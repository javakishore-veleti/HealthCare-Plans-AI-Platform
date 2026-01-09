#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[4/5] Creating profile service layer...${NC}"

CUSTOMER_API="microservices/customer-onboarding-service/customer-api/src/main/java/com/healthcare/customer/api"

# Create directories
mkdir -p "$CUSTOMER_API/profile/service"
mkdir -p "$CUSTOMER_API/profile/dto"

# =============================================================================
# PROFILE DTOs
# =============================================================================
cat > "$CUSTOMER_API/profile/dto/ProfileDto.java" << 'EOF'
package com.healthcare.customer.api.profile.dto;

import com.healthcare.customer.domain.profile.entity.*;
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

import com.healthcare.customer.domain.profile.entity.ProfileAddress;

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

cat > "$CUSTOMER_API/profile/dto/CreateProfileRequest.java" << 'EOF'
package com.healthcare.customer.api.profile.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public class CreateProfileRequest {
    
    @NotBlank(message = "First name is required")
    @Size(min = 2, max = 100, message = "First name must be between 2 and 100 characters")
    private String firstName;
    
    @NotBlank(message = "Last name is required")
    @Size(min = 2, max = 100, message = "Last name must be between 2 and 100 characters")
    private String lastName;
    
    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;
    
    @NotBlank(message = "Gender is required")
    private String gender;
    
    @NotBlank(message = "Relationship is required")
    private String relationship;
    
    private String email;
    private String phone;
    private AddressDto address;
    
    // Getters and Setters
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
    
    public AddressDto getAddress() { return address; }
    public void setAddress(AddressDto address) { this.address = address; }
}
EOF
echo -e "${GREEN}✓${NC} CreateProfileRequest.java"

cat > "$CUSTOMER_API/profile/dto/UpdateProfileRequest.java" << 'EOF'
package com.healthcare.customer.api.profile.dto;

import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;
import java.time.LocalDate;

public class UpdateProfileRequest {
    
    @Size(min = 2, max = 100, message = "First name must be between 2 and 100 characters")
    private String firstName;
    
    @Size(min = 2, max = 100, message = "Last name must be between 2 and 100 characters")
    private String lastName;
    
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;
    
    private String gender;
    private String relationship;
    private String email;
    private String phone;
    private AddressDto address;
    
    // Getters and Setters
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
    
    public AddressDto getAddress() { return address; }
    public void setAddress(AddressDto address) { this.address = address; }
}
EOF
echo -e "${GREEN}✓${NC} UpdateProfileRequest.java"

# =============================================================================
# PROFILE SERVICE
# =============================================================================
cat > "$CUSTOMER_API/profile/service/ProfileService.java" << 'EOF'
package com.healthcare.customer.api.profile.service;

import com.healthcare.customer.api.profile.dto.*;
import com.healthcare.customer.domain.auth.entity.UserAccount;
import com.healthcare.customer.domain.auth.repository.UserAccountRepository;
import com.healthcare.customer.domain.profile.entity.*;
import com.healthcare.customer.domain.profile.repository.CustomerProfileRepository;
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
            // Cannot change relationship for primary profile from SELF
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
        
        // Cannot delete primary profile
        if (Boolean.TRUE.equals(profile.getIsPrimary())) {
            throw new RuntimeException("Cannot delete primary profile");
        }
        
        profileRepository.delete(profile);
    }
    
    public ProfileDto setPrimaryProfile(UUID profileId, UUID userId) {
        CustomerProfile newPrimary = profileRepository.findByIdAndUserId(profileId, userId)
            .orElseThrow(() -> new RuntimeException("Profile not found"));
        
        // Find current primary and unset it
        profileRepository.findPrimaryByUserId(userId).ifPresent(currentPrimary -> {
            currentPrimary.setIsPrimary(false);
            profileRepository.save(currentPrimary);
        });
        
        // Set new primary
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

echo -e "${GREEN}✓ Profile service layer created${NC}"