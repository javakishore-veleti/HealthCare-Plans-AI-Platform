#!/bin/bash

# =============================================================================
# Customer Onboarding Service - Java Source Files Generator (Part 1)
# =============================================================================
# Creates: Constants, Models (Entities), DTOs
# =============================================================================

set -e

BASE_DIR="microservices/customer-onboarding-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Customer Onboarding Service - Part 1 (Constants, Entities, DTOs)         ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# CONSTANTS
# =============================================================================
echo -e "${CYAN}Creating Constants...${NC}"

CONSTANTS_DIR="$BASE_DIR/customer-common/src/main/java/com/healthcare/customer/common/constants"
mkdir -p "$CONSTANTS_DIR"

cat > "$CONSTANTS_DIR/CustomerStatus.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum CustomerStatus {
    PENDING,
    ACTIVE,
    SUSPENDED,
    INACTIVE,
    TERMINATED
}
EOF
echo -e "${GREEN}✓${NC} CustomerStatus.java"

cat > "$CONSTANTS_DIR/Gender.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum Gender {
    MALE,
    FEMALE,
    OTHER,
    PREFER_NOT_TO_SAY
}
EOF
echo -e "${GREEN}✓${NC} Gender.java"

cat > "$CONSTANTS_DIR/RelationshipType.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum RelationshipType {
    SPOUSE,
    CHILD,
    DOMESTIC_PARTNER,
    PARENT,
    OTHER
}
EOF
echo -e "${GREEN}✓${NC} RelationshipType.java"

cat > "$CONSTANTS_DIR/AddressType.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum AddressType {
    HOME,
    MAILING,
    WORK,
    BILLING
}
EOF
echo -e "${GREEN}✓${NC} AddressType.java"

cat > "$CONSTANTS_DIR/DocumentType.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum DocumentType {
    ID_CARD,
    DRIVERS_LICENSE,
    PASSPORT,
    BIRTH_CERTIFICATE,
    SOCIAL_SECURITY_CARD,
    PROOF_OF_INCOME,
    PROOF_OF_ADDRESS,
    INSURANCE_CARD,
    OTHER
}
EOF
echo -e "${GREEN}✓${NC} DocumentType.java"

cat > "$CONSTANTS_DIR/DocumentStatus.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum DocumentStatus {
    PENDING,
    VERIFIED,
    REJECTED,
    EXPIRED
}
EOF
echo -e "${GREEN}✓${NC} DocumentStatus.java"

cat > "$CONSTANTS_DIR/EligibilityStatus.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum EligibilityStatus {
    PENDING,
    ELIGIBLE,
    NOT_ELIGIBLE,
    NEEDS_REVIEW,
    EXPIRED
}
EOF
echo -e "${GREEN}✓${NC} EligibilityStatus.java"

cat > "$CONSTANTS_DIR/EnrollmentStatus.java" << 'EOF'
package com.healthcare.customer.common.constants;

public enum EnrollmentStatus {
    PENDING,
    ENROLLED,
    CANCELLED,
    EXPIRED,
    TERMINATED
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentStatus.java"

# =============================================================================
# MODELS (ENTITIES)
# =============================================================================
echo ""
echo -e "${CYAN}Creating Entities...${NC}"

MODELS_DIR="$BASE_DIR/customer-common/src/main/java/com/healthcare/customer/common/model"
mkdir -p "$MODELS_DIR"

cat > "$MODELS_DIR/BaseEntity.java" << 'EOF'
package com.healthcare.customer.common.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
public abstract class BaseEntity {

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
EOF
echo -e "${GREEN}✓${NC} BaseEntity.java"

cat > "$MODELS_DIR/Customer.java" << 'EOF'
package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.CustomerStatus;
import com.healthcare.customer.common.constants.Gender;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "customers", indexes = {
    @Index(name = "idx_customers_email", columnList = "email"),
    @Index(name = "idx_customers_ssn_last4", columnList = "ssn_last4"),
    @Index(name = "idx_customers_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Customer extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "customer_number", nullable = false, unique = true, length = 20)
    private String customerNumber;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "middle_name", length = 100)
    private String middleName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;

    @Column(name = "email", nullable = false, unique = true, length = 200)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "mobile_phone", length = 20)
    private String mobilePhone;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender", length = 20)
    private Gender gender;

    @Column(name = "ssn_last4", length = 4)
    private String ssnLast4;

    @Column(name = "ssn_encrypted", length = 500)
    private String ssnEncrypted;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private CustomerStatus status = CustomerStatus.PENDING;

    @Column(name = "preferred_language", length = 10)
    @Builder.Default
    private String preferredLanguage = "en";

    @Column(name = "marketing_opt_in", nullable = false)
    @Builder.Default
    private Boolean marketingOptIn = false;

    @Column(name = "sms_opt_in", nullable = false)
    @Builder.Default
    private Boolean smsOptIn = false;

    @Column(name = "email_verified", nullable = false)
    @Builder.Default
    private Boolean emailVerified = false;

    @Column(name = "phone_verified", nullable = false)
    @Builder.Default
    private Boolean phoneVerified = false;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Address> addresses = new HashSet<>();

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Dependent> dependents = new HashSet<>();

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<CustomerDocument> documents = new HashSet<>();

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<CustomerPlanEnrollment> enrollments = new HashSet<>();

    public String getFullName() {
        if (middleName != null && !middleName.isEmpty()) {
            return firstName + " " + middleName + " " + lastName;
        }
        return firstName + " " + lastName;
    }
}
EOF
echo -e "${GREEN}✓${NC} Customer.java"

cat > "$MODELS_DIR/Address.java" << 'EOF'
package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.AddressType;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "customer_addresses", indexes = {
    @Index(name = "idx_addresses_customer_id", columnList = "customer_id"),
    @Index(name = "idx_addresses_zip_code", columnList = "zip_code")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Address extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Enumerated(EnumType.STRING)
    @Column(name = "address_type", nullable = false, length = 20)
    private AddressType addressType;

    @Column(name = "address_line1", nullable = false, length = 200)
    private String addressLine1;

    @Column(name = "address_line2", length = 200)
    private String addressLine2;

    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @Column(name = "state_code", nullable = false, length = 2)
    private String stateCode;

    @Column(name = "zip_code", nullable = false, length = 10)
    private String zipCode;

    @Column(name = "country", nullable = false, length = 2)
    @Builder.Default
    private String country = "US";

    @Column(name = "is_primary", nullable = false)
    @Builder.Default
    private Boolean isPrimary = false;

    @Column(name = "is_verified", nullable = false)
    @Builder.Default
    private Boolean isVerified = false;
}
EOF
echo -e "${GREEN}✓${NC} Address.java"

cat > "$MODELS_DIR/Dependent.java" << 'EOF'
package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.Gender;
import com.healthcare.customer.common.constants.RelationshipType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "customer_dependents", indexes = {
    @Index(name = "idx_dependents_customer_id", columnList = "customer_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Dependent extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "middle_name", length = 100)
    private String middleName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;

    @Column(name = "date_of_birth", nullable = false)
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(name = "gender", length = 20)
    private Gender gender;

    @Enumerated(EnumType.STRING)
    @Column(name = "relationship", nullable = false, length = 20)
    private RelationshipType relationship;

    @Column(name = "ssn_last4", length = 4)
    private String ssnLast4;

    @Column(name = "is_disabled", nullable = false)
    @Builder.Default
    private Boolean isDisabled = false;

    @Column(name = "is_student", nullable = false)
    @Builder.Default
    private Boolean isStudent = false;

    public String getFullName() {
        if (middleName != null && !middleName.isEmpty()) {
            return firstName + " " + middleName + " " + lastName;
        }
        return firstName + " " + lastName;
    }
}
EOF
echo -e "${GREEN}✓${NC} Dependent.java"

cat > "$MODELS_DIR/CustomerDocument.java" << 'EOF'
package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.DocumentStatus;
import com.healthcare.customer.common.constants.DocumentType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "customer_documents", indexes = {
    @Index(name = "idx_documents_customer_id", columnList = "customer_id"),
    @Index(name = "idx_documents_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerDocument extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Enumerated(EnumType.STRING)
    @Column(name = "document_type", nullable = false, length = 30)
    private DocumentType documentType;

    @Column(name = "document_name", nullable = false, length = 200)
    private String documentName;

    @Column(name = "file_path", length = 500)
    private String filePath;

    @Column(name = "file_size")
    private Long fileSize;

    @Column(name = "mime_type", length = 100)
    private String mimeType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private DocumentStatus status = DocumentStatus.PENDING;

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @Column(name = "verified_by", length = 100)
    private String verifiedBy;

    @Column(name = "rejection_reason", length = 500)
    private String rejectionReason;
}
EOF
echo -e "${GREEN}✓${NC} CustomerDocument.java"

cat > "$MODELS_DIR/EligibilityCheck.java" << 'EOF'
package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.EligibilityStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "eligibility_checks", indexes = {
    @Index(name = "idx_eligibility_customer_id", columnList = "customer_id"),
    @Index(name = "idx_eligibility_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EligibilityCheck extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "plan_id", nullable = false)
    private UUID planId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private EligibilityStatus status = EligibilityStatus.PENDING;

    @Column(name = "check_date", nullable = false)
    private LocalDateTime checkDate;

    @Column(name = "expiration_date")
    private LocalDateTime expirationDate;

    @Column(name = "eligibility_reason", length = 500)
    private String eligibilityReason;

    @Column(name = "income_verified", nullable = false)
    @Builder.Default
    private Boolean incomeVerified = false;

    @Column(name = "residence_verified", nullable = false)
    @Builder.Default
    private Boolean residenceVerified = false;

    @Column(name = "age_verified", nullable = false)
    @Builder.Default
    private Boolean ageVerified = false;

    @Column(name = "checked_by", length = 100)
    private String checkedBy;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;
}
EOF
echo -e "${GREEN}✓${NC} EligibilityCheck.java"

cat > "$MODELS_DIR/CustomerPlanEnrollment.java" << 'EOF'
package com.healthcare.customer.common.model;

import com.healthcare.customer.common.constants.EnrollmentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "customer_plan_enrollments", indexes = {
    @Index(name = "idx_enrollments_customer_id", columnList = "customer_id"),
    @Index(name = "idx_enrollments_plan_id", columnList = "plan_id"),
    @Index(name = "idx_enrollments_status", columnList = "status")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerPlanEnrollment extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(name = "plan_id", nullable = false)
    private UUID planId;

    @Column(name = "plan_code", nullable = false, length = 50)
    private String planCode;

    @Column(name = "plan_name", nullable = false, length = 200)
    private String planName;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private EnrollmentStatus status = EnrollmentStatus.PENDING;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;

    @Column(name = "termination_date")
    private LocalDate terminationDate;

    @Column(name = "monthly_premium", precision = 10, scale = 2)
    private BigDecimal monthlyPremium;

    @Column(name = "subsidy_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal subsidyAmount = BigDecimal.ZERO;

    @Column(name = "member_id", length = 50)
    private String memberId;

    @Column(name = "group_number", length = 50)
    private String groupNumber;

    @Column(name = "include_dependents", nullable = false)
    @Builder.Default
    private Boolean includeDependents = false;

    @Column(name = "auto_renew", nullable = false)
    @Builder.Default
    private Boolean autoRenew = true;

    @Column(name = "cancellation_reason", length = 500)
    private String cancellationReason;
}
EOF
echo -e "${GREEN}✓${NC} CustomerPlanEnrollment.java"

# =============================================================================
# DTOs
# =============================================================================
echo ""
echo -e "${CYAN}Creating DTOs...${NC}"

DTO_REQUEST_DIR="$BASE_DIR/customer-common/src/main/java/com/healthcare/customer/common/dto/request"
DTO_RESPONSE_DIR="$BASE_DIR/customer-common/src/main/java/com/healthcare/customer/common/dto/response"
mkdir -p "$DTO_REQUEST_DIR"
mkdir -p "$DTO_RESPONSE_DIR"

# Request DTOs
cat > "$DTO_REQUEST_DIR/CreateCustomerRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} CreateCustomerRequest.java"

cat > "$DTO_REQUEST_DIR/UpdateCustomerRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} UpdateCustomerRequest.java"

cat > "$DTO_REQUEST_DIR/AddressRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} AddressRequest.java"

cat > "$DTO_REQUEST_DIR/DependentRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} DependentRequest.java"

cat > "$DTO_REQUEST_DIR/EnrollmentRequest.java" << 'EOF'
package com.healthcare.customer.common.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EnrollmentRequest {

    @NotNull(message = "Plan ID is required")
    private UUID planId;

    @NotNull(message = "Effective date is required")
    @FutureOrPresent(message = "Effective date must be today or in the future")
    private LocalDate effectiveDate;

    private Boolean includeDependents;

    private Boolean autoRenew;
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentRequest.java"

cat > "$DTO_REQUEST_DIR/CustomerSearchRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} CustomerSearchRequest.java"

# Response DTOs
cat > "$DTO_RESPONSE_DIR/CustomerResponse.java" << 'EOF'
package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.CustomerStatus;
import com.healthcare.customer.common.constants.Gender;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
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
EOF
echo -e "${GREEN}✓${NC} CustomerResponse.java"

cat > "$DTO_RESPONSE_DIR/CustomerDetailResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} CustomerDetailResponse.java"

cat > "$DTO_RESPONSE_DIR/AddressResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} AddressResponse.java"

cat > "$DTO_RESPONSE_DIR/DependentResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} DependentResponse.java"

cat > "$DTO_RESPONSE_DIR/EnrollmentResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} EnrollmentResponse.java"

cat > "$DTO_RESPONSE_DIR/EligibilityResponse.java" << 'EOF'
package com.healthcare.customer.common.dto.response;

import com.healthcare.customer.common.constants.EligibilityStatus;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EligibilityResponse {

    private UUID id;
    private UUID customerId;
    private UUID planId;
    private EligibilityStatus status;
    private LocalDateTime checkDate;
    private LocalDateTime expirationDate;
    private String eligibilityReason;
    private Boolean incomeVerified;
    private Boolean residenceVerified;
    private Boolean ageVerified;
}
EOF
echo -e "${GREEN}✓${NC} EligibilityResponse.java"

cat > "$DTO_RESPONSE_DIR/PagedResponse.java" << 'EOF'
package com.healthcare.customer.common.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PagedResponse<T> {

    private List<T> content;
    private Integer page;
    private Integer size;
    private Long totalElements;
    private Integer totalPages;
    private Boolean first;
    private Boolean last;
}
EOF
echo -e "${GREEN}✓${NC} PagedResponse.java"

# Fix CustomerResponse to use @SuperBuilder for inheritance
cat > "$DTO_RESPONSE_DIR/CustomerResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} CustomerResponse.java (fixed with @SuperBuilder)"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Part 1 Complete - Constants, Entities, DTOs Created!                     ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run setup-customer-service-java-part2.sh${NC}"