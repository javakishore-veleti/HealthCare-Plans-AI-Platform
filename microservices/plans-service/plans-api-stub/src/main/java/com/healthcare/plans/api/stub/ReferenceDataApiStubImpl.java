package com.healthcare.plans.api.stub;

import com.healthcare.plans.api.client.ReferenceDataApiClient;
import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;
import com.healthcare.plans.service.ReferenceDataService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class ReferenceDataApiStubImpl implements ReferenceDataApiClient {

    private final ReferenceDataService referenceDataService;

    @Override
    public List<StateResponse> getAllStates() {
        return referenceDataService.getAllStates();
    }

    @Override
    public List<AgeGroupResponse> getAllAgeGroups() {
        return referenceDataService.getAllAgeGroups();
    }

    @Override
    public List<CategoryResponse> getAllCategories() {
        return referenceDataService.getAllCategories();
    }
}
