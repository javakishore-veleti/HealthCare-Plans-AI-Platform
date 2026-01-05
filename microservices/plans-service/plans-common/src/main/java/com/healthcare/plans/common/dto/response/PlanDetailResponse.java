package com.healthcare.plans.common.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanDetailResponse extends PlanResponse {

    private List<InclusionResponse> inclusions;
    private List<ExclusionResponse> exclusions;
    private Integer providerCount;
}
