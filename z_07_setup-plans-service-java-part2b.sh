#!/bin/bash

# =============================================================================
# Plans Service - Java Source Files Generator (Part 2b - Service Layer)
# =============================================================================

set -e

BASE_DIR="microservices/plans-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Plans Service - Part 2b (Service Layer)                               ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# Service Interfaces
# =============================================================================
SERVICE_DIR="$BASE_DIR/plans-service-core/src/main/java/com/healthcare/plans/service"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/PlanService.java" << 'EOF'
package com.healthcare.plans.service;

import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;

import java.util.List;
import java.util.UUID;

public interface PlanService {
    PlanDetailResponse createPlan(CreatePlanRequest request);
    PlanDetailResponse getPlanById(UUID planId);
    PlanDetailResponse getPlanByCode(String planCode);
    PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request);
    PlanDetailResponse updatePlan(UUID planId, UpdatePlanRequest request);
    void deletePlan(UUID planId);
    List<PlanResponse> getPlansByIds(List<UUID> planIds);
    boolean isPlanActive(UUID planId);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanService.java"

cat > "$SERVICE_DIR/ReferenceDataService.java" << 'EOF'
package com.healthcare.plans.service;

import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;

import java.util.List;

public interface ReferenceDataService {
    List<StateResponse> getAllStates();
    List<AgeGroupResponse> getAllAgeGroups();
    List<CategoryResponse> getAllCategories();
}
EOF
echo -e "${GREEN}✓${NC} Created: ReferenceDataService.java"

# =============================================================================
# Service Implementations
# =============================================================================
cat > "$SERVICE_DIR/PlanServiceImpl.java" << 'EOF'
package com.healthcare.plans.service;

import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import com.healthcare.plans.common.model.*;
import com.healthcare.plans.dao.repository.*;
import com.healthcare.plans.dao.specification.PlanSpecification;
import com.healthcare.plans.service.mapper.PlanMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class PlanServiceImpl implements PlanService {

    private final PlanRepository planRepository;
    private final StateRepository stateRepository;
    private final AgeGroupRepository ageGroupRepository;
    private final PlanCategoryRepository categoryRepository;
    private final PlanMapper planMapper;

    @Override
    public PlanDetailResponse createPlan(CreatePlanRequest request) {
        log.info("Creating new plan: {}", request.getPlanName());

        String planCode = generatePlanCode(request);
        if (planRepository.existsByPlanCode(planCode)) {
            throw new IllegalArgumentException("Plan with code " + planCode + " already exists");
        }

        Plan plan = planMapper.toEntity(request);
        plan.setPlanCode(planCode);

        if (!Boolean.TRUE.equals(request.getIsNational()) && StringUtils.hasText(request.getStateCode())) {
            State state = stateRepository.findById(request.getStateCode())
                .orElseThrow(() -> new IllegalArgumentException("State not found: " + request.getStateCode()));
            plan.setState(state);
        }

        if (request.getAgeGroupIds() != null && !request.getAgeGroupIds().isEmpty()) {
            Set<AgeGroup> ageGroups = new HashSet<>(ageGroupRepository.findAllById(request.getAgeGroupIds()));
            plan.setAgeGroups(ageGroups);
        }

        if (request.getCategoryIds() != null && !request.getCategoryIds().isEmpty()) {
            Set<PlanCategory> categories = new HashSet<>(categoryRepository.findAllById(request.getCategoryIds()));
            plan.setCategories(categories);
        }

        plan.setStatus(PlanStatus.ACTIVE);
        Plan savedPlan = planRepository.save(plan);
        
        log.info("Created plan with ID: {} and code: {}", savedPlan.getId(), savedPlan.getPlanCode());
        return planMapper.toDetailResponse(savedPlan);
    }

    @Override
    @Transactional(readOnly = true)
    public PlanDetailResponse getPlanById(UUID planId) {
        Plan plan = planRepository.findByIdWithDetails(planId)
            .orElseThrow(() -> new IllegalArgumentException("Plan not found: " + planId));
        return planMapper.toDetailResponse(plan);
    }

    @Override
    @Transactional(readOnly = true)
    public PlanDetailResponse getPlanByCode(String planCode) {
        Plan plan = planRepository.findByPlanCode(planCode)
            .orElseThrow(() -> new IllegalArgumentException("Plan not found: " + planCode));
        return planMapper.toDetailResponse(plan);
    }

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request) {
        Sort sort = buildSort(request.getSortBy(), request.getSortDirection());
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize(), sort);

        Page<Plan> planPage = planRepository.findAll(PlanSpecification.buildSpecification(request), pageable);

        List<PlanResponse> content = planPage.getContent().stream()
            .map(planMapper::toResponse)
            .collect(Collectors.toList());

        return PagedResponse.<PlanResponse>builder()
            .content(content)
            .page(planPage.getNumber())
            .size(planPage.getSize())
            .totalElements(planPage.getTotalElements())
            .totalPages(planPage.getTotalPages())
            .first(planPage.isFirst())
            .last(planPage.isLast())
            .build();
    }

    @Override
    public PlanDetailResponse updatePlan(UUID planId, UpdatePlanRequest request) {
        Plan plan = planRepository.findById(planId)
            .orElseThrow(() -> new IllegalArgumentException("Plan not found: " + planId));

        planMapper.updateEntity(plan, request);

        if (request.getAgeGroupIds() != null) {
            Set<AgeGroup> ageGroups = new HashSet<>(ageGroupRepository.findAllById(request.getAgeGroupIds()));
            plan.setAgeGroups(ageGroups);
        }

        if (request.getCategoryIds() != null) {
            Set<PlanCategory> categories = new HashSet<>(categoryRepository.findAllById(request.getCategoryIds()));
            plan.setCategories(categories);
        }

        Plan savedPlan = planRepository.save(plan);
        return planMapper.toDetailResponse(savedPlan);
    }

    @Override
    public void deletePlan(UUID planId) {
        Plan plan = planRepository.findById(planId)
            .orElseThrow(() -> new IllegalArgumentException("Plan not found: " + planId));
        plan.setStatus(PlanStatus.DEPRECATED);
        planRepository.save(plan);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PlanResponse> getPlansByIds(List<UUID> planIds) {
        return planRepository.findAllById(planIds).stream()
            .map(planMapper::toResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isPlanActive(UUID planId) {
        return planRepository.findById(planId)
            .map(plan -> plan.getStatus() == PlanStatus.ACTIVE)
            .orElse(false);
    }

    private String generatePlanCode(CreatePlanRequest request) {
        String tierCode = request.getMetalTier().name().substring(0, 3).toUpperCase();
        String stateCode = Boolean.TRUE.equals(request.getIsNational()) ? "NAT" : request.getStateCode();
        String sequence = String.format("%04d", System.currentTimeMillis() % 10000);
        return String.format("%s-%d-%s-%s", tierCode, request.getYear(), stateCode, sequence);
    }

    private Sort buildSort(String sortBy, String sortDirection) {
        String field = StringUtils.hasText(sortBy) ? sortBy : "createdAt";
        Sort.Direction direction = "asc".equalsIgnoreCase(sortDirection) ? Sort.Direction.ASC : Sort.Direction.DESC;
        return Sort.by(direction, field);
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanServiceImpl.java"

cat > "$SERVICE_DIR/ReferenceDataServiceImpl.java" << 'EOF'
package com.healthcare.plans.service;

import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;
import com.healthcare.plans.dao.repository.AgeGroupRepository;
import com.healthcare.plans.dao.repository.PlanCategoryRepository;
import com.healthcare.plans.dao.repository.StateRepository;
import com.healthcare.plans.service.mapper.ReferenceDataMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReferenceDataServiceImpl implements ReferenceDataService {

    private final StateRepository stateRepository;
    private final AgeGroupRepository ageGroupRepository;
    private final PlanCategoryRepository categoryRepository;
    private final ReferenceDataMapper mapper;

    @Override
    @Cacheable("states")
    public List<StateResponse> getAllStates() {
        return stateRepository.findAllByOrderByNameAsc().stream()
            .map(mapper::toStateResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Cacheable("ageGroups")
    public List<AgeGroupResponse> getAllAgeGroups() {
        return ageGroupRepository.findAllByOrderByMinAgeAsc().stream()
            .map(mapper::toAgeGroupResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Cacheable("categories")
    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAllByOrderByNameAsc().stream()
            .map(mapper::toCategoryResponse)
            .collect(Collectors.toList());
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: ReferenceDataServiceImpl.java"

# =============================================================================
# Mappers
# =============================================================================
MAPPER_DIR="$BASE_DIR/plans-service-core/src/main/java/com/healthcare/plans/service/mapper"
mkdir -p "$MAPPER_DIR"

cat > "$MAPPER_DIR/PlanMapper.java" << 'EOF'
package com.healthcare.plans.service.mapper;

import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.*;
import com.healthcare.plans.common.model.*;
import org.mapstruct.*;

import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface PlanMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "planCode", ignore = true)
    @Mapping(target = "state", ignore = true)
    @Mapping(target = "status", ignore = true)
    @Mapping(target = "ageGroups", ignore = true)
    @Mapping(target = "categories", ignore = true)
    @Mapping(target = "inclusions", ignore = true)
    @Mapping(target = "exclusions", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    Plan toEntity(CreatePlanRequest request);

    @Mapping(target = "stateCode", source = "state.code")
    @Mapping(target = "stateName", source = "state.name")
    @Mapping(target = "ageGroups", expression = "java(mapAgeGroups(plan.getAgeGroups()))")
    @Mapping(target = "categories", expression = "java(mapCategories(plan.getCategories()))")
    PlanResponse toResponse(Plan plan);

    @Mapping(target = "stateCode", source = "state.code")
    @Mapping(target = "stateName", source = "state.name")
    @Mapping(target = "ageGroups", expression = "java(mapAgeGroups(plan.getAgeGroups()))")
    @Mapping(target = "categories", expression = "java(mapCategories(plan.getCategories()))")
    @Mapping(target = "inclusions", source = "inclusions")
    @Mapping(target = "exclusions", source = "exclusions")
    @Mapping(target = "providerCount", ignore = true)
    PlanDetailResponse toDetailResponse(Plan plan);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "planCode", ignore = true)
    @Mapping(target = "year", ignore = true)
    @Mapping(target = "state", ignore = true)
    @Mapping(target = "isNational", ignore = true)
    @Mapping(target = "effectiveDate", ignore = true)
    @Mapping(target = "ageGroups", ignore = true)
    @Mapping(target = "categories", ignore = true)
    @Mapping(target = "inclusions", ignore = true)
    @Mapping(target = "exclusions", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    void updateEntity(@MappingTarget Plan plan, UpdatePlanRequest request);

    InclusionResponse toInclusionResponse(PlanInclusion inclusion);
    ExclusionResponse toExclusionResponse(PlanExclusion exclusion);

    default Set<String> mapAgeGroups(Set<AgeGroup> ageGroups) {
        if (ageGroups == null) return null;
        return ageGroups.stream().map(AgeGroup::getDisplayName).collect(Collectors.toSet());
    }

    default Set<String> mapCategories(Set<PlanCategory> categories) {
        if (categories == null) return null;
        return categories.stream().map(PlanCategory::getName).collect(Collectors.toSet());
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanMapper.java"

cat > "$MAPPER_DIR/ReferenceDataMapper.java" << 'EOF'
package com.healthcare.plans.service.mapper;

import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;
import com.healthcare.plans.common.model.AgeGroup;
import com.healthcare.plans.common.model.PlanCategory;
import com.healthcare.plans.common.model.State;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface ReferenceDataMapper {
    StateResponse toStateResponse(State state);
    AgeGroupResponse toAgeGroupResponse(AgeGroup ageGroup);
    CategoryResponse toCategoryResponse(PlanCategory category);
}
EOF
echo -e "${GREEN}✓${NC} Created: ReferenceDataMapper.java"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Part 2b Complete - Service Layer Created!                             ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run Part 2c for API-Client, API-Stub, and API layers${NC}"
