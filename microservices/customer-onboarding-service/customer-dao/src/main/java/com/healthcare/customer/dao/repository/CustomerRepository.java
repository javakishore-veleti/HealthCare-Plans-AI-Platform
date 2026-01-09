package com.healthcare.customer.dao.repository;

import com.healthcare.customer.common.constants.CustomerStatus;
import com.healthcare.customer.common.model.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, UUID>, JpaSpecificationExecutor<Customer> {

    Optional<Customer> findByCustomerNumber(String customerNumber);

    Optional<Customer> findByEmail(String email);

    boolean existsByEmail(String email);

    boolean existsByCustomerNumber(String customerNumber);

    List<Customer> findByStatus(CustomerStatus status);

    @Query("SELECT c FROM Customer c LEFT JOIN FETCH c.addresses WHERE c.id = :id")
    Optional<Customer> findByIdWithAddresses(@Param("id") UUID id);

    @Query("SELECT c FROM Customer c " +
           "LEFT JOIN FETCH c.addresses " +
           "LEFT JOIN FETCH c.dependents " +
           "WHERE c.id = :id")
    Optional<Customer> findByIdWithDetails(@Param("id") UUID id);

    @Query("SELECT c FROM Customer c WHERE c.status = :status AND c.emailVerified = false")
    List<Customer> findUnverifiedCustomers(@Param("status") CustomerStatus status);

    @Query("SELECT COUNT(c) FROM Customer c WHERE c.status = :status")
    long countByStatus(@Param("status") CustomerStatus status);
}
