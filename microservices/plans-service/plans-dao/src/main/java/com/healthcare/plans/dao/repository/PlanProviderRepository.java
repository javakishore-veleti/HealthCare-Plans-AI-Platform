package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.constants.NetworkStatus;
import com.healthcare.plans.common.model.PlanProvider;
import com.healthcare.plans.common.model.PlanProviderId;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlanProviderRepository extends JpaRepository<PlanProvider, PlanProviderId> {
    
    @Query("SELECT COUNT(pp) FROM PlanProvider pp WHERE pp.plan.id = :planId AND pp.networkStatus = 'IN_NETWORK'")
    long countInNetworkProviders(@Param("planId") UUID planId);
    
    void deleteByPlanId(UUID planId);
}
