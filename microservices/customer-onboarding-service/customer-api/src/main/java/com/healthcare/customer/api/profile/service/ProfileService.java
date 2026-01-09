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
            CustomerProfile finalProfile = profile;
            ProfileAddress address = profile.getAddresses().stream()
                .filter(a -> Boolean.TRUE.equals(a.getIsPrimary()))
                .findFirst()
                .orElseGet(() -> {
                    ProfileAddress newAddr = new ProfileAddress();
                    newAddr.setIsPrimary(true);
                    finalProfile.addAddress(newAddr);
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
