package com.healthcare.plans.service.mapper;

import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.*;
import com.healthcare.plans.common.model.*;
import org.mapstruct.*;

import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
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