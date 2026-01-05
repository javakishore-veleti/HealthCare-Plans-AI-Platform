package com.healthcare.plans.common.dto.request;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import lombok.*;

import java.math.BigDecimal;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanSearchRequest {

    private Integer year;
    private String stateCode;
    private Boolean isNational;
    private Set<PlanType> planTypes;
    private Set<MetalTier> metalTiers;
    private Set<PlanStatus> statuses;
    private Set<Long> categoryIds;
    private Set<Long> ageGroupIds;

    private BigDecimal minPremium;
    private BigDecimal maxPremium;
    private BigDecimal maxDeductible;

    private String searchTerm;

    @Builder.Default
    private Integer page = 0;

    @Builder.Default
    private Integer size = 20;

    private String sortBy;
    private String sortDirection;
}
