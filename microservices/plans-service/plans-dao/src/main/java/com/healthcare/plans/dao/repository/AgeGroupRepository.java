package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.AgeGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface AgeGroupRepository extends JpaRepository<AgeGroup, Long> {
    Optional<AgeGroup> findByCode(String code);
    List<AgeGroup> findAllByOrderByMinAgeAsc();
}
