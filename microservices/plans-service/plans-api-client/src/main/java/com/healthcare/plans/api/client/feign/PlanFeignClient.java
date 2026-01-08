package com.healthcare.plans.api.client.feign;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "plans-service", url = "${services.plans.url:http://localhost:8081}")
public interface PlanFeignClient extends PlanApiClient {

    @Override
    @PostMapping("/api/v1/plans")
    PlanDetailResponse createPlan(@RequestBody CreatePlanRequest request);

    @Override
    @GetMapping("/api/v1/plans/{planId}")
    PlanDetailResponse getPlanById(@PathVariable("planId") UUID planId);

    @Override
    @GetMapping("/api/v1/plans/code/{planCode}")
    PlanDetailResponse getPlanByCode(@PathVariable("planCode") String planCode);

    @Override
    @PostMapping("/api/v1/plans/search")
    PagedResponse<PlanResponse> searchPlans(@RequestBody PlanSearchRequest request);

    @Override
    @PutMapping("/api/v1/plans/{planId}")
    PlanDetailResponse updatePlan(@PathVariable("planId") UUID planId, @RequestBody UpdatePlanRequest request);

    @Override
    @DeleteMapping("/api/v1/plans/{planId}")
    void deletePlan(@PathVariable("planId") UUID planId);

    @Override
    @PostMapping("/api/v1/plans/bulk")
    List<PlanResponse> getPlansByIds(@RequestBody List<UUID> planIds);

    @Override
    @GetMapping("/api/v1/plans/{planId}/active")
    boolean isPlanActive(@PathVariable("planId") UUID planId);
}
