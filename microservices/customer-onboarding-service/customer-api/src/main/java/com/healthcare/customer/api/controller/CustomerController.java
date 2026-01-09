package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
@Tag(name = "Customer", description = "Customer management APIs")
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping
    @Operation(summary = "Create a new customer", description = "Register a new customer in the system")
    public ResponseEntity<CustomerDetailResponse> createCustomer(
            @Valid @RequestBody CreateCustomerRequest request) {
        CustomerDetailResponse response = customerService.createCustomer(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{customerId}")
    @Operation(summary = "Get customer by ID", description = "Retrieve customer details by UUID")
    public ResponseEntity<CustomerDetailResponse> getCustomerById(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        CustomerDetailResponse response = customerService.getCustomerById(customerId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/number/{customerNumber}")
    @Operation(summary = "Get customer by number", description = "Retrieve customer by customer number")
    public ResponseEntity<CustomerDetailResponse> getCustomerByNumber(
            @Parameter(description = "Customer number") @PathVariable String customerNumber) {
        CustomerDetailResponse response = customerService.getCustomerByNumber(customerNumber);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/email/{email}")
    @Operation(summary = "Get customer by email", description = "Retrieve customer by email address")
    public ResponseEntity<CustomerDetailResponse> getCustomerByEmail(
            @Parameter(description = "Email address") @PathVariable String email) {
        CustomerDetailResponse response = customerService.getCustomerByEmail(email);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/search")
    @Operation(summary = "Search customers", description = "Search customers with filters and pagination")
    public ResponseEntity<PagedResponse<CustomerResponse>> searchCustomers(
            @Valid @RequestBody CustomerSearchRequest request) {
        PagedResponse<CustomerResponse> response = customerService.searchCustomers(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{customerId}")
    @Operation(summary = "Update customer", description = "Update customer information")
    public ResponseEntity<CustomerDetailResponse> updateCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody UpdateCustomerRequest request) {
        CustomerDetailResponse response = customerService.updateCustomer(customerId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{customerId}")
    @Operation(summary = "Delete customer", description = "Soft delete a customer")
    public ResponseEntity<Void> deleteCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        customerService.deleteCustomer(customerId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{customerId}/activate")
    @Operation(summary = "Activate customer", description = "Activate a pending customer")
    public ResponseEntity<Void> activateCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        customerService.activateCustomer(customerId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{customerId}/suspend")
    @Operation(summary = "Suspend customer", description = "Suspend a customer account")
    public ResponseEntity<Void> suspendCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @RequestParam(required = false) String reason) {
        customerService.suspendCustomer(customerId, reason);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/email-available")
    @Operation(summary = "Check email availability", description = "Check if an email is available for registration")
    public ResponseEntity<Boolean> isEmailAvailable(
            @Parameter(description = "Email address") @RequestParam String email) {
        boolean available = customerService.isEmailAvailable(email);
        return ResponseEntity.ok(available);
    }
}
