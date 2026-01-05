package com.healthcare.plans.dao.repository;

import com.healthcare.plans.common.model.State;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StateRepository extends JpaRepository<State, String> {
    List<State> findByRegion(String region);
    List<State> findAllByOrderByNameAsc();
}
