package com.healthcare.customer.common.dto.request;

import com.healthcare.customer.common.constants.Gender;
import com.healthcare.customer.common.constants.RelationshipType;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DependentRequest {

    @NotBlank(message = "First name is required")
    @Size(max = 100)
    private String firstName;

    @Size(max = 100)
    private String middleName;

    @NotBlank(message = "Last name is required")
    @Size(max = 100)
    private String lastName;

    @NotNull(message = "Date of birth is required")
    @Past(message = "Date of birth must be in the past")
    private LocalDate dateOfBirth;

    private Gender gender;

    @NotNull(message = "Relationship is required")
    private RelationshipType relationship;

    @Size(min = 4, max = 4)
    private String ssnLast4;

    private Boolean isDisabled;

    private Boolean isStudent;
}
