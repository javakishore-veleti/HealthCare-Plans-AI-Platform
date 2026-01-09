package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.EnrollmentStatus;
import com.healthcare.customer.common.model.CustomerPlanEnrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerPlanEnrollmentRepository extends JpaRepository<CustomerPlanEnrollment, UUID> {

    List<CustomerPlanEnrollment> findByCustomerId(UUID customerId);

    List<CustomerPlanEnrollment> findByCustomerIdAndStatus(UUID customerId, EnrollmentStatus status);

    Optional<CustomerPlanEnrollment> findByCustomerIdAndPlanIdAndStatus(UUID customerId, UUID planId, EnrollmentStatus status);

    @Query("SELECT e FROM CustomerPlanEnrollment e WHERE e.customer.id = :customerId " +
           "AND e.status = 'ENROLLED' AND e.effectiveDate <= :date " +
           "AND (e.terminationDate IS NULL OR e.terminationDate > :date)")
    List<CustomerPlanEnrollment> findActiveEnrollments(
        @Param("customerId") UUID customerId,
        @Param("date") LocalDate date);

    @Query("SELECT e FROM CustomerPlanEnrollment e WHERE e.planId = :planId AND e.status = 'ENROLLED'")
    List<CustomerPlanEnrollment> findEnrolledByPlanId(@Param("planId") UUID planId);

    @Query("SELECT COUNT(e) FROM CustomerPlanEnrollment e WHERE e.customer.id = :customerId AND e.status = 'ENROLLED'")
    int countActiveEnrollments(@Param("customerId") UUID customerId);

    boolean existsByCustomerIdAndPlanIdAndStatus(UUID customerId, UUID planId, EnrollmentStatus status);
}
