package com.healthcare.customer.common.dto.request;

import com.healthcare.customer.common.constants.Gender;
import jakarta.validation.constraints.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateCustomerRequest {

    @Size(max = 100)
    private String firstName;

    @Size(max = 100)
    private String middleName;

    @Size(max = 100)
    private String lastName;

    @Email(message = "Invalid email format")
    @Size(max = 200)
    private String email;

    @Size(max = 20)
    private String phone;

    @Size(max = 20)
    private String mobilePhone;

    private Gender gender;

    private String preferredLanguage;

    private Boolean marketingOptIn;

    private Boolean smsOptIn;
}
