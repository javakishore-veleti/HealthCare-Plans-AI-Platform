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
