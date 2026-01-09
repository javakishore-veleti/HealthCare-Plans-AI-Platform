#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[3/5] Creating auth service layer...${NC}"

CUSTOMER_API="microservices/customer-onboarding-service/customer-api/src/main/java/com/healthcare/customer/api"

# Create directories
mkdir -p "$CUSTOMER_API/auth/service"
mkdir -p "$CUSTOMER_API/auth/dto"
mkdir -p "$CUSTOMER_API/auth/config"
mkdir -p "$CUSTOMER_API/auth/security"

# =============================================================================
# ADD JWT DEPENDENCY TO POM.XML
# =============================================================================
echo -e "${CYAN}Adding JWT dependencies...${NC}"

CUSTOMER_API_POM="microservices/customer-onboarding-service/customer-api/pom.xml"

# Check if jjwt already exists
if ! grep -q "jjwt-api" "$CUSTOMER_API_POM"; then
    # Add before </dependencies>
    sed -i '' 's|</dependencies>|        <!-- JWT -->\
        <dependency>\
            <groupId>io.jsonwebtoken</groupId>\
            <artifactId>jjwt-api</artifactId>\
            <version>0.12.5</version>\
        </dependency>\
        <dependency>\
            <groupId>io.jsonwebtoken</groupId>\
            <artifactId>jjwt-impl</artifactId>\
            <version>0.12.5</version>\
            <scope>runtime</scope>\
        </dependency>\
        <dependency>\
            <groupId>io.jsonwebtoken</groupId>\
            <artifactId>jjwt-jackson</artifactId>\
            <version>0.12.5</version>\
            <scope>runtime</scope>\
        </dependency>\
        <!-- Spring Security -->\
        <dependency>\
            <groupId>org.springframework.boot</groupId>\
            <artifactId>spring-boot-starter-security</artifactId>\
        </dependency>\
    </dependencies>|' "$CUSTOMER_API_POM"
    echo -e "${GREEN}✓${NC} JWT dependencies added to pom.xml"
else
    echo -e "${GREEN}✓${NC} JWT dependencies already exist"
fi

# =============================================================================
# JWT CONFIGURATION PROPERTIES
# =============================================================================
cat >> "microservices/customer-onboarding-service/customer-api/src/main/resources/application-local.yaml" << 'EOF'

# JWT Configuration
jwt:
  secret: healthcare-plans-jwt-secret-key-must-be-at-least-256-bits-long-for-hs256
  access-token-expiration: 3600000      # 1 hour in milliseconds
  refresh-token-expiration: 604800000   # 7 days in milliseconds

# Auth Configuration
auth:
  max-profiles-per-user: 500
  password-reset-expiry-hours: 24
  max-failed-login-attempts: 5
  account-lock-duration-minutes: 30
EOF
echo -e "${GREEN}✓${NC} JWT configuration added"

# =============================================================================
# AUTH DTOs
# =============================================================================
cat > "$CUSTOMER_API/auth/dto/SignupRequest.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class SignupRequest {
    
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 100, message = "First name must be between 2 and 100 characters")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 100, message = "Last name must be between 2 and 100 characters")
    private String lastName;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$", 
             message = "Password must contain at least one uppercase, one lowercase, and one number")
    private String password;
    
    @Size(min = 10, max = 20, message = "Phone must be between 10 and 20 characters")
    private String phone;
    
    // Getters and Setters
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
EOF
echo -e "${GREEN}✓${NC} SignupRequest.java"

cat > "$CUSTOMER_API/auth/dto/LoginRequest.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class LoginRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    @NotBlank(message = "Password is required")
    private String password;
    
    // Getters and Setters
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
EOF
echo -e "${GREEN}✓${NC} LoginRequest.java"

cat > "$CUSTOMER_API/auth/dto/AuthResponse.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

public class AuthResponse {
    
    private String token;
    private String refreshToken;
    private String tokenType = "Bearer";
    private long expiresIn;
    private UserDto user;
    
    public AuthResponse() {}
    
    public AuthResponse(String token, String refreshToken, long expiresIn, UserDto user) {
        this.token = token;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
        this.user = user;
    }
    
    // Getters and Setters
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
    
    public String getTokenType() { return tokenType; }
    public void setTokenType(String tokenType) { this.tokenType = tokenType; }
    
    public long getExpiresIn() { return expiresIn; }
    public void setExpiresIn(long expiresIn) { this.expiresIn = expiresIn; }
    
    public UserDto getUser() { return user; }
    public void setUser(UserDto user) { this.user = user; }
}
EOF
echo -e "${GREEN}✓${NC} AuthResponse.java"

cat > "$CUSTOMER_API/auth/dto/UserDto.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import com.healthcare.customer.domain.auth.entity.UserAccount;
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

cat > "$CUSTOMER_API/auth/dto/ForgotPasswordRequest.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class ForgotPasswordRequest {
    
    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
}
EOF
echo -e "${GREEN}✓${NC} ForgotPasswordRequest.java"

cat > "$CUSTOMER_API/auth/dto/ResetPasswordRequest.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class ResetPasswordRequest {
    
    @NotBlank(message = "Token is required")
    private String token;
    
    @NotBlank(message = "Password is required")
    @Size(min = 8, message = "Password must be at least 8 characters")
    @Pattern(regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$", 
             message = "Password must contain at least one uppercase, one lowercase, and one number")
    private String password;
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
EOF
echo -e "${GREEN}✓${NC} ResetPasswordRequest.java"

cat > "$CUSTOMER_API/auth/dto/RefreshTokenRequest.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import jakarta.validation.constraints.NotBlank;

public class RefreshTokenRequest {
    
    @NotBlank(message = "Refresh token is required")
    private String refreshToken;
    
    public String getRefreshToken() { return refreshToken; }
    public void setRefreshToken(String refreshToken) { this.refreshToken = refreshToken; }
}
EOF
echo -e "${GREEN}✓${NC} RefreshTokenRequest.java"

# =============================================================================
# JWT SERVICE
# =============================================================================
cat > "$CUSTOMER_API/auth/service/JwtService.java" << 'EOF'
package com.healthcare.customer.api.auth.service;

import com.healthcare.customer.domain.auth.entity.UserAccount;
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
# AUTH SERVICE
# =============================================================================
cat > "$CUSTOMER_API/auth/service/AuthService.java" << 'EOF'
package com.healthcare.customer.api.auth.service;

import com.healthcare.customer.api.auth.dto.*;
import com.healthcare.customer.domain.auth.entity.*;
import com.healthcare.customer.domain.auth.repository.*;
import com.healthcare.customer.domain.profile.entity.*;
import com.healthcare.customer.domain.profile.repository.CustomerProfileRepository;
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
            // emailService.sendPasswordResetEmail(user.getEmail(), resetToken.getToken());
            
            System.out.println("Password reset token for " + email + ": " + resetToken.getToken());
        });
        
        // Always return success to prevent email enumeration
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
    
    public UserAccount getUserByEmail(String email) {
        return userAccountRepository.findByEmail(email.toLowerCase())
            .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
EOF
echo -e "${GREEN}✓${NC} AuthService.java"

# =============================================================================
# SECURITY CONFIG
# =============================================================================
cat > "$CUSTOMER_API/auth/config/SecurityConfig.java" << 'EOF'
package com.healthcare.customer.api.auth.config;

import com.healthcare.customer.api.auth.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    private final JwtAuthenticationFilter jwtAuthFilter;
    
    public SecurityConfig(JwtAuthenticationFilter jwtAuthFilter) {
        this.jwtAuthFilter = jwtAuthFilter;
    }
    
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/api/v1/auth/**").permitAll()
                .requestMatchers("/actuator/**").permitAll()
                .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll()
                // Existing customer endpoints (keep backward compatible)
                .requestMatchers("/api/v1/customers/search").permitAll()
                .requestMatchers("/api/v1/customers/**").permitAll()
                // Protected endpoints
                .requestMatchers("/api/v1/profiles/**").authenticated()
                .requestMatchers("/api/v1/me/**").authenticated()
                .anyRequest().permitAll()
            )
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("http://localhost:3000", "http://localhost:3001"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
    
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
EOF
echo -e "${GREEN}✓${NC} SecurityConfig.java"

# =============================================================================
# JWT AUTHENTICATION FILTER
# =============================================================================
cat > "$CUSTOMER_API/auth/security/JwtAuthenticationFilter.java" << 'EOF'
package com.healthcare.customer.api.auth.security;

import com.healthcare.customer.api.auth.service.JwtService;
import com.healthcare.customer.domain.auth.entity.UserAccount;
import com.healthcare.customer.domain.auth.repository.UserAccountRepository;
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
# AUTH UTILS - GET CURRENT USER
# =============================================================================
cat > "$CUSTOMER_API/auth/security/AuthUtils.java" << 'EOF'
package com.healthcare.customer.api.auth.security;

import com.healthcare.customer.domain.auth.entity.UserAccount;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
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

echo -e "${GREEN}✓ Auth service layer created${NC}"