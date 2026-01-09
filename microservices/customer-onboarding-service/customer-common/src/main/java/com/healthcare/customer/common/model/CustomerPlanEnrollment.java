package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.EnrollmentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "customer_plan_enrollments", indexes = {
    @Index(name = "idx_enrollments_customer_id", columnList = "customer_id"),
    @Index(name = "idx_enrollments_plan_id", columnList = "plan_id"),
    @Index(name = "idx_enrollments_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerPlanEnrollment extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "plan_id", nullable = false)
    private UUID planId;

    @Column(name = "plan_code", nullable = false, length = 50)
    private String planCode;

    @Column(name = "plan_name", nullable = false, length = 200)
    private String planName;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private EnrollmentStatus status = EnrollmentStatus.PENDING;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;

    @Column(name = "termination_date")
    private LocalDate terminationDate;

    @Column(name = "monthly_premium", precision = 10, scale = 2)
    private BigDecimal monthlyPremium;

    @Column(name = "subsidy_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal subsidyAmount = BigDecimal.ZERO;

    @Column(name = "member_id", length = 50)
    private String memberId;

    @Column(name = "group_number", length = 50)
    private String groupNumber;

    @Column(name = "include_dependents", nullable = false)
    @Builder.Default
    private Boolean includeDependents = false;

    @Column(name = "auto_renew", nullable = false)
    @Builder.Default
    private Boolean autoRenew = true;

    @Column(name = "cancellation_reason", length = 500)
    private String cancellationReason;
}
