package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "plan_inclusions", indexes = {
    @Index(name = "idx_plan_inclusions_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanInclusion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private Plan plan;

    @Column(name = "coverage_item", nullable = false, length = 100)
    private String coverageItem;

    @Column(name = "coverage_name", nullable = false, length = 200)
    private String coverageName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "copay_amount", precision = 10, scale = 2)
    private BigDecimal copayAmount;

    @Column(name = "coverage_percentage")
    private Integer coveragePercentage;

    @Column(name = "prior_auth_required", nullable = false)
    @Builder.Default
    private Boolean priorAuthRequired = false;
}
