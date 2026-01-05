package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.Specialty;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;

@Repository
public interface SpecialtyRepository extends JpaRepository<Specialty, Long> {
    Optional<Specialty> findByCode(String code);
    List<Specialty> findAllByOrderByNameAsc();
}
