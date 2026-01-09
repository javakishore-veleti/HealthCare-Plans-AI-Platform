#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[Fix] Updating API layer imports...${NC}"

CUSTOMER_API="microservices/customer-onboarding-service/customer-api/src/main/java/com/healthcare/customer/api"

# =============================================================================
# UPDATE AUTH DTOs - UserDto
# =============================================================================
cat > "$CUSTOMER_API/auth/dto/UserDto.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import com.healthcare.customer.dao.entity.auth.UserAccount;
import java.time.LocalDateTime;
import java.util.UUID;

public class UserDto {
    
    private UUID id;
    private String email;
    private String firstName;
    private String lastName;
    private String phone;
    private Boolean emailVerified;
    private LocalDateTime createdAt;
    
    public UserDto() {}
    
    public static UserDto fromEntity(UserAccount user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setFirstName(user.getFirstName());
        dto.setLastName(user.getLastName());
        dto.setPhone(user.getPhone());
        dto.setEmailVerified(user.getEmailVerified());
        dto.setCreatedAt(user.getCreatedAt());
        return dto;
    }
    
    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public Boolean getEmailVerified() { return emailVerified; }
    public void setEmailVerified(Boolean emailVerified) { this.emailVerified = emailVerified; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
EOF
echo -e "${GREEN}✓${NC} UserDto.java"

# =============================================================================
# UPDATE JWT SERVICE
# =============================================================================
cat > "$CUSTOMER_API/auth/service/JwtService.java" << 'EOF'
package com.healthcare.customer.api.auth.service;

import com.healthcare.customer.dao.entity.auth.UserAccount;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;

@Service
public class JwtService {
    
    @Value("${jwt.secret}")
    private String secretKey;
    
    @Value("${jwt.access-token-expiration}")
    private long accessTokenExpiration;
    
    @Value("${jwt.refresh-token-expiration}")
    private long refreshTokenExpiration;
    
    public String generateAccessToken(UserAccount user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("email", user.getEmail());
        claims.put("firstName", user.getFirstName());
        claims.put("lastName", user.getLastName());
        return buildToken(claims, user.getId().toString(), accessTokenExpiration);
    }
    
    public String generateRefreshToken(UserAccount user) {
        return buildToken(new HashMap<>(), user.getId().toString(), refreshTokenExpiration);
    }
    
    private String buildToken(Map<String, Object> extraClaims, String subject, long expiration) {
        return Jwts.builder()
                .claims(extraClaims)
                .subject(subject)
                .issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis() + expiration))
                .signWith(getSignInKey(), Jwts.SIG.HS256)
                .compact();
    }
    
    public boolean isTokenValid(String token) {
        try {
            Jwts.parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token);
            return !isTokenExpired(token);
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
    
    public UUID extractUserId(String token) {
        String subject = extractClaim(token, Claims::getSubject);
        return UUID.fromString(subject);
    }
    
    public String extractEmail(String token) {
        return extractClaim(token, claims -> claims.get("email", String.class));
    }
    
    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }
    
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }
    
    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }
    
    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }
    
    private SecretKey getSignInKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(keyBytes);
    }
    
    public long getAccessTokenExpiration() {
        return accessTokenExpiration;
    }
    
    public long getRefreshTokenExpiration() {
        return refreshTokenExpiration;
    }
}
EOF
echo -e "${GREEN}✓${NC} JwtService.java"

# =============================================================================
# UPDATE AUTH SERVICE
# =============================================================================
cat > "$CUSTOMER_API/auth/service/AuthService.java" << 'EOF'
package com.healthcare.customer.api.auth.service;

import com.healthcare.customer.api.auth.dto.*;
import com.healthcare.customer.dao.entity.auth.*;
import com.healthcare.customer.dao.entity.profile.*;
import com.healthcare.customer.dao.repository.auth.*;
import com.healthcare.customer.dao.repository.profile.CustomerProfileRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@Transactional
public class AuthService {
    
    private final UserAccountRepository userAccountRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final CustomerProfileRepository customerProfileRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    
    @Value("${auth.password-reset-expiry-hours:24}")
    private int passwordResetExpiryHours;
    
    @Value("${auth.max-failed-login-attempts:5}")
    private int maxFailedLoginAttempts;
    
    @Value("${auth.account-lock-duration-minutes:30}")
    private int accountLockDurationMinutes;
    
    public AuthService(
            UserAccountRepository userAccountRepository,
            PasswordResetTokenRepository passwordResetTokenRepository,
            RefreshTokenRepository refreshTokenRepository,
            CustomerProfileRepository customerProfileRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {
        this.userAccountRepository = userAccountRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.customerProfileRepository = customerProfileRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }
    
    public AuthResponse signup(SignupRequest request) {
        // Check if email already exists
        if (userAccountRepository.existsByEmail(request.getEmail().toLowerCase())) {
            throw new RuntimeException("Email already registered");
        }
        
        // Create user account
        UserAccount user = new UserAccount();
        user.setEmail(request.getEmail().toLowerCase());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setFirstName(request.getFirstName());
        user.setLastName(request.getLastName());
        user.setPhone(request.getPhone());
        user.setStatus(UserStatus.ACTIVE);
        
        user = userAccountRepository.save(user);
        
        // Create primary profile (SELF)
        CustomerProfile primaryProfile = new CustomerProfile();
        primaryProfile.setUser(user);
        primaryProfile.setFirstName(request.getFirstName());
        primaryProfile.setLastName(request.getLastName());
        primaryProfile.setDateOfBirth(LocalDate.of(1990, 1, 1)); // Default, user can update later
        primaryProfile.setGender(Gender.OTHER); // Default, user can update later
        primaryProfile.setRelationship(Relationship.SELF);
        primaryProfile.setEmail(request.getEmail());
        primaryProfile.setPhone(request.getPhone());
        primaryProfile.setIsPrimary(true);
        primaryProfile.setStatus(ProfileStatus.ACTIVE);
        
        customerProfileRepository.save(primaryProfile);
        
        // Generate tokens
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = createRefreshToken(user, null, null);
        
        return new AuthResponse(
            accessToken,
            refreshToken,
            jwtService.getAccessTokenExpiration(),
            UserDto.fromEntity(user)
        );
    }
    
    public AuthResponse login(LoginRequest request, String ipAddress, String userAgent) {
        UserAccount user = userAccountRepository.findByEmail(request.getEmail().toLowerCase())
            .orElseThrow(() -> new RuntimeException("Invalid email or password"));
        
        // Check if account is locked
        if (user.isLocked()) {
            throw new RuntimeException("Account is locked. Try again later.");
        }
        
        // Verify password
        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            handleFailedLogin(user);
            throw new RuntimeException("Invalid email or password");
        }
        
        // Check if account is active
        if (user.getStatus() != UserStatus.ACTIVE) {
            throw new RuntimeException("Account is not active");
        }
        
        // Reset failed login attempts on successful login
        user.resetFailedLoginAttempts();
        user.setLastLoginAt(LocalDateTime.now());
        userAccountRepository.save(user);
        
        // Generate tokens
        String accessToken = jwtService.generateAccessToken(user);
        String refreshToken = createRefreshToken(user, ipAddress, userAgent);
        
        return new AuthResponse(
            accessToken,
            refreshToken,
            jwtService.getAccessTokenExpiration(),
            UserDto.fromEntity(user)
        );
    }
    
    private void handleFailedLogin(UserAccount user) {
        user.incrementFailedLoginAttempts();
        
        if (user.getFailedLoginAttempts() >= maxFailedLoginAttempts) {
            user.setLockedUntil(LocalDateTime.now().plusMinutes(accountLockDurationMinutes));
        }
        
        userAccountRepository.save(user);
    }
    
    private String createRefreshToken(UserAccount user, String ipAddress, String deviceInfo) {
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setToken(UUID.randomUUID().toString());
        refreshToken.setIpAddress(ipAddress);
        refreshToken.setDeviceInfo(deviceInfo);
        refreshToken.setExpiresAt(LocalDateTime.now().plusDays(7));
        
        refreshTokenRepository.save(refreshToken);
        
        return refreshToken.getToken();
    }
    
    public AuthResponse refreshToken(String refreshTokenStr) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(refreshTokenStr)
            .orElseThrow(() -> new RuntimeException("Invalid refresh token"));
        
        if (!refreshToken.isValid()) {
            throw new RuntimeException("Refresh token is expired or revoked");
        }
        
        UserAccount user = refreshToken.getUser();
        
        // Revoke old refresh token
        refreshToken.revoke();
        refreshTokenRepository.save(refreshToken);
        
        // Generate new tokens
        String newAccessToken = jwtService.generateAccessToken(user);
        String newRefreshToken = createRefreshToken(user, refreshToken.getIpAddress(), refreshToken.getDeviceInfo());
        
        return new AuthResponse(
            newAccessToken,
            newRefreshToken,
            jwtService.getAccessTokenExpiration(),
            UserDto.fromEntity(user)
        );
    }
    
    public void logout(UUID userId) {
        refreshTokenRepository.revokeAllByUserId(userId);
    }
    
    public void forgotPassword(String email) {
        userAccountRepository.findByEmail(email.toLowerCase()).ifPresent(user -> {
            // Delete any existing tokens
            passwordResetTokenRepository.deleteByUserId(user.getId());
            
            // Create new reset token
            PasswordResetToken resetToken = new PasswordResetToken();
            resetToken.setUser(user);
            resetToken.setToken(UUID.randomUUID().toString());
            resetToken.setExpiresAt(LocalDateTime.now().plusHours(passwordResetExpiryHours));
            
            passwordResetTokenRepository.save(resetToken);
            
            // TODO: Send email with reset link
            System.out.println("Password reset token for " + email + ": " + resetToken.getToken());
        });
    }
    
    public void resetPassword(ResetPasswordRequest request) {
        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(request.getToken())
            .orElseThrow(() -> new RuntimeException("Invalid or expired reset token"));
        
        if (!resetToken.isValid()) {
            throw new RuntimeException("Invalid or expired reset token");
        }
        
        UserAccount user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.resetFailedLoginAttempts();
        userAccountRepository.save(user);
        
        // Mark token as used
        resetToken.setUsedAt(LocalDateTime.now());
        passwordResetTokenRepository.save(resetToken);
        
        // Revoke all refresh tokens
        refreshTokenRepository.revokeAllByUserId(user.getId());
    }
    
    public UserAccount getUserById(UUID userId) {
        return userAccountRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
EOF
echo -e "${GREEN}✓${NC} AuthService.java"

# =============================================================================
# UPDATE JWT AUTH FILTER
# =============================================================================
cat > "$CUSTOMER_API/auth/security/JwtAuthenticationFilter.java" << 'EOF'
package com.healthcare.customer.api.auth.security;

import com.healthcare.customer.api.auth.service.JwtService;
import com.healthcare.customer.dao.entity.auth.UserAccount;
import com.healthcare.customer.dao.repository.auth.UserAccountRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.UUID;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    private final JwtService jwtService;
    private final UserAccountRepository userAccountRepository;
    
    public JwtAuthenticationFilter(JwtService jwtService, UserAccountRepository userAccountRepository) {
        this.jwtService = jwtService;
        this.userAccountRepository = userAccountRepository;
    }
    
    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        
        final String authHeader = request.getHeader("Authorization");
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }
        
        final String jwt = authHeader.substring(7);
        
        try {
            if (jwtService.isTokenValid(jwt)) {
                UUID userId = jwtService.extractUserId(jwt);
                
                UserAccount user = userAccountRepository.findById(userId).orElse(null);
                
                if (user != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        user,
                        null,
                        Collections.emptyList()
                    );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (Exception e) {
            // Invalid token, continue without authentication
        }
        
        filterChain.doFilter(request, response);
    }
}
EOF
echo -e "${GREEN}✓${NC} JwtAuthenticationFilter.java"

# =============================================================================
# UPDATE AUTH UTILS
# =============================================================================
cat > "$CUSTOMER_API/auth/security/AuthUtils.java" << 'EOF'
package com.healthcare.customer.api.auth.security;

import com.healthcare.customer.dao.entity.auth.UserAccount;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.UUID;

public class AuthUtils {
    
    public static UserAccount getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof UserAccount) {
            return (UserAccount) authentication.getPrincipal();
        }
        return null;
    }
    
    public static UUID getCurrentUserId() {
        UserAccount user = getCurrentUser();
        return user != null ? user.getId() : null;
    }
    
    public static boolean isAuthenticated() {
        return getCurrentUser() != null;
    }
}
EOF
echo -e "${GREEN}✓${NC} AuthUtils.java"

# =============================================================================
# UPDATE PROFILE DTOs
# =============================================================================
cat > "$CUSTOMER_API/profile/dto/ProfileDto.java" << 'EOF'
package com.healthcare.customer.api.profile.dto;

import com.healthcare.customer.dao.entity.profile.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public class ProfileDto {
    
    private UUID id;
    private String firstName;
    private String lastName;
    private LocalDate dateOfBirth;
    private String gender;
    private String relationship;
    private String email;
    private String phone;
    private Boolean isPrimary;
    private String status;
    private AddressDto address;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public ProfileDto() {}
    
    public static ProfileDto fromEntity(CustomerProfile profile) {
        ProfileDto dto = new ProfileDto();
        dto.setId(profile.getId());
        dto.setFirstName(profile.getFirstName());
        dto.setLastName(profile.getLastName());
        dto.setDateOfBirth(profile.getDateOfBirth());
        dto.setGender(profile.getGender().name());
        dto.setRelationship(profile.getRelationship().name());
        dto.setEmail(profile.getEmail());
        dto.setPhone(profile.getPhone());
        dto.setIsPrimary(profile.getIsPrimary());
        dto.setStatus(profile.getStatus().name());
        dto.setCreatedAt(profile.getCreatedAt());
        dto.setUpdatedAt(profile.getUpdatedAt());
        
        // Get primary address
        if (profile.getAddresses() != null && !profile.getAddresses().isEmpty()) {
            profile.getAddresses().stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsPrimary()))
                .findFirst()
                .or(() -> profile.getAddresses().stream().findFirst())
                .ifPresent(addr -> dto.setAddress(AddressDto.fromEntity(addr)));
        }
        
        return dto;
    }
    
    public static List<ProfileDto> fromEntities(List<CustomerProfile> profiles) {
        return profiles.stream()
            .map(ProfileDto::fromEntity)
            .collect(Collectors.toList());
    }
    
    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    
    public String getRelationship() { return relationship; }
    public void setRelationship(String relationship) { this.relationship = relationship; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public Boolean getIsPrimary() { return isPrimary; }
    public void setIsPrimary(Boolean isPrimary) { this.isPrimary = isPrimary; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public AddressDto getAddress() { return address; }
    public void setAddress(AddressDto address) { this.address = address; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
EOF
echo -e "${GREEN}✓${NC} ProfileDto.java"

cat > "$CUSTOMER_API/profile/dto/AddressDto.java" << 'EOF'
package com.healthcare.customer.api.profile.dto;

import com.healthcare.customer.dao.entity.profile.ProfileAddress;

public class AddressDto {
    
    private String street1;
    private String street2;
    private String city;
    private String state;
    private String zipCode;
    private String country;
    
    public AddressDto() {}
    
    public static AddressDto fromEntity(ProfileAddress address) {
        AddressDto dto = new AddressDto();
        dto.setStreet1(address.getStreet1());
        dto.setStreet2(address.getStreet2());
        dto.setCity(address.getCity());
        dto.setState(address.getState());
        dto.setZipCode(address.getZipCode());
        dto.setCountry(address.getCountry());
        return dto;
    }
    
    // Getters and Setters
    public String getStreet1() { return street1; }
    public void setStreet1(String street1) { this.street1 = street1; }
    
    public String getStreet2() { return street2; }
    public void setStreet2(String street2) { this.street2 = street2; }
    
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    
    public String getZipCode() { return zipCode; }
    public void setZipCode(String zipCode) { this.zipCode = zipCode; }
    
    public String getCountry() { return country; }
    public void setCountry(String country) { this.country = country; }
}
EOF
echo -e "${GREEN}✓${NC} AddressDto.java"

# =============================================================================
# UPDATE PROFILE SERVICE
# =============================================================================
cat > "$CUSTOMER_API/profile/service/ProfileService.java" << 'EOF'
package com.healthcare.customer.api.profile.service;

import com.healthcare.customer.api.profile.dto.*;
import com.healthcare.customer.dao.entity.auth.UserAccount;
import com.healthcare.customer.dao.entity.profile.*;
import com.healthcare.customer.dao.repository.auth.UserAccountRepository;
import com.healthcare.customer.dao.repository.profile.CustomerProfileRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ProfileService {
    
    private final CustomerProfileRepository profileRepository;
    private final UserAccountRepository userAccountRepository;
    
    @Value("${auth.max-profiles-per-user:500}")
    private int maxProfilesPerUser;
    
    public ProfileService(
            CustomerProfileRepository profileRepository,
            UserAccountRepository userAccountRepository) {
        this.profileRepository = profileRepository;
        this.userAccountRepository = userAccountRepository;
    }
    
    public List<ProfileDto> getProfilesByUserId(UUID userId) {
        List<CustomerProfile> profiles = profileRepository.findByUserIdOrderByIsPrimaryDescCreatedAtAsc(userId);
        return ProfileDto.fromEntities(profiles);
    }
    
    public ProfileDto getProfileById(UUID profileId, UUID userId) {
        CustomerProfile profile = profileRepository.findByIdAndUserId(profileId, userId)
            .orElseThrow(() -> new RuntimeException("Profile not found"));
        return ProfileDto.fromEntity(profile);
    }
    
    public ProfileDto createProfile(CreateProfileRequest request, UUID userId) {
        // Check profile limit
        long currentCount = profileRepository.countByUserId(userId);
        if (currentCount >= maxProfilesPerUser) {
            throw new RuntimeException("Maximum number of profiles (" + maxProfilesPerUser + ") reached");
        }
        
        UserAccount user = userAccountRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Check if this is the first profile (should be primary)
        boolean isPrimary = !profileRepository.existsByUserIdAndIsPrimaryTrue(userId);
        
        CustomerProfile profile = new CustomerProfile();
        profile.setUser(user);
        profile.setFirstName(request.getFirstName());
        profile.setLastName(request.getLastName());
        profile.setDateOfBirth(request.getDateOfBirth());
        profile.setGender(Gender.valueOf(request.getGender().toUpperCase()));
        profile.setRelationship(Relationship.valueOf(request.getRelationship().toUpperCase()));
        profile.setEmail(request.getEmail());
        profile.setPhone(request.getPhone());
        profile.setIsPrimary(isPrimary);
        profile.setStatus(ProfileStatus.ACTIVE);
        
        // Add address if provided
        if (request.getAddress() != null && request.getAddress().getStreet1() != null) {
            ProfileAddress address = new ProfileAddress();
            address.setStreet1(request.getAddress().getStreet1());
            address.setStreet2(request.getAddress().getStreet2());
            address.setCity(request.getAddress().getCity());
            address.setState(request.getAddress().getState());
            address.setZipCode(request.getAddress().getZipCode());
            address.setCountry(request.getAddress().getCountry() != null ? 
                request.getAddress().getCountry() : "USA");
            address.setIsPrimary(true);
            profile.addAddress(address);
        }
        
        profile = profileRepository.save(profile);
        return ProfileDto.fromEntity(profile);
    }
    
    public ProfileDto updateProfile(UUID profileId, UpdateProfileRequest request, UUID userId) {
        CustomerProfile profile = profileRepository.findByIdAndUserId(profileId, userId)
            .orElseThrow(() -> new RuntimeException("Profile not found"));
        
        if (request.getFirstName() != null) {
            profile.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            profile.setLastName(request.getLastName());
        }
        if (request.getDateOfBirth() != null) {
            profile.setDateOfBirth(request.getDateOfBirth());
        }
        if (request.getGender() != null) {
            profile.setGender(Gender.valueOf(request.getGender().toUpperCase()));
        }
        if (request.getRelationship() != null) {
            if (!profile.getIsPrimary() || !Relationship.SELF.equals(profile.getRelationship())) {
                profile.setRelationship(Relationship.valueOf(request.getRelationship().toUpperCase()));
            }
        }
        if (request.getEmail() != null) {
            profile.setEmail(request.getEmail());
        }
        if (request.getPhone() != null) {
            profile.setPhone(request.getPhone());
        }
        
        // Update address
        if (request.getAddress() != null) {
            ProfileAddress address = profile.getAddresses().stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsPrimary()))
                .findFirst()
                .orElseGet(() -> {
                    ProfileAddress newAddr = new ProfileAddress();
                    newAddr.setIsPrimary(true);
                    profile.addAddress(newAddr);
                    return newAddr;
                });
            
            if (request.getAddress().getStreet1() != null) {
                address.setStreet1(request.getAddress().getStreet1());
            }
            address.setStreet2(request.getAddress().getStreet2());
            if (request.getAddress().getCity() != null) {
                address.setCity(request.getAddress().getCity());
            }
            if (request.getAddress().getState() != null) {
                address.setState(request.getAddress().getState());
            }
            if (request.getAddress().getZipCode() != null) {
                address.setZipCode(request.getAddress().getZipCode());
            }
            if (request.getAddress().getCountry() != null) {
                address.setCountry(request.getAddress().getCountry());
            }
        }
        
        profile = profileRepository.save(profile);
        return ProfileDto.fromEntity(profile);
    }
    
    public void deleteProfile(UUID profileId, UUID userId) {
        CustomerProfile profile = profileRepository.findByIdAndUserId(profileId, userId)
            .orElseThrow(() -> new RuntimeException("Profile not found"));
        
        if (Boolean.TRUE.equals(profile.getIsPrimary())) {
            throw new RuntimeException("Cannot delete primary profile");
        }
        
        profileRepository.delete(profile);
    }
    
    public ProfileDto setPrimaryProfile(UUID profileId, UUID userId) {
        CustomerProfile newPrimary = profileRepository.findByIdAndUserId(profileId, userId)
            .orElseThrow(() -> new RuntimeException("Profile not found"));
        
        profileRepository.findPrimaryByUserId(userId).ifPresent(currentPrimary -> {
            currentPrimary.setIsPrimary(false);
            profileRepository.save(currentPrimary);
        });
        
        newPrimary.setIsPrimary(true);
        newPrimary = profileRepository.save(newPrimary);
        
        return ProfileDto.fromEntity(newPrimary);
    }
    
    public long getProfileCount(UUID userId) {
        return profileRepository.countByUserId(userId);
    }
    
    public int getMaxProfilesPerUser() {
        return maxProfilesPerUser;
    }
}
EOF
echo -e "${GREEN}✓${NC} ProfileService.java"

# =============================================================================
# UPDATE AUTH CONTROLLER
# =============================================================================
cat > "$CUSTOMER_API/auth/controller/AuthController.java" << 'EOF'
package com.healthcare.customer.api.auth.controller;

import com.healthcare.customer.api.auth.dto.*;
import com.healthcare.customer.api.auth.service.AuthService;
import com.healthcare.customer.api.auth.security.AuthUtils;
import com.healthcare.customer.api.profile.dto.ProfileDto;
import com.healthcare.customer.api.profile.service.ProfileService;
import com.healthcare.customer.dao.entity.auth.UserAccount;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001"})
public class AuthController {
    
    private final AuthService authService;
    private final ProfileService profileService;
    
    public AuthController(AuthService authService, ProfileService profileService) {
        this.authService = authService;
        this.profileService = profileService;
    }
    
    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {
        String ipAddress = getClientIpAddress(httpRequest);
        String userAgent = httpRequest.getHeader("User-Agent");
        
        AuthResponse response = authService.login(request, ipAddress, userAgent);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout() {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId != null) {
            authService.logout(userId);
        }
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Logged out successfully");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, String>> forgotPassword(@Valid @RequestBody ForgotPasswordRequest request) {
        authService.forgotPassword(request.getEmail());
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "If the email exists, a password reset link has been sent");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, String>> resetPassword(@Valid @RequestBody ResetPasswordRequest request) {
        authService.resetPassword(request);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Password reset successfully");
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/me")
    public ResponseEntity<MeResponse> getCurrentUser() {
        UserAccount user = AuthUtils.getCurrentUser();
        if (user == null) {
            return ResponseEntity.status(401).build();
        }
        
        UserDto userDto = UserDto.fromEntity(user);
        List<ProfileDto> profiles = profileService.getProfilesByUserId(user.getId());
        
        MeResponse response = new MeResponse();
        response.setUser(userDto);
        response.setProfiles(profiles);
        
        return ResponseEntity.ok(response);
    }
    
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
EOF
echo -e "${GREEN}✓${NC} AuthController.java"

echo -e "${GREEN}✓ API imports fixed${NC}"