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
