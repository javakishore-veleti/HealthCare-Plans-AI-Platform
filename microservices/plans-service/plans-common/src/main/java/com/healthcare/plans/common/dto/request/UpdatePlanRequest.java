package com.healthcare.plans.common.dto.request;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdatePlanRequest {

    @Size(max = 200)
    private String planName;

    private PlanType planType;
    private MetalTier metalTier;

    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal monthlyPremium;

    @DecimalMin(value = "0.0")
    private BigDecimal annualDeductible;

    @DecimalMin(value = "0.0")
    private BigDecimal outOfPocketMax;

    private BigDecimal copayPrimary;
    private BigDecimal copaySpecialist;
    private BigDecimal copayEmergency;

    @Min(0)
    @Max(100)
    private Integer outOfNetworkPct;

    private PlanStatus status;
    private LocalDate expirationDate;

    private Set<Long> ageGroupIds;
    private Set<Long> categoryIds;
}
