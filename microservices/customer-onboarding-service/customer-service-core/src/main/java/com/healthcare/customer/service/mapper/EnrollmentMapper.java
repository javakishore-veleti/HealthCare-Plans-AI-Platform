package com.healthcare.customer.service.mapper;

import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.common.model.CustomerPlanEnrollment;
import com.healthcare.customer.common.model.EligibilityCheck;
import org.mapstruct.*;

import java.math.BigDecimal;
import java.util.Set;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface EnrollmentMapper {

    @Mapping(target = "customerId", source = "customer.id")
    EligibilityResponse toEligibilityResponse(EligibilityCheck check);

    @Mapping(target = "netPremium", expression = "java(calculateNetPremium(enrollment))")
    EnrollmentResponse toEnrollmentResponse(CustomerPlanEnrollment enrollment);

    default List<EnrollmentResponse> mapEnrollments(Set<CustomerPlanEnrollment> enrollments) {
        if (enrollments == null) return null;
        return enrollments.stream().map(this::toEnrollmentResponse).collect(Collectors.toList());
    }

    default BigDecimal calculateNetPremium(CustomerPlanEnrollment enrollment) {
        if (enrollment.getMonthlyPremium() == null) return null;
        BigDecimal subsidy = enrollment.getSubsidyAmount() != null ? enrollment.getSubsidyAmount() : BigDecimal.ZERO;
        return enrollment.getMonthlyPremium().subtract(subsidy);
    }
}
