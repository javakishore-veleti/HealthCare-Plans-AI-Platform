package com.healthcare.customer.common.dto.request;

import com.healthcare.customer.common.constants.AddressType;
import jakarta.validation.constraints.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddressRequest {

    @NotNull(message = "Address type is required")
    private AddressType addressType;

    @NotBlank(message = "Address line 1 is required")
    @Size(max = 200)
    private String addressLine1;

    @Size(max = 200)
    private String addressLine2;

    @NotBlank(message = "City is required")
    @Size(max = 100)
    private String city;

    @NotBlank(message = "State code is required")
    @Size(min = 2, max = 2)
    private String stateCode;

    @NotBlank(message = "Zip code is required")
    @Size(max = 10)
    private String zipCode;

    @Size(max = 2)
    private String country;

    private Boolean isPrimary;
}
