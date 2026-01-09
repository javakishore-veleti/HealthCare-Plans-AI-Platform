package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.EligibilityStatus;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EligibilityResponse {

    private UUID id;
    private UUID customerId;
    private UUID planId;
    private EligibilityStatus status;
    private LocalDateTime checkDate;
    private LocalDateTime expirationDate;
    private String eligibilityReason;
    private Boolean incomeVerified;
    private Boolean residenceVerified;
    private Boolean ageVerified;
}
