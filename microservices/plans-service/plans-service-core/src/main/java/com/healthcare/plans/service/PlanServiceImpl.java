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
