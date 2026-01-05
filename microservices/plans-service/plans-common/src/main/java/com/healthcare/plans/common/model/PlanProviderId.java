package com.healthcare.plans.common.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;
import java.util.UUID;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class PlanProviderId implements Serializable {

    @Column(name = "plan_id")
    private UUID planId;

    @Column(name = "provider_id")
    private UUID providerId;
}
