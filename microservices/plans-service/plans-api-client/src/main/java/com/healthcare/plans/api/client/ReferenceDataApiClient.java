package com.healthcare.plans.api.client;

import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;

import java.util.List;

public interface ReferenceDataApiClient {
    List<StateResponse> getAllStates();
    List<AgeGroupResponse> getAllAgeGroups();
    List<CategoryResponse> getAllCategories();
}
