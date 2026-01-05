package com.healthcare.plans.common.model;

import com.healthcare.plans.common.constants.NetworkStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "plan_providers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanProvider {

    @EmbeddedId
    private PlanProviderId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("planId")
    @JoinColumn(name = "plan_id")
    private Plan plan;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("providerId")
    @JoinColumn(name = "provider_id")
    private HealthcareProvider provider;

    @Enumerated(EnumType.STRING)
    @Column(name = "network_status", nullable = false, length = 20)
    @Builder.Default
    private NetworkStatus networkStatus = NetworkStatus.IN_NETWORK;

    @Column(name = "effective_date")
    private LocalDate effectiveDate;
}
