package com.healthcare.plans.client;

import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "plans-service", url = "${plans.service.url:http://localhost:8081}")
public interface PlanFeignClient {

    @GetMapping("/api/v1/plans/{planId}")
    PlanDetailResponse getPlanById(@PathVariable("planId") UUID planId);

    @GetMapping("/api/v1/plans/code/{planCode}")
    PlanDetailResponse getPlanByCode(@PathVariable("planCode") String planCode);

    @GetMapping("/api/v1/plans")
    PagedResponse<PlanResponse> searchPlans(
            @RequestParam(required = false) String state,
            @RequestParam(required = false) String metalTier,
            @RequestParam(required = false) Integer year,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    );

    @GetMapping("/api/v1/plans/active")
    List<PlanResponse> getActivePlans(@RequestParam(required = false) String state);
}