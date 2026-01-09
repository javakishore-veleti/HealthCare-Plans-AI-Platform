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
