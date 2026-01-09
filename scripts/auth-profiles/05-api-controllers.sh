#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[5/5] Creating API controllers...${NC}"

CUSTOMER_API="microservices/customer-onboarding-service/customer-api/src/main/java/com/healthcare/customer/api"

# Create directories
mkdir -p "$CUSTOMER_API/auth/controller"
mkdir -p "$CUSTOMER_API/profile/controller"

# =============================================================================
# AUTH CONTROLLER
# =============================================================================
cat > "$CUSTOMER_API/auth/controller/AuthController.java" << 'EOF'
package com.healthcare.customer.api.auth.controller;

import com.healthcare.customer.api.auth.dto.*;
import com.healthcare.customer.api.auth.service.AuthService;
import com.healthcare.customer.api.auth.security.AuthUtils;
import com.healthcare.customer.api.profile.dto.ProfileDto;
import com.healthcare.customer.api.profile.service.ProfileService;
import com.healthcare.customer.domain.auth.entity.UserAccount;
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

# =============================================================================
# ME RESPONSE DTO
# =============================================================================
cat > "$CUSTOMER_API/auth/dto/MeResponse.java" << 'EOF'
package com.healthcare.customer.api.auth.dto;

import com.healthcare.customer.api.profile.dto.ProfileDto;
import java.util.List;

public class MeResponse {
    
    private UserDto user;
    private List<ProfileDto> profiles;
    
    public MeResponse() {}
    
    public UserDto getUser() { return user; }
    public void setUser(UserDto user) { this.user = user; }
    
    public List<ProfileDto> getProfiles() { return profiles; }
    public void setProfiles(List<ProfileDto> profiles) { this.profiles = profiles; }
}
EOF
echo -e "${GREEN}✓${NC} MeResponse.java"

# =============================================================================
# PROFILE CONTROLLER
# =============================================================================
cat > "$CUSTOMER_API/profile/controller/ProfileController.java" << 'EOF'
package com.healthcare.customer.api.profile.controller;

import com.healthcare.customer.api.auth.security.AuthUtils;
import com.healthcare.customer.api.profile.dto.*;
import com.healthcare.customer.api.profile.service.ProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/profiles")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:3001"})
public class ProfileController {
    
    private final ProfileService profileService;
    
    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }
    
    @GetMapping
    public ResponseEntity<List<ProfileDto>> getProfiles() {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        List<ProfileDto> profiles = profileService.getProfilesByUserId(userId);
        return ResponseEntity.ok(profiles);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ProfileDto> getProfile(@PathVariable UUID id) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.getProfileById(id, userId);
        return ResponseEntity.ok(profile);
    }
    
    @PostMapping
    public ResponseEntity<ProfileDto> createProfile(@Valid @RequestBody CreateProfileRequest request) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.createProfile(request, userId);
        return ResponseEntity.ok(profile);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ProfileDto> updateProfile(
            @PathVariable UUID id,
            @Valid @RequestBody UpdateProfileRequest request) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.updateProfile(id, request, userId);
        return ResponseEntity.ok(profile);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> deleteProfile(@PathVariable UUID id) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        profileService.deleteProfile(id, userId);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "Profile deleted successfully");
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/{id}/set-primary")
    public ResponseEntity<ProfileDto> setPrimaryProfile(@PathVariable UUID id) {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        ProfileDto profile = profileService.setPrimaryProfile(id, userId);
        return ResponseEntity.ok(profile);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getProfileStats() {
        UUID userId = AuthUtils.getCurrentUserId();
        if (userId == null) {
            return ResponseEntity.status(401).build();
        }
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("count", profileService.getProfileCount(userId));
        stats.put("maxAllowed", profileService.getMaxProfilesPerUser());
        stats.put("canAddMore", profileService.getProfileCount(userId) < profileService.getMaxProfilesPerUser());
        
        return ResponseEntity.ok(stats);
    }
}
EOF
echo -e "${GREEN}✓${NC} ProfileController.java"

# =============================================================================
# GLOBAL EXCEPTION HANDLER
# =============================================================================
cat > "$CUSTOMER_API/auth/config/GlobalExceptionHandler.java" << 'EOF'
package com.healthcare.customer.api.auth.config;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, Object>> handleRuntimeException(RuntimeException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("timestamp", LocalDateTime.now().toString());
        error.put("message", ex.getMessage());
        error.put("status", HttpStatus.BAD_REQUEST.value());
        
        return ResponseEntity.badRequest().body(error);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, Object> error = new HashMap<>();
        error.put("timestamp", LocalDateTime.now().toString());
        error.put("status", HttpStatus.BAD_REQUEST.value());
        
        Map<String, String> fieldErrors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(err -> {
            String fieldName = ((FieldError) err).getField();
            String errorMessage = err.getDefaultMessage();
            fieldErrors.put(fieldName, errorMessage);
        });
        
        error.put("message", "Validation failed");
        error.put("errors", fieldErrors);
        
        return ResponseEntity.badRequest().body(error);
    }
}
EOF
echo -e "${GREEN}✓${NC} GlobalExceptionHandler.java"

# =============================================================================
# UPDATE APPLICATION YAML - ENCODE JWT SECRET
# =============================================================================
echo -e "${CYAN}Updating JWT secret to Base64...${NC}"

# Generate a proper Base64 encoded secret
JWT_SECRET=$(echo -n "healthcare-plans-jwt-secret-key-must-be-at-least-256-bits-long-for-hs256-algorithm" | base64)

cat > "microservices/customer-onboarding-service/customer-api/src/main/resources/application-local.yaml" << EOF
server:
  port: 8083

spring:
  application:
    name: customer-onboarding-service
  datasource:
    url: jdbc:postgresql://localhost:5432/customer_db
    username: customer_user
    password: customer_pass
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

# JWT Configuration
jwt:
  secret: ${JWT_SECRET}
  access-token-expiration: 3600000
  refresh-token-expiration: 604800000

# Auth Configuration
auth:
  max-profiles-per-user: 500
  password-reset-expiry-hours: 24
  max-failed-login-attempts: 5
  account-lock-duration-minutes: 30

logging:
  level:
    com.healthcare: DEBUG
    org.springframework.security: DEBUG
EOF
echo -e "${GREEN}✓${NC} application-local.yaml updated with Base64 JWT secret"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Auth & Profiles API Complete!        ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "API Endpoints:"
echo ""
echo "  Auth:"
echo "    POST /api/v1/auth/signup          - Create account"
echo "    POST /api/v1/auth/login           - Login"
echo "    POST /api/v1/auth/refresh         - Refresh token"
echo "    POST /api/v1/auth/logout          - Logout"
echo "    POST /api/v1/auth/forgot-password - Request password reset"
echo "    POST /api/v1/auth/reset-password  - Reset password"
echo "    GET  /api/v1/auth/me              - Get current user + profiles"
echo ""
echo "  Profiles:"
echo "    GET    /api/v1/profiles           - List all profiles"
echo "    GET    /api/v1/profiles/:id       - Get profile by ID"
echo "    POST   /api/v1/profiles           - Create profile"
echo "    PUT    /api/v1/profiles/:id       - Update profile"
echo "    DELETE /api/v1/profiles/:id       - Delete profile"
echo "    POST   /api/v1/profiles/:id/set-primary - Set as primary"
echo "    GET    /api/v1/profiles/stats     - Get profile stats"
echo ""
echo "Next: Rebuild and restart Customer Service"
echo "  cd microservices/customer-onboarding-service"
echo "  mvn clean install -DskipTests"
echo "  cd customer-api && mvn spring-boot:run -Dspring-boot.run.profiles=local"
EOF
echo -e "${GREEN}✓ API controllers created${NC}"