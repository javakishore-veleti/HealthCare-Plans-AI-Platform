package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.PlanInclusion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlanInclusionRepository extends JpaRepository<PlanInclusion, UUID> {
    List<PlanInclusion> findByPlanId(UUID planId);
    void deleteByPlanId(UUID planId);
}
