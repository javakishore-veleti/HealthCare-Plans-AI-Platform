package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.EnrollmentStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnrollmentResponse {

    private UUID id;
    private UUID planId;
    private String planCode;
    private String planName;
    private EnrollmentStatus status;
    private LocalDate effectiveDate;
    private LocalDate terminationDate;
    private BigDecimal monthlyPremium;
    private BigDecimal subsidyAmount;
    private BigDecimal netPremium;
    private String memberId;
    private String groupNumber;
    private Boolean includeDependents;
    private Boolean autoRenew;
}
