package com.healthcare.customer.common.dto.request;

import com.healthcare.customer.common.constants.Gender;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateCustomerRequest {

    @NotBlank(message = "First name is required")
    @Size(max = 100)
    private String firstName;

    @Size(max = 100)
    private String middleName;

    @NotBlank(message = "Last name is required")
    @Size(max = 100)
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    @Size(max = 200)
    private String email;

    @Size(max = 20)
    private String phone;

    @Size(max = 20)
    private String mobilePhone;

    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;

    private Gender gender;

    @Size(min = 4, max = 4)
    private String ssnLast4;

    private String preferredLanguage;

    private Boolean marketingOptIn;

    private Boolean smsOptIn;

    private AddressRequest primaryAddress;
}
