package com.healthcare.plans.common.dto.request;

import com.healthcare.plans.common.constants.MetalTier;
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
public class CreatePlanRequest {

    @NotBlank(message = "Plan name is required")
    @Size(max = 200)
    private String planName;

    @NotNull(message = "Year is required")
    @Min(2020)
    @Max(2030)
    private Integer year;

    @Size(max = 2)
    private String stateCode;

    private Boolean isNational;

    @NotNull(message = "Plan type is required")
    private PlanType planType;

    @NotNull(message = "Metal tier is required")
    private MetalTier metalTier;

    @NotNull(message = "Monthly premium is required")
    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal monthlyPremium;

    @NotNull(message = "Annual deductible is required")
    @DecimalMin(value = "0.0")
    private BigDecimal annualDeductible;

    @NotNull(message = "Out of pocket max is required")
    @DecimalMin(value = "0.0")
    private BigDecimal outOfPocketMax;

    private BigDecimal copayPrimary;
    private BigDecimal copaySpecialist;
    private BigDecimal copayEmergency;

    @Min(0)
    @Max(100)
    private Integer outOfNetworkPct;

    @NotNull(message = "Effective date is required")
    private LocalDate effectiveDate;

    private LocalDate expirationDate;

    private Set<Long> ageGroupIds;
    private Set<Long> categoryIds;
}
