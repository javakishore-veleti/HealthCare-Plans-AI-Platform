package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.constants.PlanStatus;
import com.healthcare.plans.common.model.Plan;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PlanRepository extends JpaRepository<Plan, UUID>, JpaSpecificationExecutor<Plan> {
    
    Optional<Plan> findByPlanCode(String planCode);
    
    boolean existsByPlanCode(String planCode);
    
    List<Plan> findByYearAndStatus(Integer year, PlanStatus status);
    
    @Query("SELECT p FROM Plan p WHERE p.state.code = :stateCode AND p.status = :status")
    List<Plan> findByStateAndStatus(@Param("stateCode") String stateCode, @Param("status") PlanStatus status);
    
    @Query("SELECT p FROM Plan p WHERE p.isNational = true AND p.status = :status")
    List<Plan> findNationalPlans(@Param("status") PlanStatus status);
    
    @Query("SELECT p FROM Plan p LEFT JOIN FETCH p.ageGroups LEFT JOIN FETCH p.categories WHERE p.id = :id")
    Optional<Plan> findByIdWithDetails(@Param("id") UUID id);
    
    @Query("SELECT COUNT(p) FROM Plan p WHERE p.year = :year AND p.status = :status")
    long countByYearAndStatus(@Param("year") Integer year, @Param("status") PlanStatus status);
}
