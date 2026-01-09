package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.CustomerStatus;
import com.healthcare.customer.common.constants.Gender;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class CustomerResponse {

    private UUID id;
    private String customerNumber;
    private String firstName;
    private String middleName;
    private String lastName;
    private String fullName;
    private String email;
    private String phone;
    private String mobilePhone;
    private LocalDate dateOfBirth;
    private Gender gender;
    private String ssnLast4;
    private CustomerStatus status;
    private String preferredLanguage;
    private Boolean marketingOptIn;
    private Boolean smsOptIn;
    private Boolean emailVerified;
    private Boolean phoneVerified;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
