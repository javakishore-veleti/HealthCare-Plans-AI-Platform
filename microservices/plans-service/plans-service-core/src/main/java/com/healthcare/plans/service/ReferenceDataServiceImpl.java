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
