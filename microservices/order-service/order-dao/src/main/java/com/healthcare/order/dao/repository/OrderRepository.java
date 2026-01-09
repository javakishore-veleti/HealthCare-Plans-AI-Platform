package com.healthcare.order.dao.repository;

import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, UUID>, JpaSpecificationExecutor<Order> {

    Optional<Order> findByOrderNumber(String orderNumber);

    boolean existsByOrderNumber(String orderNumber);

    List<Order> findByCustomerId(UUID customerId);

    List<Order> findByCustomerIdAndStatus(UUID customerId, OrderStatus status);

    @Query("SELECT o FROM Order o LEFT JOIN FETCH o.items WHERE o.id = :id")
    Optional<Order> findByIdWithItems(@Param("id") UUID id);

    @Query("SELECT o FROM Order o " +
           "LEFT JOIN FETCH o.items " +
           "LEFT JOIN FETCH o.payments " +
           "WHERE o.id = :id")
    Optional<Order> findByIdWithDetails(@Param("id") UUID id);

    @Query("SELECT o FROM Order o WHERE o.customerId = :customerId AND o.status = :status " +
           "AND o.effectiveDate <= :date ORDER BY o.effectiveDate DESC")
    List<Order> findActiveOrders(@Param("customerId") UUID customerId,
                                  @Param("status") OrderStatus status,
                                  @Param("date") LocalDate date);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.customerId = :customerId AND o.status = :status")
    long countByCustomerIdAndStatus(@Param("customerId") UUID customerId, @Param("status") OrderStatus status);

    @Query("SELECT o FROM Order o WHERE o.status = :status AND o.createdAt < :cutoffDate")
    List<Order> findStaleOrders(@Param("status") OrderStatus status,
                                 @Param("cutoffDate") java.time.LocalDateTime cutoffDate);
}
