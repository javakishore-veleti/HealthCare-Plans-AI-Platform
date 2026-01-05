package com.healthcare.plans.common.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgeGroupResponse {
    private Long id;
    private String code;
    private Integer minAge;
    private Integer maxAge;
    private String displayName;
}
