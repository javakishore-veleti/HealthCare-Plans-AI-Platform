package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.AddressType;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddressResponse {

    private UUID id;
    private AddressType addressType;
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String stateCode;
    private String zipCode;
    private String country;
    private Boolean isPrimary;
    private Boolean isVerified;
}
