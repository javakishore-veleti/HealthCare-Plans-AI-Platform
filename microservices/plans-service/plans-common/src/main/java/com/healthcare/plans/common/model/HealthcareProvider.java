package com.healthcare.plans.common.model;

import com.healthcare.plans.common.constants.NetworkTier;
import com.healthcare.plans.common.constants.ProviderType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "healthcare_providers", indexes = {
    @Index(name = "idx_providers_state_city", columnList = "state_code, city"),
    @Index(name = "idx_providers_type_status", columnList = "provider_type, status"),
    @Index(name = "idx_providers_location", columnList = "latitude, longitude")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthcareProvider extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "provider_code", nullable = false, unique = true, length = 50)
    private String providerCode;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider_type", nullable = false, length = 50)
    private ProviderType providerType;

    @Column(name = "address_line1", nullable = false, length = 200)
    private String addressLine1;

    @Column(name = "address_line2", length = 200)
    private String addressLine2;

    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_code", nullable = false)
    private State state;

    @Column(name = "zip_code", nullable = false, length = 10)
    private String zipCode;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "website", length = 200)
    private String website;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Enumerated(EnumType.STRING)
    @Column(name = "network_tier", length = 20)
    private NetworkTier networkTier;

    @Column(name = "accepting_patients", nullable = false)
    @Builder.Default
    private Boolean acceptingPatients = true;

    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private String status = "active";

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "provider_specialists",
        joinColumns = @JoinColumn(name = "provider_id"),
        inverseJoinColumns = @JoinColumn(name = "specialist_id")
    )
    @Builder.Default
    private Set<HealthcareSpecialist> specialists = new HashSet<>();
}
