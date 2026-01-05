package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.PlanExclusion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface PlanExclusionRepository extends JpaRepository<PlanExclusion, UUID> {
    List<PlanExclusion> findByPlanId(UUID planId);
    void deleteByPlanId(UUID planId);
}
