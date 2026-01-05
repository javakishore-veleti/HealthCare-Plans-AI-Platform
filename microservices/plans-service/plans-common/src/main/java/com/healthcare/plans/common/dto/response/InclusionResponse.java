package com.healthcare.plans.common.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InclusionResponse {

    private UUID id;
    private String coverageItem;
    private String coverageName;
    private String description;
    private BigDecimal copayAmount;
    private Integer coveragePercentage;
    private Boolean priorAuthRequired;
}
