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
