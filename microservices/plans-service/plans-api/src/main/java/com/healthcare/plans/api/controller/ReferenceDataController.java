package com.healthcare.plans.api.controller;

import com.healthcare.plans.api.client.ReferenceDataApiClient;
import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/reference")
@RequiredArgsConstructor
@Tag(name = "Reference Data", description = "Reference Data APIs")
public class ReferenceDataController {

    private final ReferenceDataApiClient referenceDataApiClient;

    @GetMapping("/states")
    @Operation(summary = "Get all US states")
    public ResponseEntity<List<StateResponse>> getAllStates() {
        return ResponseEntity.ok(referenceDataApiClient.getAllStates());
    }

    @GetMapping("/age-groups")
    @Operation(summary = "Get all age groups")
    public ResponseEntity<List<AgeGroupResponse>> getAllAgeGroups() {
        return ResponseEntity.ok(referenceDataApiClient.getAllAgeGroups());
    }

    @GetMapping("/categories")
    @Operation(summary = "Get all plan categories")
    public ResponseEntity<List<CategoryResponse>> getAllCategories() {
        return ResponseEntity.ok(referenceDataApiClient.getAllCategories());
    }
}
