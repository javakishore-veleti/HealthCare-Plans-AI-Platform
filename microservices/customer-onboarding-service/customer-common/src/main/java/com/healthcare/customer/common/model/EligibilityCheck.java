package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.EligibilityStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "eligibility_checks", indexes = {
    @Index(name = "idx_eligibility_customer_id", columnList = "customer_id"),
    @Index(name = "idx_eligibility_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EligibilityCheck extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "plan_id", nullable = false)
    private UUID planId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private EligibilityStatus status = EligibilityStatus.PENDING;

    @Column(name = "check_date", nullable = false)
    private LocalDateTime checkDate;

    @Column(name = "expiration_date")
    private LocalDateTime expirationDate;

    @Column(name = "eligibility_reason", length = 500)
    private String eligibilityReason;

    @Column(name = "income_verified", nullable = false)
    @Builder.Default
    private Boolean incomeVerified = false;

    @Column(name = "residence_verified", nullable = false)
    @Builder.Default
    private Boolean residenceVerified = false;

    @Column(name = "age_verified", nullable = false)
    @Builder.Default
    private Boolean ageVerified = false;

    @Column(name = "checked_by", length = 100)
    private String checkedBy;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;
}
