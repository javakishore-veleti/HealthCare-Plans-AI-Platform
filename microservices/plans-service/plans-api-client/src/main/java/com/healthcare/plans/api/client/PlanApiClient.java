package com.healthcare.plans.api.client;

import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;

import java.util.List;
import java.util.UUID;

public interface PlanApiClient {
    PlanDetailResponse createPlan(CreatePlanRequest request);
    PlanDetailResponse getPlanById(UUID planId);
    PlanDetailResponse getPlanByCode(String planCode);
    PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request);
    PlanDetailResponse updatePlan(UUID planId, UpdatePlanRequest request);
    void deletePlan(UUID planId);
    List<PlanResponse> getPlansByIds(List<UUID> planIds);
    boolean isPlanActive(UUID planId);
}
