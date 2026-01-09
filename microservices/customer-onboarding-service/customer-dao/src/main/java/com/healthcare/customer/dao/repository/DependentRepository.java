package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.RelationshipType;
import com.healthcare.customer.common.model.Dependent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface DependentRepository extends JpaRepository<Dependent, UUID> {

    List<Dependent> findByCustomerId(UUID customerId);

    List<Dependent> findByCustomerIdAndRelationship(UUID customerId, RelationshipType relationship);

    int countByCustomerId(UUID customerId);

    void deleteByCustomerId(UUID customerId);
}
