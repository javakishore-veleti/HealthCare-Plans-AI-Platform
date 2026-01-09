package com.healthcare.customer.service;

import com.healthcare.customer.common.constants.EligibilityStatus;
import com.healthcare.customer.common.constants.EnrollmentStatus;
import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.common.model.Customer;
import com.healthcare.customer.common.model.CustomerPlanEnrollment;
import com.healthcare.customer.common.model.EligibilityCheck;
import com.healthcare.customer.dao.repository.CustomerPlanEnrollmentRepository;
import com.healthcare.customer.dao.repository.CustomerRepository;
import com.healthcare.customer.dao.repository.EligibilityCheckRepository;
import com.healthcare.customer.service.mapper.EnrollmentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class EnrollmentServiceImpl implements EnrollmentService {

    private final CustomerRepository customerRepository;
    private final CustomerPlanEnrollmentRepository enrollmentRepository;
    private final EligibilityCheckRepository eligibilityRepository;
    private final EnrollmentMapper enrollmentMapper;

    // TODO: Inject PlanApiClient for inter-service communication
    // private final PlanApiClient planApiClient;

    @Override
    public EligibilityResponse checkEligibility(UUID customerId, UUID planId) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        // Check if there's a valid existing eligibility
        EligibilityCheck existing = eligibilityRepository
            .findValidEligibility(customerId, planId, LocalDateTime.now())
            .orElse(null);

        if (existing != null) {
            return enrollmentMapper.toEligibilityResponse(existing);
        }

        // Perform new eligibility check
        EligibilityCheck check = EligibilityCheck.builder()
            .customer(customer)
            .planId(planId)
            .checkDate(LocalDateTime.now())
            .expirationDate(LocalDateTime.now().plusDays(30))
            .build();

        // TODO: Call plans-service to get plan details and verify eligibility
        // PlanDetailResponse plan = planApiClient.getPlanById(planId);

        // Basic eligibility checks
        boolean ageVerified = verifyAge(customer);
        boolean residenceVerified = !customer.getAddresses().isEmpty();
        boolean incomeVerified = true; // Simplified for now

        check.setAgeVerified(ageVerified);
        check.setResidenceVerified(residenceVerified);
        check.setIncomeVerified(incomeVerified);

        if (ageVerified && residenceVerified) {
            check.setStatus(EligibilityStatus.ELIGIBLE);
            check.setEligibilityReason("Customer meets all eligibility requirements");
        } else {
            check.setStatus(EligibilityStatus.NOT_ELIGIBLE);
            StringBuilder reason = new StringBuilder("Not eligible: ");
            if (!ageVerified) reason.append("Age not verified. ");
            if (!residenceVerified) reason.append("Residence not verified. ");
            check.setEligibilityReason(reason.toString());
        }

        EligibilityCheck savedCheck = eligibilityRepository.save(check);
        log.info("Eligibility check for customer {} and plan {}: {}", customerId, planId, savedCheck.getStatus());

        return enrollmentMapper.toEligibilityResponse(savedCheck);
    }

    @Override
    public EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request) {
        Customer customer = customerRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + customerId));

        // Check if already enrolled in this plan
        if (enrollmentRepository.existsByCustomerIdAndPlanIdAndStatus(
                customerId, request.getPlanId(), EnrollmentStatus.ENROLLED)) {
            throw new IllegalArgumentException("Customer is already enrolled in this plan");
        }

        // Verify eligibility
        EligibilityCheck eligibility = eligibilityRepository
            .findValidEligibility(customerId, request.getPlanId(), LocalDateTime.now())
            .orElseThrow(() -> new IllegalArgumentException("No valid eligibility found. Please check eligibility first."));

        if (eligibility.getStatus() != EligibilityStatus.ELIGIBLE) {
            throw new IllegalArgumentException("Customer is not eligible for this plan");
        }

        // TODO: Get plan details from plans-service
        // PlanDetailResponse plan = planApiClient.getPlanById(request.getPlanId());

        CustomerPlanEnrollment enrollment = CustomerPlanEnrollment.builder()
            .customer(customer)
            .planId(request.getPlanId())
            .planCode("PLAN-" + request.getPlanId().toString().substring(0, 8))  // TODO: Get from plans-service
            .planName("Healthcare Plan")  // TODO: Get from plans-service
            .status(EnrollmentStatus.ENROLLED)
            .effectiveDate(request.getEffectiveDate())
            .memberId(generateMemberId(customer))
            .groupNumber("GRP" + LocalDate.now().getYear())
            .includeDependents(Boolean.TRUE.equals(request.getIncludeDependents()))
            .autoRenew(Boolean.TRUE.equals(request.getAutoRenew()))
            .build();

        CustomerPlanEnrollment savedEnrollment = enrollmentRepository.save(enrollment);
        log.info("Enrolled customer {} in plan {}", customerId, request.getPlanId());

        return enrollmentMapper.toEnrollmentResponse(savedEnrollment);
    }

    @Override
    @Transactional(readOnly = true)
    public EnrollmentResponse getEnrollmentById(UUID enrollmentId) {
        CustomerPlanEnrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new IllegalArgumentException("Enrollment not found: " + enrollmentId));
        return enrollmentMapper.toEnrollmentResponse(enrollment);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EnrollmentResponse> getCustomerEnrollments(UUID customerId) {
        return enrollmentRepository.findByCustomerId(customerId).stream()
            .map(enrollmentMapper::toEnrollmentResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<EnrollmentResponse> getActiveEnrollments(UUID customerId) {
        return enrollmentRepository.findActiveEnrollments(customerId, LocalDate.now()).stream()
            .map(enrollmentMapper::toEnrollmentResponse)
            .collect(Collectors.toList());
    }

    @Override
    public void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason) {
        CustomerPlanEnrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new IllegalArgumentException("Enrollment not found: " + enrollmentId));

        if (!enrollment.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Enrollment does not belong to customer");
        }

        enrollment.setStatus(EnrollmentStatus.CANCELLED);
        enrollment.setCancellationReason(reason);
        enrollment.setTerminationDate(LocalDate.now());
        enrollmentRepository.save(enrollment);

        log.info("Cancelled enrollment {} for customer {} - Reason: {}", enrollmentId, customerId, reason);
    }

    @Override
    public void terminateEnrollment(UUID customerId, UUID enrollmentId, String reason) {
        CustomerPlanEnrollment enrollment = enrollmentRepository.findById(enrollmentId)
            .orElseThrow(() -> new IllegalArgumentException("Enrollment not found: " + enrollmentId));

        if (!enrollment.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Enrollment does not belong to customer");
        }

        enrollment.setStatus(EnrollmentStatus.TERMINATED);
        enrollment.setCancellationReason(reason);
        enrollment.setTerminationDate(LocalDate.now());
        enrollmentRepository.save(enrollment);

        log.info("Terminated enrollment {} for customer {} - Reason: {}", enrollmentId, customerId, reason);
    }

    private boolean verifyAge(Customer customer) {
        if (customer.getDateOfBirth() == null) return false;
        int age = LocalDate.now().getYear() - customer.getDateOfBirth().getYear();
        return age >= 0 && age <= 120;
    }

    private String generateMemberId(Customer customer) {
        return "MBR" + customer.getCustomerNumber() + LocalDate.now().getYear();
    }
}
