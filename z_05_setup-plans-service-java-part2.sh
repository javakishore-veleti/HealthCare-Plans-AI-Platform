#!/bin/bash

# =============================================================================
# Plans Service - Java Source Files Generator
# =============================================================================
# Generates all Java source files for plans-service modules
# =============================================================================

set -e

BASE_DIR="microservices/plans-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Plans Service - Java Source Files Generator                     ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# PLANS-COMMON: Constants (Enums)
# =============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  PLANS-COMMON: Constants${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CONSTANTS_DIR="$BASE_DIR/plans-common/src/main/java/com/healthcare/plans/common/constants"
mkdir -p "$CONSTANTS_DIR"

# PlanStatus.java
cat > "$CONSTANTS_DIR/PlanStatus.java" << 'EOF'
package com.healthcare.plans.common.constants;

public enum PlanStatus {
    ACTIVE,
    INACTIVE,
    DEPRECATED,
    PENDING_APPROVAL
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanStatus.java"

# PlanType.java
cat > "$CONSTANTS_DIR/PlanType.java" << 'EOF'
package com.healthcare.plans.common.constants;

public enum PlanType {
    HMO("Health Maintenance Organization"),
    PPO("Preferred Provider Organization"),
    EPO("Exclusive Provider Organization"),
    POS("Point of Service"),
    HDHP("High Deductible Health Plan");

    private final String description;

    PlanType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanType.java"

# MetalTier.java
cat > "$CONSTANTS_DIR/MetalTier.java" << 'EOF'
package com.healthcare.plans.common.constants;

public enum MetalTier {
    BRONZE(60),
    SILVER(70),
    GOLD(80),
    PLATINUM(90);

    private final int coveragePercentage;

    MetalTier(int coveragePercentage) {
        this.coveragePercentage = coveragePercentage;
    }

    public int getCoveragePercentage() {
        return coveragePercentage;
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: MetalTier.java"

# ProviderType.java
cat > "$CONSTANTS_DIR/ProviderType.java" << 'EOF'
package com.healthcare.plans.common.constants;

public enum ProviderType {
    HOSPITAL,
    CLINIC,
    PHARMACY,
    LAB,
    IMAGING_CENTER,
    URGENT_CARE,
    SPECIALIST_OFFICE
}
EOF
echo -e "${GREEN}✓${NC} Created: ProviderType.java"

# NetworkStatus.java
cat > "$CONSTANTS_DIR/NetworkStatus.java" << 'EOF'
package com.healthcare.plans.common.constants;

public enum NetworkStatus {
    IN_NETWORK,
    OUT_OF_NETWORK
}
EOF
echo -e "${GREEN}✓${NC} Created: NetworkStatus.java"

# NetworkTier.java
cat > "$CONSTANTS_DIR/NetworkTier.java" << 'EOF'
package com.healthcare.plans.common.constants;

public enum NetworkTier {
    TIER_1,
    TIER_2,
    TIER_3
}
EOF
echo -e "${GREEN}✓${NC} Created: NetworkTier.java"

# =============================================================================
# PLANS-COMMON: Models (JPA Entities)
# =============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  PLANS-COMMON: Models (JPA Entities)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

MODELS_DIR="$BASE_DIR/plans-common/src/main/java/com/healthcare/plans/common/model"
mkdir -p "$MODELS_DIR"

# BaseEntity.java
cat > "$MODELS_DIR/BaseEntity.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
public abstract class BaseEntity {

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
EOF
echo -e "${GREEN}✓${NC} Created: BaseEntity.java"

# State.java
cat > "$MODELS_DIR/State.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "states")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class State {

    @Id
    @Column(name = "code", length = 2)
    private String code;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "region", length = 50)
    private String region;
}
EOF
echo -e "${GREEN}✓${NC} Created: State.java"

# AgeGroup.java
cat > "$MODELS_DIR/AgeGroup.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "age_groups")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgeGroup extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 20)
    private String code;

    @Column(name = "min_age", nullable = false)
    private Integer minAge;

    @Column(name = "max_age", nullable = false)
    private Integer maxAge;

    @Column(name = "display_name", nullable = false, length = 50)
    private String displayName;
}
EOF
echo -e "${GREEN}✓${NC} Created: AgeGroup.java"

# PlanCategory.java
cat > "$MODELS_DIR/PlanCategory.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "plan_categories")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanCategory extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
    private String code;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanCategory.java"

# Specialty.java
cat > "$MODELS_DIR/Specialty.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "specialties")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Specialty extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
    private String code;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
}
EOF
echo -e "${GREEN}✓${NC} Created: Specialty.java"

# Plan.java
cat > "$MODELS_DIR/Plan.java" << 'EOF'
package com.healthcare.plans.common.model;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "plans", indexes = {
    @Index(name = "idx_plans_year_state_status", columnList = "year, state_code, status"),
    @Index(name = "idx_plans_metal_tier_type", columnList = "metal_tier, plan_type")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Plan extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "plan_code", nullable = false, unique = true, length = 50)
    private String planCode;

    @Column(name = "plan_name", nullable = false, length = 200)
    private String planName;

    @Column(name = "year", nullable = false)
    private Integer year;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_code")
    private State state;

    @Column(name = "is_national", nullable = false)
    @Builder.Default
    private Boolean isNational = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "plan_type", nullable = false, length = 20)
    private PlanType planType;

    @Enumerated(EnumType.STRING)
    @Column(name = "metal_tier", nullable = false, length = 20)
    private MetalTier metalTier;

    @Column(name = "monthly_premium", nullable = false, precision = 10, scale = 2)
    private BigDecimal monthlyPremium;

    @Column(name = "annual_deductible", nullable = false, precision = 10, scale = 2)
    private BigDecimal annualDeductible;

    @Column(name = "out_of_pocket_max", nullable = false, precision = 10, scale = 2)
    private BigDecimal outOfPocketMax;

    @Column(name = "copay_primary", precision = 10, scale = 2)
    private BigDecimal copayPrimary;

    @Column(name = "copay_specialist", precision = 10, scale = 2)
    private BigDecimal copaySpecialist;

    @Column(name = "copay_emergency", precision = 10, scale = 2)
    private BigDecimal copayEmergency;

    @Column(name = "out_of_network_pct")
    private Integer outOfNetworkPct;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private PlanStatus status = PlanStatus.ACTIVE;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "plan_age_groups",
        joinColumns = @JoinColumn(name = "plan_id"),
        inverseJoinColumns = @JoinColumn(name = "age_group_id")
    )
    @Builder.Default
    private Set<AgeGroup> ageGroups = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "plan_category_mappings",
        joinColumns = @JoinColumn(name = "plan_id"),
        inverseJoinColumns = @JoinColumn(name = "category_id")
    )
    @Builder.Default
    private Set<PlanCategory> categories = new HashSet<>();

    @OneToMany(mappedBy = "plan", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<PlanInclusion> inclusions = new HashSet<>();

    @OneToMany(mappedBy = "plan", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<PlanExclusion> exclusions = new HashSet<>();
}
EOF
echo -e "${GREEN}✓${NC} Created: Plan.java"

# PlanInclusion.java
cat > "$MODELS_DIR/PlanInclusion.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "plan_inclusions", indexes = {
    @Index(name = "idx_plan_inclusions_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanInclusion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private Plan plan;

    @Column(name = "coverage_item", nullable = false, length = 100)
    private String coverageItem;

    @Column(name = "coverage_name", nullable = false, length = 200)
    private String coverageName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "copay_amount", precision = 10, scale = 2)
    private BigDecimal copayAmount;

    @Column(name = "coverage_percentage")
    private Integer coveragePercentage;

    @Column(name = "prior_auth_required", nullable = false)
    @Builder.Default
    private Boolean priorAuthRequired = false;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanInclusion.java"

# PlanExclusion.java
cat > "$MODELS_DIR/PlanExclusion.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "plan_exclusions", indexes = {
    @Index(name = "idx_plan_exclusions_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanExclusion extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plan_id", nullable = false)
    private Plan plan;

    @Column(name = "exclusion_item", nullable = false, length = 100)
    private String exclusionItem;

    @Column(name = "exclusion_name", nullable = false, length = 200)
    private String exclusionName;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanExclusion.java"

# HealthcareProvider.java
cat > "$MODELS_DIR/HealthcareProvider.java" << 'EOF'
package com.healthcare.plans.common.model;

import com.healthcare.plans.common.constants.NetworkTier;
import com.healthcare.plans.common.constants.ProviderType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "healthcare_providers", indexes = {
    @Index(name = "idx_providers_state_city", columnList = "state_code, city"),
    @Index(name = "idx_providers_type_status", columnList = "provider_type, status"),
    @Index(name = "idx_providers_location", columnList = "latitude, longitude")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthcareProvider extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "provider_code", nullable = false, unique = true, length = 50)
    private String providerCode;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "provider_type", nullable = false, length = 50)
    private ProviderType providerType;

    @Column(name = "address_line1", nullable = false, length = 200)
    private String addressLine1;

    @Column(name = "address_line2", length = 200)
    private String addressLine2;

    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "state_code", nullable = false)
    private State state;

    @Column(name = "zip_code", nullable = false, length = 10)
    private String zipCode;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "website", length = 200)
    private String website;

    @Column(name = "latitude", precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Enumerated(EnumType.STRING)
    @Column(name = "network_tier", length = 20)
    private NetworkTier networkTier;

    @Column(name = "accepting_patients", nullable = false)
    @Builder.Default
    private Boolean acceptingPatients = true;

    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private String status = "active";

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "provider_specialists",
        joinColumns = @JoinColumn(name = "provider_id"),
        inverseJoinColumns = @JoinColumn(name = "specialist_id")
    )
    @Builder.Default
    private Set<HealthcareSpecialist> specialists = new HashSet<>();
}
EOF
echo -e "${GREEN}✓${NC} Created: HealthcareProvider.java"

# HealthcareSpecialist.java
cat > "$MODELS_DIR/HealthcareSpecialist.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "healthcare_specialists", indexes = {
    @Index(name = "idx_specialists_specialty_status", columnList = "specialty_id, status"),
    @Index(name = "idx_specialists_name", columnList = "last_name, first_name")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HealthcareSpecialist extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "npi_number", nullable = false, unique = true, length = 20)
    private String npiNumber;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;

    @Column(name = "title", length = 20)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "specialty_id", nullable = false)
    private Specialty specialty;

    @Column(name = "email", length = 200)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "years_experience")
    private Integer yearsExperience;

    @Column(name = "languages", length = 200)
    private String languages;

    @Column(name = "accepting_patients", nullable = false)
    @Builder.Default
    private Boolean acceptingPatients = true;

    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private String status = "active";
}
EOF
echo -e "${GREEN}✓${NC} Created: HealthcareSpecialist.java"

# PlanProvider.java (Join entity for Plan-Provider network)
cat > "$MODELS_DIR/PlanProvider.java" << 'EOF'
package com.healthcare.plans.common.model;

import com.healthcare.plans.common.constants.NetworkStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "plan_providers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanProvider {

    @EmbeddedId
    private PlanProviderId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("planId")
    @JoinColumn(name = "plan_id")
    private Plan plan;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("providerId")
    @JoinColumn(name = "provider_id")
    private HealthcareProvider provider;

    @Enumerated(EnumType.STRING)
    @Column(name = "network_status", nullable = false, length = 20)
    @Builder.Default
    private NetworkStatus networkStatus = NetworkStatus.IN_NETWORK;

    @Column(name = "effective_date")
    private LocalDate effectiveDate;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanProvider.java"

# PlanProviderId.java (Composite key)
cat > "$MODELS_DIR/PlanProviderId.java" << 'EOF'
package com.healthcare.plans.common.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;
import java.util.UUID;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class PlanProviderId implements Serializable {

    @Column(name = "plan_id")
    private UUID planId;

    @Column(name = "provider_id")
    private UUID providerId;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanProviderId.java"

# =============================================================================
# PLANS-COMMON: DTOs
# =============================================================================
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  PLANS-COMMON: DTOs${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

DTO_REQUEST_DIR="$BASE_DIR/plans-common/src/main/java/com/healthcare/plans/common/dto/request"
DTO_RESPONSE_DIR="$BASE_DIR/plans-common/src/main/java/com/healthcare/plans/common/dto/response"
mkdir -p "$DTO_REQUEST_DIR"
mkdir -p "$DTO_RESPONSE_DIR"

# CreatePlanRequest.java
cat > "$DTO_REQUEST_DIR/CreatePlanRequest.java" << 'EOF'
package com.healthcare.plans.common.dto.request;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanType;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreatePlanRequest {

    @NotBlank(message = "Plan name is required")
    @Size(max = 200)
    private String planName;

    @NotNull(message = "Year is required")
    @Min(2020)
    @Max(2030)
    private Integer year;

    @Size(max = 2)
    private String stateCode;

    private Boolean isNational;

    @NotNull(message = "Plan type is required")
    private PlanType planType;

    @NotNull(message = "Metal tier is required")
    private MetalTier metalTier;

    @NotNull(message = "Monthly premium is required")
    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal monthlyPremium;

    @NotNull(message = "Annual deductible is required")
    @DecimalMin(value = "0.0")
    private BigDecimal annualDeductible;

    @NotNull(message = "Out of pocket max is required")
    @DecimalMin(value = "0.0")
    private BigDecimal outOfPocketMax;

    private BigDecimal copayPrimary;
    private BigDecimal copaySpecialist;
    private BigDecimal copayEmergency;

    @Min(0)
    @Max(100)
    private Integer outOfNetworkPct;

    @NotNull(message = "Effective date is required")
    private LocalDate effectiveDate;

    private LocalDate expirationDate;

    private Set<Long> ageGroupIds;
    private Set<Long> categoryIds;
}
EOF
echo -e "${GREEN}✓${NC} Created: CreatePlanRequest.java"

# UpdatePlanRequest.java
cat > "$DTO_REQUEST_DIR/UpdatePlanRequest.java" << 'EOF'
package com.healthcare.plans.common.dto.request;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdatePlanRequest {

    @Size(max = 200)
    private String planName;

    private PlanType planType;
    private MetalTier metalTier;

    @DecimalMin(value = "0.0", inclusive = false)
    private BigDecimal monthlyPremium;

    @DecimalMin(value = "0.0")
    private BigDecimal annualDeductible;

    @DecimalMin(value = "0.0")
    private BigDecimal outOfPocketMax;

    private BigDecimal copayPrimary;
    private BigDecimal copaySpecialist;
    private BigDecimal copayEmergency;

    @Min(0)
    @Max(100)
    private Integer outOfNetworkPct;

    private PlanStatus status;
    private LocalDate expirationDate;

    private Set<Long> ageGroupIds;
    private Set<Long> categoryIds;
}
EOF
echo -e "${GREEN}✓${NC} Created: UpdatePlanRequest.java"

# PlanSearchRequest.java
cat > "$DTO_REQUEST_DIR/PlanSearchRequest.java" << 'EOF'
package com.healthcare.plans.common.dto.request;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import lombok.*;

import java.math.BigDecimal;
import java.util.Set;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanSearchRequest {

    private Integer year;
    private String stateCode;
    private Boolean isNational;
    private Set<PlanType> planTypes;
    private Set<MetalTier> metalTiers;
    private Set<PlanStatus> statuses;
    private Set<Long> categoryIds;
    private Set<Long> ageGroupIds;

    private BigDecimal minPremium;
    private BigDecimal maxPremium;
    private BigDecimal maxDeductible;

    private String searchTerm;

    @Builder.Default
    private Integer page = 0;

    @Builder.Default
    private Integer size = 20;

    private String sortBy;
    private String sortDirection;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanSearchRequest.java"

# PlanResponse.java
cat > "$DTO_RESPONSE_DIR/PlanResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import com.healthcare.plans.common.constants.MetalTier;
import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.constants.PlanType;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Set;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanResponse {

    private UUID id;
    private String planCode;
    private String planName;
    private Integer year;
    private String stateCode;
    private String stateName;
    private Boolean isNational;
    private PlanType planType;
    private MetalTier metalTier;
    private BigDecimal monthlyPremium;
    private BigDecimal annualDeductible;
    private BigDecimal outOfPocketMax;
    private BigDecimal copayPrimary;
    private BigDecimal copaySpecialist;
    private BigDecimal copayEmergency;
    private Integer outOfNetworkPct;
    private PlanStatus status;
    private LocalDate effectiveDate;
    private LocalDate expirationDate;
    private Set<String> ageGroups;
    private Set<String> categories;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanResponse.java"

# PlanDetailResponse.java
cat > "$DTO_RESPONSE_DIR/PlanDetailResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanDetailResponse extends PlanResponse {

    private List<InclusionResponse> inclusions;
    private List<ExclusionResponse> exclusions;
    private Integer providerCount;
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanDetailResponse.java"

# InclusionResponse.java
cat > "$DTO_RESPONSE_DIR/InclusionResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InclusionResponse {

    private UUID id;
    private String coverageItem;
    private String coverageName;
    private String description;
    private BigDecimal copayAmount;
    private Integer coveragePercentage;
    private Boolean priorAuthRequired;
}
EOF
echo -e "${GREEN}✓${NC} Created: InclusionResponse.java"

# ExclusionResponse.java
cat > "$DTO_RESPONSE_DIR/ExclusionResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExclusionResponse {

    private UUID id;
    private String exclusionItem;
    private String exclusionName;
    private String description;
}
EOF
echo -e "${GREEN}✓${NC} Created: ExclusionResponse.java"

# PagedResponse.java
cat > "$DTO_RESPONSE_DIR/PagedResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

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
echo -e "${GREEN}✓${NC} Created: PagedResponse.java"

# StateResponse.java
cat > "$DTO_RESPONSE_DIR/StateResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StateResponse {
    private String code;
    private String name;
    private String region;
}
EOF
echo -e "${GREEN}✓${NC} Created: StateResponse.java"

# AgeGroupResponse.java
cat > "$DTO_RESPONSE_DIR/AgeGroupResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgeGroupResponse {
    private Long id;
    private String code;
    private Integer minAge;
    private Integer maxAge;
    private String displayName;
}
EOF
echo -e "${GREEN}✓${NC} Created: AgeGroupResponse.java"

# CategoryResponse.java
cat > "$DTO_RESPONSE_DIR/CategoryResponse.java" << 'EOF'
package com.healthcare.plans.common.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryResponse {
    private Long id;
    private String code;
    private String name;
    private String description;
}
EOF
echo -e "${GREEN}✓${NC} Created: CategoryResponse.java"

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Plans Service - Java Source Files Generated!                    ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}plans-common/constants:${NC}"
echo -e "  ✓ PlanStatus, PlanType, MetalTier"
echo -e "  ✓ ProviderType, NetworkStatus, NetworkTier"
echo ""
echo -e "${YELLOW}plans-common/model:${NC}"
echo -e "  ✓ BaseEntity, State, AgeGroup, PlanCategory, Specialty"
echo -e "  ✓ Plan, PlanInclusion, PlanExclusion"
echo -e "  ✓ HealthcareProvider, HealthcareSpecialist"
echo -e "  ✓ PlanProvider, PlanProviderId"
echo ""
echo -e "${YELLOW}plans-common/dto/request:${NC}"
echo -e "  ✓ CreatePlanRequest, UpdatePlanRequest, PlanSearchRequest"
echo ""
echo -e "${YELLOW}plans-common/dto/response:${NC}"
echo -e "  ✓ PlanResponse, PlanDetailResponse"
echo -e "  ✓ InclusionResponse, ExclusionResponse"
echo -e "  ✓ PagedResponse, StateResponse, AgeGroupResponse, CategoryResponse"
echo ""
echo -e "${YELLOW}Next: Run Part 2 script for DAO, Service, API-Client, API-Stub, API layers${NC}"
echo ""