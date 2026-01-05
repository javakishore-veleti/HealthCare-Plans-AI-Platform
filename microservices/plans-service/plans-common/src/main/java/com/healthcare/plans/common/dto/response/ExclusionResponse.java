package com.healthcare.plans.common.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExclusionResponse {

    private UUID id;
    private String exclusionItem;
    private String exclusionName;
    private String description;
}
