package com.healthcare.customer.common.dto.request;

import com.healthcare.customer.common.constants.CustomerStatus;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerSearchRequest {

    private String email;
    private String phone;
    private String firstName;
    private String lastName;
    private String customerNumber;
    private CustomerStatus status;
    private String stateCode;
    private String zipCode;

    @Builder.Default
    private Integer page = 0;

    @Builder.Default
    private Integer size = 20;

    private String sortBy;
    private String sortDirection;
}
