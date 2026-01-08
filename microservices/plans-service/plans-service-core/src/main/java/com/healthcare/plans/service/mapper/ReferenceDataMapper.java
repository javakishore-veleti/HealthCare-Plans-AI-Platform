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
