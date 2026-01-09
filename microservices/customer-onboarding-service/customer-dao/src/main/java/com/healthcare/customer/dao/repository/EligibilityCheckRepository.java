package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.EligibilityStatus;
import com.healthcare.customer.common.model.EligibilityCheck;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EligibilityCheckRepository extends JpaRepository<EligibilityCheck, UUID> {

    List<EligibilityCheck> findByCustomerId(UUID customerId);

    List<EligibilityCheck> findByCustomerIdAndStatus(UUID customerId, EligibilityStatus status);

    Optional<EligibilityCheck> findByCustomerIdAndPlanId(UUID customerId, UUID planId);

    @Query("SELECT e FROM EligibilityCheck e WHERE e.customer.id = :customerId AND e.planId = :planId " +
           "AND e.status = 'ELIGIBLE' AND e.expirationDate > :now")
    Optional<EligibilityCheck> findValidEligibility(
        @Param("customerId") UUID customerId,
        @Param("planId") UUID planId,
        @Param("now") LocalDateTime now);

    @Query("SELECT e FROM EligibilityCheck e WHERE e.expirationDate < :now AND e.status = 'ELIGIBLE'")
    List<EligibilityCheck> findExpiredEligibilities(@Param("now") LocalDateTime now);
}
