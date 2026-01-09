package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.DependentRequest;
import com.healthcare.customer.common.dto.response.DependentResponse;
import com.healthcare.customer.service.DependentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/customers/{customerId}/dependents")
@RequiredArgsConstructor
@Tag(name = "Dependent", description = "Customer dependent management APIs")
public class DependentController {

    private final DependentService dependentService;

    @PostMapping
    @Operation(summary = "Add dependent", description = "Add a new dependent for a customer")
    public ResponseEntity<DependentResponse> addDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody DependentRequest request) {
        DependentResponse response = dependentService.addDependent(customerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "Get dependents", description = "Get all dependents for a customer")
    public ResponseEntity<List<DependentResponse>> getDependents(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<DependentResponse> responses = dependentService.getCustomerDependents(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{dependentId}")
    @Operation(summary = "Get dependent", description = "Get a specific dependent")
    public ResponseEntity<DependentResponse> getDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Dependent UUID") @PathVariable UUID dependentId) {
        DependentResponse response = dependentService.getDependentById(customerId, dependentId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{dependentId}")
    @Operation(summary = "Update dependent", description = "Update a dependent's information")
    public ResponseEntity<DependentResponse> updateDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Dependent UUID") @PathVariable UUID dependentId,
            @Valid @RequestBody DependentRequest request) {
        DependentResponse response = dependentService.updateDependent(customerId, dependentId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{dependentId}")
    @Operation(summary = "Delete dependent", description = "Remove a dependent")
    public ResponseEntity<Void> deleteDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Dependent UUID") @PathVariable UUID dependentId) {
        dependentService.deleteDependent(customerId, dependentId);
        return ResponseEntity.noContent().build();
    }
}
