package com.healthcare.plans.common.model;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "plans", indexes = {
    @Index(name = "idx_plans_year_state_status", columnList = "year, state_code, status"),
    @Index(name = "idx_plans_metal_tier_type", columnList = "metal_tier, plan_type")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Plan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "plan_code", nullable = false, unique = true, length = 50)
    private String planCode;

    @Column(name = "plan_name", nullable = false, length = 200)
    private String planName;

    @Column(name = "year", nullable = false)
    private Integer year;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_code")
    private State state;

    @Column(name = "is_national", nullable = false)
    @Builder.Default
    private Boolean isNational = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "plan_type", nullable = false, length = 20)
    private PlanType planType;

    @Enumerated(EnumType.STRING)
    @Column(name = "metal_tier", nullable = false, length = 20)
    private MetalTier metalTier;

    @Column(name = "monthly_premium", nullable = false, precision = 10, scale = 2)
    private BigDecimal monthlyPremium;

    @Column(name = "annual_deductible", nullable = false, precision = 10, scale = 2)
    private BigDecimal annualDeductible;

    @Column(name = "out_of_pocket_max", nullable = false, precision = 10, scale = 2)
    private BigDecimal outOfPocketMax;

    @Column(name = "copay_primary", precision = 10, scale = 2)
    private BigDecimal copayPrimary;

    @Column(name = "copay_specialist", precision = 10, scale = 2)
    private BigDecimal copaySpecialist;

    @Column(name = "copay_emergency", precision = 10, scale = 2)
    private BigDecimal copayEmergency;

    @Column(name = "out_of_network_pct")
    private Integer outOfNetworkPct;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private PlanStatus status = PlanStatus.ACTIVE;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "plan_age_groups",
        joinColumns = @JoinColumn(name = "plan_id"),
        inverseJoinColumns = @JoinColumn(name = "age_group_id")
    )
    @Builder.Default
    private Set<AgeGroup> ageGroups = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "plan_category_mappings",
        joinColumns = @JoinColumn(name = "plan_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    @Builder.Default
    private Set<PlanCategory> categories = new HashSet<>();

    @OneToMany(mappedBy = "plan", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<PlanInclusion> inclusions = new HashSet<>();

    @OneToMany(mappedBy = "plan", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<PlanExclusion> exclusions = new HashSet<>();
}
