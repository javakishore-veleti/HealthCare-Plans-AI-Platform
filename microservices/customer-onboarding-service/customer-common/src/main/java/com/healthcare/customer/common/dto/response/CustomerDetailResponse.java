package com.healthcare.customer.common.dto.response;

import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class CustomerDetailResponse extends CustomerResponse {

    private List<AddressResponse> addresses;
    private List<DependentResponse> dependents;
    private List<EnrollmentResponse> enrollments;
    private Integer documentCount;
}
