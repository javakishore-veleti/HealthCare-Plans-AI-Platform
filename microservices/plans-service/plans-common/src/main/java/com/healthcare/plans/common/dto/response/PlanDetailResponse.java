package com.healthcare.plans.common.dto.response;

import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class PlanDetailResponse extends PlanResponse {

    private List<InclusionResponse> inclusions;
    private List<ExclusionResponse> exclusions;
    private Integer providerCount;
}
