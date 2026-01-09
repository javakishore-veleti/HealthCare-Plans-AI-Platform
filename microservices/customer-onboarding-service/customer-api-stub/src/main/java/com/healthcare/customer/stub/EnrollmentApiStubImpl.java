package com.healthcare.customer.stub;

import com.healthcare.customer.client.EnrollmentApiClient;
import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.service.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class EnrollmentApiStubImpl implements EnrollmentApiClient {

    private final EnrollmentService enrollmentService;

    @Override
    public EligibilityResponse checkEligibility(UUID customerId, UUID planId) {
        return enrollmentService.checkEligibility(customerId, planId);
    }

    @Override
    public EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request) {
        return enrollmentService.enrollCustomer(customerId, request);
    }

    @Override
    public List<EnrollmentResponse> getCustomerEnrollments(UUID customerId) {
        return enrollmentService.getCustomerEnrollments(customerId);
    }

    @Override
    public List<EnrollmentResponse> getActiveEnrollments(UUID customerId) {
        return enrollmentService.getActiveEnrollments(customerId);
    }

    @Override
    public void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason) {
        enrollmentService.cancelEnrollment(customerId, enrollmentId, reason);
    }
}
