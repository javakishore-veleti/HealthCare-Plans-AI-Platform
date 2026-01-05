package com.healthcare.plans.common.dto.response;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanResponse {

    private UUID id;
    private String planCode;
    private String planName;
    private Integer year;
    private String stateCode;
    private String stateName;
    private Boolean isNational;
    private PlanType planType;
    private MetalTier metalTier;
    private BigDecimal monthlyPremium;
    private BigDecimal annualDeductible;
    private BigDecimal outOfPocketMax;
    private BigDecimal copayPrimary;
    private BigDecimal copaySpecialist;
    private BigDecimal copayEmergency;
    private Integer outOfNetworkPct;
    private PlanStatus status;
    private LocalDate effectiveDate;
    private LocalDate expirationDate;
    private Set<String> ageGroups;
    private Set<String> categories;
}
