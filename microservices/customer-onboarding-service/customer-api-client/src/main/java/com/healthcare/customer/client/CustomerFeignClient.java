package com.healthcare.customer.client;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "customer-service", url = "${customer.service.url:http://localhost:8082}")
public interface CustomerFeignClient extends CustomerApiClient, EnrollmentApiClient {

    // Customer endpoints
    @Override
    @PostMapping("/api/v1/customers")
    CustomerDetailResponse createCustomer(@RequestBody CreateCustomerRequest request);

    @Override
    @GetMapping("/api/v1/customers/{customerId}")
    CustomerDetailResponse getCustomerById(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/customers/email/{email}")
    CustomerDetailResponse getCustomerByEmail(@PathVariable("email") String email);

    @Override
    @PostMapping("/api/v1/customers/search")
    PagedResponse<CustomerResponse> searchCustomers(@RequestBody CustomerSearchRequest request);

    @Override
    @PutMapping("/api/v1/customers/{customerId}")
    CustomerDetailResponse updateCustomer(@PathVariable("customerId") UUID customerId,
                                          @RequestBody UpdateCustomerRequest request);

    @Override
    @DeleteMapping("/api/v1/customers/{customerId}")
    void deleteCustomer(@PathVariable("customerId") UUID customerId);

    @Override
    @PostMapping("/api/v1/customers/{customerId}/activate")
    void activateCustomer(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/customers/email-available")
    boolean isEmailAvailable(@RequestParam("email") String email);

    // Enrollment endpoints
    @Override
    @PostMapping("/api/v1/customers/{customerId}/eligibility/{planId}")
    EligibilityResponse checkEligibility(@PathVariable("customerId") UUID customerId,
                                         @PathVariable("planId") UUID planId);

    @Override
    @PostMapping("/api/v1/customers/{customerId}/enrollments")
    EnrollmentResponse enrollCustomer(@PathVariable("customerId") UUID customerId,
                                      @RequestBody EnrollmentRequest request);

    @Override
    @GetMapping("/api/v1/customers/{customerId}/enrollments")
    List<EnrollmentResponse> getCustomerEnrollments(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/customers/{customerId}/enrollments/active")
    List<EnrollmentResponse> getActiveEnrollments(@PathVariable("customerId") UUID customerId);

    @Override
    @DeleteMapping("/api/v1/customers/{customerId}/enrollments/{enrollmentId}")
    void cancelEnrollment(@PathVariable("customerId") UUID customerId,
                          @PathVariable("enrollmentId") UUID enrollmentId,
                          @RequestParam("reason") String reason);
}
