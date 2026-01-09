#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[Fix] Moving domain entities to customer-dao module...${NC}"

CUSTOMER_DAO="microservices/customer-onboarding-service/customer-dao/src/main/java/com/healthcare/customer/dao"

# Create directories in customer-dao
mkdir -p "$CUSTOMER_DAO/entity/auth"
mkdir -p "$CUSTOMER_DAO/entity/profile"
mkdir -p "$CUSTOMER_DAO/repository/auth"
mkdir -p "$CUSTOMER_DAO/repository/profile"

# =============================================================================
# MOVE AUTH ENTITIES
# =============================================================================

cat > "$CUSTOMER_DAO/entity/auth/UserAccount.java" << 'EOF'
package com.healthcare.customer.dao.entity.auth;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "user_accounts")
public class UserAccount {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(nullable = false, unique = true)
    private String email;
    
    @Column(name = "password_hash", nullable = false)
    private String passwordHash;
    
    @Column(name = "first_name", nullable = false)
    private String firstName;
    
    @Column(name = "last_name", nullable = false)
    private String lastName;
    
    private String phone;
    
    @Column(name = "email_verified")
    private Boolean emailVerified = false;
    
    @Column(name = "email_verified_at")
    private LocalDateTime emailVerifiedAt;
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private UserStatus status = UserStatus.ACTIVE;
    
    @Column(name = "failed_login_attempts")
    private Integer failedLoginAttempts = 0;
    
    @Column(name = "locked_until")
    private LocalDateTime lockedUntil;
    
    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public Boolean getEmailVerified() { return emailVerified; }
    public void setEmailVerified(Boolean emailVerified) { this.emailVerified = emailVerified; }
    
    public LocalDateTime getEmailVerifiedAt() { return emailVerifiedAt; }
    public void setEmailVerifiedAt(LocalDateTime emailVerifiedAt) { this.emailVerifiedAt = emailVerifiedAt; }
    
    public UserStatus getStatus() { return status; }
    public void setStatus(UserStatus status) { this.status = status; }
    
    public Integer getFailedLoginAttempts() { return failedLoginAttempts; }
    public void setFailedLoginAttempts(Integer failedLoginAttempts) { this.failedLoginAttempts = failedLoginAttempts; }
    
    public LocalDateTime getLockedUntil() { return lockedUntil; }
    public void setLockedUntil(LocalDateTime lockedUntil) { this.lockedUntil = lockedUntil; }
    
    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    public boolean isLocked() {
        return lockedUntil != null && lockedUntil.isAfter(LocalDateTime.now());
    }
    
    public void incrementFailedLoginAttempts() {
        this.failedLoginAttempts = (this.failedLoginAttempts == null ? 0 : this.failedLoginAttempts) + 1;
    }
    
    public void resetFailedLoginAttempts() {
        this.failedLoginAttempts = 0;
        this.lockedUntil = null;
    }
}
EOF
echo -e "${GREEN}✓${NC} UserAccount.java"

cat > "$CUSTOMER_DAO/entity/auth/UserStatus.java" << 'EOF'
package com.healthcare.customer.dao.entity.auth;

public enum UserStatus {
    ACTIVE,
    INACTIVE,
    SUSPENDED,
    PENDING_VERIFICATION
}
EOF
echo -e "${GREEN}✓${NC} UserStatus.java"

cat > "$CUSTOMER_DAO/entity/auth/PasswordResetToken.java" << 'EOF'
package com.healthcare.customer.dao.entity.auth;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "password_reset_tokens")
public class PasswordResetToken {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private UserAccount user;
    
    @Column(nullable = false, unique = true)
    private String token;
    
    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;
    
    @Column(name = "used_at")
    private LocalDateTime usedAt;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public UserAccount getUser() { return user; }
    public void setUser(UserAccount user) { this.user = user; }
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    
    public LocalDateTime getUsedAt() { return usedAt; }
    public void setUsedAt(LocalDateTime usedAt) { this.usedAt = usedAt; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
    
    public boolean isUsed() {
        return usedAt != null;
    }
    
    public boolean isValid() {
        return !isExpired() && !isUsed();
    }
}
EOF
echo -e "${GREEN}✓${NC} PasswordResetToken.java"

cat > "$CUSTOMER_DAO/entity/auth/RefreshToken.java" << 'EOF'
package com.healthcare.customer.dao.entity.auth;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "refresh_tokens")
public class RefreshToken {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private UserAccount user;
    
    @Column(nullable = false, unique = true)
    private String token;
    
    @Column(name = "device_info")
    private String deviceInfo;
    
    @Column(name = "ip_address")
    private String ipAddress;
    
    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;
    
    @Column(name = "revoked_at")
    private LocalDateTime revokedAt;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
    
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public UserAccount getUser() { return user; }
    public void setUser(UserAccount user) { this.user = user; }
    
    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }
    
    public String getDeviceInfo() { return deviceInfo; }
    public void setDeviceInfo(String deviceInfo) { this.deviceInfo = deviceInfo; }
    
    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }
    
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    
    public LocalDateTime getRevokedAt() { return revokedAt; }
    public void setRevokedAt(LocalDateTime revokedAt) { this.revokedAt = revokedAt; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    
    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }
    
    public boolean isRevoked() {
        return revokedAt != null;
    }
    
    public boolean isValid() {
        return !isExpired() && !isRevoked();
    }
    
    public void revoke() {
        this.revokedAt = LocalDateTime.now();
    }
}
EOF
echo -e "${GREEN}✓${NC} RefreshToken.java"

# =============================================================================
# PROFILE ENTITIES
# =============================================================================

cat > "$CUSTOMER_DAO/entity/profile/Gender.java" << 'EOF'
package com.healthcare.customer.dao.entity.profile;

public enum Gender {
    MALE, FEMALE, OTHER
}
EOF
echo -e "${GREEN}✓${NC} Gender.java"

cat > "$CUSTOMER_DAO/entity/profile/Relationship.java" << 'EOF'
package com.healthcare.customer.dao.entity.profile;

public enum Relationship {
    SELF, SPOUSE, CHILD, PARENT, SIBLING, OTHER
}
EOF
echo -e "${GREEN}✓${NC} Relationship.java"

cat > "$CUSTOMER_DAO/entity/profile/ProfileStatus.java" << 'EOF'
package com.healthcare.customer.dao.entity.profile;

public enum ProfileStatus {
    ACTIVE, INACTIVE
}
EOF
echo -e "${GREEN}✓${NC} ProfileStatus.java"

cat > "$CUSTOMER_DAO/entity/profile/AddressType.java" << 'EOF'
package com.healthcare.customer.dao.entity.profile;

public enum AddressType {
    HOME, WORK, MAILING, OTHER
}
EOF
echo -e "${GREEN}✓${NC} AddressType.java"

cat > "$CUSTOMER_DAO/entity/profile/CustomerProfile.java" << 'EOF'
package com.healthcare.customer.dao.entity.profile;

import com.healthcare.customer.dao.entity.auth.UserAccount;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "customer_profiles")
public class CustomerProfile {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private UserAccount user;
    
    @Column(name = "first_name", nullable = false)
    private String firstName;
    
    @Column(name = "last_name", nullable = false)
    private String lastName;
    
    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Gender gender;
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Relationship relationship;
    
    @Column(name = "ssn_encrypted")
    private String ssnEncrypted;
    
    private String email;
    
    private String phone;
    
    @Column(name = "is_primary")
    private Boolean isPrimary = false;
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private ProfileStatus status = ProfileStatus.ACTIVE;
    
    @OneToMany(mappedBy = "profile", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    private List<ProfileAddress> addresses = new ArrayList<>();
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public UserAccount getUser() { return user; }
    public void setUser(UserAccount user) { this.user = user; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }
    
    public Gender getGender() { return gender; }
    public void setGender(Gender gender) { this.gender = gender; }
    
    public Relationship getRelationship() { return relationship; }
    public void setRelationship(Relationship relationship) { this.relationship = relationship; }
    
    public String getSsnEncrypted() { return ssnEncrypted; }
    public void setSsnEncrypted(String ssnEncrypted) { this.ssnEncrypted = ssnEncrypted; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    
    public Boolean getIsPrimary() { return isPrimary; }
    public void setIsPrimary(Boolean isPrimary) { this.isPrimary = isPrimary; }
    
    public ProfileStatus getStatus() { return status; }
    public void setStatus(ProfileStatus status) { this.status = status; }
    
    public List<ProfileAddress> getAddresses() { return addresses; }
    public void setAddresses(List<ProfileAddress> addresses) { this.addresses = addresses; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    
    public String getFullName() {
        return firstName + " " + lastName;
    }
    
    public void addAddress(ProfileAddress address) {
        addresses.add(address);
        address.setProfile(this);
    }
    
    public void removeAddress(ProfileAddress address) {
        addresses.remove(address);
        address.setProfile(null);
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerProfile.java"

cat > "$CUSTOMER_DAO/entity/profile/ProfileAddress.java" << 'EOF'
package com.healthcare.customer.dao.entity.profile;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "profile_addresses")
public class ProfileAddress {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id", nullable = false)
    private CustomerProfile profile;
    
    @Column(name = "address_type")
    @Enumerated(EnumType.STRING)
    private AddressType addressType = AddressType.HOME;
    
    @Column(nullable = false)
    private String street1;
    
    private String street2;
    
    @Column(nullable = false)
    private String city;
    
    @Column(nullable = false)
    private String state;
    
    @Column(name = "zip_code", nullable = false)
    private String zipCode;
    
    private String country = "USA";
    
    @Column(name = "is_primary")
    private Boolean isPrimary = true;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    
    public CustomerProfile getProfile() { return profile; }
    public void setProfile(CustomerProfile profile) { this.profile = profile; }
    
    public AddressType getAddressType() { return addressType; }
    public void setAddressType(AddressType addressType) { this.addressType = addressType; }
    
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
    
    public Boolean getIsPrimary() { return isPrimary; }
    public void setIsPrimary(Boolean isPrimary) { this.isPrimary = isPrimary; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
EOF
echo -e "${GREEN}✓${NC} ProfileAddress.java"

# =============================================================================
# REPOSITORIES
# =============================================================================

cat > "$CUSTOMER_DAO/repository/auth/UserAccountRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository.auth;

import com.healthcare.customer.dao.entity.auth.UserAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserAccountRepository extends JpaRepository<UserAccount, UUID> {
    Optional<UserAccount> findByEmail(String email);
    boolean existsByEmail(String email);
}
EOF
echo -e "${GREEN}✓${NC} UserAccountRepository.java"

cat > "$CUSTOMER_DAO/repository/auth/PasswordResetTokenRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository.auth;

import com.healthcare.customer.dao.entity.auth.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {
    Optional<PasswordResetToken> findByToken(String token);
    
    @Modifying
    @Query("DELETE FROM PasswordResetToken p WHERE p.user.id = :userId")
    void deleteByUserId(UUID userId);
}
EOF
echo -e "${GREEN}✓${NC} PasswordResetTokenRepository.java"

cat > "$CUSTOMER_DAO/repository/auth/RefreshTokenRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository.auth;

import com.healthcare.customer.dao.entity.auth.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findByToken(String token);
    
    @Modifying
    @Query("UPDATE RefreshToken r SET r.revokedAt = CURRENT_TIMESTAMP WHERE r.user.id = :userId AND r.revokedAt IS NULL")
    void revokeAllByUserId(UUID userId);
}
EOF
echo -e "${GREEN}✓${NC} RefreshTokenRepository.java"

cat > "$CUSTOMER_DAO/repository/profile/CustomerProfileRepository.java" << 'EOF'
package com.healthcare.customer.dao.repository.profile;

import com.healthcare.customer.dao.entity.profile.CustomerProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerProfileRepository extends JpaRepository<CustomerProfile, UUID> {
    List<CustomerProfile> findByUserIdOrderByIsPrimaryDescCreatedAtAsc(UUID userId);
    
    Optional<CustomerProfile> findByIdAndUserId(UUID id, UUID userId);
    
    @Query("SELECT COUNT(p) FROM CustomerProfile p WHERE p.user.id = :userId")
    long countByUserId(UUID userId);
    
    @Query("SELECT p FROM CustomerProfile p WHERE p.user.id = :userId AND p.isPrimary = true")
    Optional<CustomerProfile> findPrimaryByUserId(UUID userId);
    
    boolean existsByUserIdAndIsPrimaryTrue(UUID userId);
}
EOF
echo -e "${GREEN}✓${NC} CustomerProfileRepository.java"

# =============================================================================
# REMOVE OLD customer-domain DIRECTORY IF EXISTS
# =============================================================================
if [ -d "microservices/customer-onboarding-service/customer-domain" ]; then
    rm -rf "microservices/customer-onboarding-service/customer-domain"
    echo -e "${GREEN}✓${NC} Removed old customer-domain directory"
fi

echo -e "${GREEN}✓ Domain entities moved to customer-dao${NC}"