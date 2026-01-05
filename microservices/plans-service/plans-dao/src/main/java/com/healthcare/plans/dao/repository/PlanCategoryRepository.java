package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.PlanCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface PlanCategoryRepository extends JpaRepository<PlanCategory, Long> {
    Optional<PlanCategory> findByCode(String code);
    List<PlanCategory> findAllByOrderByNameAsc();
}
