package com.healthcare.plans.common.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StateResponse {
    private String code;
    private String name;
    private String region;
}
