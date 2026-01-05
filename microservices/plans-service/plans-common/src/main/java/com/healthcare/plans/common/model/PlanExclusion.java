package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "plan_exclusions", indexes = {
    @Index(name = "idx_plan_exclusions_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanExclusion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private Plan plan;

    @Column(name = "exclusion_item", nullable = false, length = 100)
    private String exclusionItem;

    @Column(name = "exclusion_name", nullable = false, length = 200)
    private String exclusionName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
}
