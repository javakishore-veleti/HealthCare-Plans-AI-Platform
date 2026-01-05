#!/bin/bash

# =============================================================================
# Plans Service - Java Source Files Generator (Part 2a - DAO Layer)
# =============================================================================

set -e

BASE_DIR="microservices/plans-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Plans Service - Part 2a (DAO Layer)                                   ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

REPO_DIR="$BASE_DIR/plans-dao/src/main/java/com/healthcare/plans/dao/repository"
mkdir -p "$REPO_DIR"

# StateRepository.java
cat > "$REPO_DIR/StateRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StateRepository extends JpaRepository<State, String> {
    List<State> findByRegion(String region);
    List<State> findAllByOrderByNameAsc();
}
EOF
echo -e "${GREEN}✓${NC} Created: StateRepository.java"

# AgeGroupRepository.java
cat > "$REPO_DIR/AgeGroupRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.AgeGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface AgeGroupRepository extends JpaRepository<AgeGroup, Long> {
    Optional<AgeGroup> findByCode(String code);
    List<AgeGroup> findAllByOrderByMinAgeAsc();
}
EOF
echo -e "${GREEN}✓${NC} Created: AgeGroupRepository.java"

# PlanCategoryRepository.java
cat > "$REPO_DIR/PlanCategoryRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.PlanCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface PlanCategoryRepository extends JpaRepository<PlanCategory, Long> {
    Optional<PlanCategory> findByCode(String code);
    List<PlanCategory> findAllByOrderByNameAsc();
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanCategoryRepository.java"

# SpecialtyRepository.java
cat > "$REPO_DIR/SpecialtyRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.Specialty;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface SpecialtyRepository extends JpaRepository<Specialty, Long> {
    Optional<Specialty> findByCode(String code);
    List<Specialty> findAllByOrderByNameAsc();
}
EOF
echo -e "${GREEN}✓${NC} Created: SpecialtyRepository.java"

# PlanRepository.java
cat > "$REPO_DIR/PlanRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.model.Plan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PlanRepository extends JpaRepository<Plan, UUID>, JpaSpecificationExecutor<Plan> {
    
    Optional<Plan> findByPlanCode(String planCode);
    
    boolean existsByPlanCode(String planCode);
    
    List<Plan> findByYearAndStatus(Integer year, PlanStatus status);
    
    @Query("SELECT p FROM Plan p WHERE p.state.code = :stateCode AND p.status = :status")
    List<Plan> findByStateAndStatus(@Param("stateCode") String stateCode, @Param("status") PlanStatus status);
    
    @Query("SELECT p FROM Plan p WHERE p.isNational = true AND p.status = :status")
    List<Plan> findNationalPlans(@Param("status") PlanStatus status);
    
    @Query("SELECT p FROM Plan p LEFT JOIN FETCH p.ageGroups LEFT JOIN FETCH p.categories WHERE p.id = :id")
    Optional<Plan> findByIdWithDetails(@Param("id") UUID id);
    
    @Query("SELECT COUNT(p) FROM Plan p WHERE p.year = :year AND p.status = :status")
    long countByYearAndStatus(@Param("year") Integer year, @Param("status") PlanStatus status);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanRepository.java"

# PlanInclusionRepository.java
cat > "$REPO_DIR/PlanInclusionRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.PlanInclusion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlanInclusionRepository extends JpaRepository<PlanInclusion, UUID> {
    List<PlanInclusion> findByPlanId(UUID planId);
    void deleteByPlanId(UUID planId);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanInclusionRepository.java"

# PlanExclusionRepository.java
cat > "$REPO_DIR/PlanExclusionRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.PlanExclusion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlanExclusionRepository extends JpaRepository<PlanExclusion, UUID> {
    List<PlanExclusion> findByPlanId(UUID planId);
    void deleteByPlanId(UUID planId);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanExclusionRepository.java"

# HealthcareProviderRepository.java
cat > "$REPO_DIR/HealthcareProviderRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.constants.ProviderType;
import com.healthcare.plans.common.model.HealthcareProvider;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface HealthcareProviderRepository extends JpaRepository<HealthcareProvider, UUID>, 
                                                      JpaSpecificationExecutor<HealthcareProvider> {
    
    Optional<HealthcareProvider> findByProviderCode(String providerCode);
    
    boolean existsByProviderCode(String providerCode);
    
    Page<HealthcareProvider> findByProviderTypeAndStatus(ProviderType providerType, String status, Pageable pageable);
    
    @Query("SELECT COUNT(p) FROM HealthcareProvider p WHERE p.status = 'active'")
    long countActiveProviders();
}
EOF
echo -e "${GREEN}✓${NC} Created: HealthcareProviderRepository.java"

# HealthcareSpecialistRepository.java
cat > "$REPO_DIR/HealthcareSpecialistRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.HealthcareSpecialist;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface HealthcareSpecialistRepository extends JpaRepository<HealthcareSpecialist, UUID>,
                                                        JpaSpecificationExecutor<HealthcareSpecialist> {
    
    Optional<HealthcareSpecialist> findByNpiNumber(String npiNumber);
    
    boolean existsByNpiNumber(String npiNumber);
    
    Page<HealthcareSpecialist> findBySpecialtyIdAndStatus(Long specialtyId, String status, Pageable pageable);
    
    @Query("SELECT COUNT(s) FROM HealthcareSpecialist s WHERE s.status = 'active'")
    long countActiveSpecialists();
}
EOF
echo -e "${GREEN}✓${NC} Created: HealthcareSpecialistRepository.java"

# PlanProviderRepository.java
cat > "$REPO_DIR/PlanProviderRepository.java" << 'EOF'
package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.constants.NetworkStatus;
import com.healthcare.plans.common.model.PlanProvider;
import com.healthcare.plans.common.model.PlanProviderId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlanProviderRepository extends JpaRepository<PlanProvider, PlanProviderId> {
    
    @Query("SELECT COUNT(pp) FROM PlanProvider pp WHERE pp.plan.id = :planId AND pp.networkStatus = 'IN_NETWORK'")
    long countInNetworkProviders(@Param("planId") UUID planId);
    
    void deleteByPlanId(UUID planId);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanProviderRepository.java"

# =============================================================================
# Specifications
# =============================================================================
echo ""
echo -e "${CYAN}  Creating Specifications...${NC}"

SPEC_DIR="$BASE_DIR/plans-dao/src/main/java/com/healthcare/plans/dao/specification"
mkdir -p "$SPEC_DIR"

cat > "$SPEC_DIR/PlanSpecification.java" << 'EOF'
package com.healthcare.plans.dao.specification;

import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.model.Plan;
import com.healthcare.plans.common.model.PlanCategory;
import com.healthcare.plans.common.model.AgeGroup;
import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

public class PlanSpecification {

    public static Specification<Plan> buildSpecification(PlanSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (request.getYear() != null) {
                predicates.add(cb.equal(root.get("year"), request.getYear()));
            }

            if (StringUtils.hasText(request.getStateCode())) {
                predicates.add(cb.or(
                    cb.equal(root.get("state").get("code"), request.getStateCode()),
                    cb.isTrue(root.get("isNational"))
                ));
            }

            if (request.getIsNational() != null && request.getIsNational()) {
                predicates.add(cb.isTrue(root.get("isNational")));
            }

            if (request.getPlanTypes() != null && !request.getPlanTypes().isEmpty()) {
                predicates.add(root.get("planType").in(request.getPlanTypes()));
            }

            if (request.getMetalTiers() != null && !request.getMetalTiers().isEmpty()) {
                predicates.add(root.get("metalTier").in(request.getMetalTiers()));
            }

            if (request.getStatuses() != null && !request.getStatuses().isEmpty()) {
                predicates.add(root.get("status").in(request.getStatuses()));
            } else {
                predicates.add(cb.equal(root.get("status"), PlanStatus.ACTIVE));
            }

            if (request.getMinPremium() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("monthlyPremium"), request.getMinPremium()));
            }
            if (request.getMaxPremium() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("monthlyPremium"), request.getMaxPremium()));
            }

            if (request.getMaxDeductible() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("annualDeductible"), request.getMaxDeductible()));
            }

            if (request.getCategoryIds() != null && !request.getCategoryIds().isEmpty()) {
                Join<Plan, PlanCategory> catJoin = root.join("categories", JoinType.INNER);
                predicates.add(catJoin.get("id").in(request.getCategoryIds()));
            }

            if (request.getAgeGroupIds() != null && !request.getAgeGroupIds().isEmpty()) {
                Join<Plan, AgeGroup> ageJoin = root.join("ageGroups", JoinType.INNER);
                predicates.add(ageJoin.get("id").in(request.getAgeGroupIds()));
            }

            if (StringUtils.hasText(request.getSearchTerm())) {
                String pattern = "%" + request.getSearchTerm().toLowerCase() + "%";
                predicates.add(cb.or(
                    cb.like(cb.lower(root.get("planName")), pattern),
                    cb.like(cb.lower(root.get("planCode")), pattern)
                ));
            }

            query.distinct(true);
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanSpecification.java"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Part 2a Complete - DAO Layer Created!                                 ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run Part 2b for Service and API layers${NC}"