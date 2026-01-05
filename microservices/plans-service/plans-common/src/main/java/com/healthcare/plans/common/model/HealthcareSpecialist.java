package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "healthcare_specialists", indexes = {
    @Index(name = "idx_specialists_specialty_status", columnList = "specialty_id, status"),
    @Index(name = "idx_specialists_name", columnList = "last_name, first_name")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthcareSpecialist extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "npi_number", nullable = false, unique = true, length = 20)
    private String npiNumber;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;

    @Column(name = "title", length = 20)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialty_id", nullable = false)
    private Specialty specialty;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "years_experience")
    private Integer yearsExperience;

    @Column(name = "languages", length = 200)
    private String languages;

    @Column(name = "accepting_patients", nullable = false)
    @Builder.Default
    private Boolean acceptingPatients = true;

    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private String status = "active";
}
