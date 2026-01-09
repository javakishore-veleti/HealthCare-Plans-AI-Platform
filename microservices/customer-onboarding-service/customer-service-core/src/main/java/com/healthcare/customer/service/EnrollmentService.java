package com.healthcare.customer.service;

import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;

import java.util.List;
import java.util.UUID;

public interface EnrollmentService {

    EligibilityResponse checkEligibility(UUID customerId, UUID planId);

    EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request);

    EnrollmentResponse getEnrollmentById(UUID enrollmentId);

    List<EnrollmentResponse> getCustomerEnrollments(UUID customerId);

    List<EnrollmentResponse> getActiveEnrollments(UUID customerId);

    void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason);

    void terminateEnrollment(UUID customerId, UUID enrollmentId, String reason);
}
