package com.healthcare.plans.api.stub;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import com.healthcare.plans.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PlanApiStubImpl implements PlanApiClient {

    private final PlanService planService;

    @Override
    public PlanDetailResponse createPlan(CreatePlanRequest request) {
        return planService.createPlan(request);
    }

    @Override
    public PlanDetailResponse getPlanById(UUID planId) {
        return planService.getPlanById(planId);
    }

    @Override
    public PlanDetailResponse getPlanByCode(String planCode) {
        return planService.getPlanByCode(planCode);
    }

    @Override
    public PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request) {
        return planService.searchPlans(request);
    }

    @Override
    public PlanDetailResponse updatePlan(UUID planId, UpdatePlanRequest request) {
        return planService.updatePlan(planId, request);
    }

    @Override
    public void deletePlan(UUID planId) {
        planService.deletePlan(planId);
    }

    @Override
    public List<PlanResponse> getPlansByIds(List<UUID> planIds) {
        return planService.getPlansByIds(planIds);
    }

    @Override
    public boolean isPlanActive(UUID planId) {
        return planService.isPlanActive(planId);
    }
}
