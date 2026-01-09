package com.healthcare.plans.api.controller;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/plans")
@RequiredArgsConstructor
@Tag(name = "Plans", description = "Healthcare Plan Management APIs")
public class PlanController {

    private final PlanApiClient planApiClient;

    @PostMapping
    @Operation(summary = "Create a new plan")
    public ResponseEntity<PlanDetailResponse> createPlan(@Valid @RequestBody CreatePlanRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(planApiClient.createPlan(request));
    }

    @PostMapping("/search")
    @Operation(summary = "Search plans with filters")
    public ResponseEntity<PagedResponse<PlanResponse>> searchPlans(@RequestBody PlanSearchRequest request) {
        return ResponseEntity.ok(planApiClient.searchPlans(request));
    }

    @PostMapping("/bulk")
    @Operation(summary = "Get plans by IDs")
    public ResponseEntity<List<PlanResponse>> getPlansByIds(@RequestBody List<UUID> planIds) {
        return ResponseEntity.ok(planApiClient.getPlansByIds(planIds));
    }

    @GetMapping("/code/{planCode}")
    @Operation(summary = "Get plan by code")
    public ResponseEntity<PlanDetailResponse> getPlanByCode(@PathVariable String planCode) {
        return ResponseEntity.ok(planApiClient.getPlanByCode(planCode));
    }

    // UUID regex pattern to prevent matching non-UUID paths like "search"
    @GetMapping("/{planId:[0-9a-fA-F-]{36}}")
    @Operation(summary = "Get plan by ID")
    public ResponseEntity<PlanDetailResponse> getPlanById(@PathVariable UUID planId) {
        return ResponseEntity.ok(planApiClient.getPlanById(planId));
    }

    @PutMapping("/{planId:[0-9a-fA-F-]{36}}")
    @Operation(summary = "Update a plan")
    public ResponseEntity<PlanDetailResponse> updatePlan(@PathVariable UUID planId, @Valid @RequestBody UpdatePlanRequest request) {
        return ResponseEntity.ok(planApiClient.updatePlan(planId, request));
    }

    @DeleteMapping("/{planId:[0-9a-fA-F-]{36}}")
    @Operation(summary = "Delete a plan (soft delete)")
    public ResponseEntity<Void> deletePlan(@PathVariable UUID planId) {
        planApiClient.deletePlan(planId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{planId:[0-9a-fA-F-]{36}}/active")
    @Operation(summary = "Check if plan is active")
    public ResponseEntity<Boolean> isPlanActive(@PathVariable UUID planId) {
        return ResponseEntity.ok(planApiClient.isPlanActive(planId));
    }
}