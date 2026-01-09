package com.healthcare.order.dao.repository;

import com.healthcare.order.common.model.SavedPaymentMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SavedPaymentMethodRepository extends JpaRepository<SavedPaymentMethod, UUID> {

    List<SavedPaymentMethod> findByCustomerIdAndIsActiveTrue(UUID customerId);

    Optional<SavedPaymentMethod> findByCustomerIdAndIsDefaultTrue(UUID customerId);

    @Modifying
    @Query("UPDATE SavedPaymentMethod s SET s.isDefault = false WHERE s.customerId = :customerId")
    void clearDefaultPaymentMethods(@Param("customerId") UUID customerId);

    @Query("SELECT s FROM SavedPaymentMethod s WHERE s.customerId = :customerId AND s.isActive = true " +
           "ORDER BY s.isDefault DESC, s.createdAt DESC")
    List<SavedPaymentMethod> findActivePaymentMethods(@Param("customerId") UUID customerId);
}
