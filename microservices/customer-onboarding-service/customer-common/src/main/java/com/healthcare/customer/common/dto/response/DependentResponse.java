package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.Gender;
import com.healthcare.customer.common.constants.RelationshipType;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DependentResponse {

    private UUID id;
    private String firstName;
    private String middleName;
    private String lastName;
    private String fullName;
    private LocalDate dateOfBirth;
    private Gender gender;
    private RelationshipType relationship;
    private Boolean isDisabled;
    private Boolean isStudent;
}
