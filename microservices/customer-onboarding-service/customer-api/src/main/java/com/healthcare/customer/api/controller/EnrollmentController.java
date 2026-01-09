package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.service.EnrollmentService;
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
@RequestMapping("/api/v1/customers/{customerId}")
@RequiredArgsConstructor
@Tag(name = "Enrollment", description = "Plan enrollment and eligibility APIs")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    @PostMapping("/eligibility/{planId}")
    @Operation(summary = "Check eligibility", description = "Check customer eligibility for a specific plan")
    public ResponseEntity<EligibilityResponse> checkEligibility(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Plan UUID") @PathVariable UUID planId) {
        EligibilityResponse response = enrollmentService.checkEligibility(customerId, planId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/enrollments")
    @Operation(summary = "Enroll customer", description = "Enroll a customer in a healthcare plan")
    public ResponseEntity<EnrollmentResponse> enrollCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody EnrollmentRequest request) {
        EnrollmentResponse response = enrollmentService.enrollCustomer(customerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/enrollments")
    @Operation(summary = "Get enrollments", description = "Get all enrollments for a customer")
    public ResponseEntity<List<EnrollmentResponse>> getEnrollments(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<EnrollmentResponse> responses = enrollmentService.getCustomerEnrollments(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/enrollments/active")
    @Operation(summary = "Get active enrollments", description = "Get currently active enrollments")
    public ResponseEntity<List<EnrollmentResponse>> getActiveEnrollments(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<EnrollmentResponse> responses = enrollmentService.getActiveEnrollments(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/enrollments/{enrollmentId}")
    @Operation(summary = "Get enrollment", description = "Get enrollment details by ID")
    public ResponseEntity<EnrollmentResponse> getEnrollment(
            @Parameter(description = "Enrollment UUID") @PathVariable UUID enrollmentId) {
        EnrollmentResponse response = enrollmentService.getEnrollmentById(enrollmentId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/enrollments/{enrollmentId}")
    @Operation(summary = "Cancel enrollment", description = "Cancel an enrollment")
    public ResponseEntity<Void> cancelEnrollment(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Enrollment UUID") @PathVariable UUID enrollmentId,
            @RequestParam(required = false) String reason) {
        enrollmentService.cancelEnrollment(customerId, enrollmentId, reason);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/enrollments/{enrollmentId}/terminate")
    @Operation(summary = "Terminate enrollment", description = "Terminate an enrollment")
    public ResponseEntity<Void> terminateEnrollment(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Enrollment UUID") @PathVariable UUID enrollmentId,
            @RequestParam(required = false) String reason) {
        enrollmentService.terminateEnrollment(customerId, enrollmentId, reason);
        return ResponseEntity.ok().build();
    }
}
