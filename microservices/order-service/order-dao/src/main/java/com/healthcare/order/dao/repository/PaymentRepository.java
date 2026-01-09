package com.healthcare.order.dao.repository;

import com.healthcare.order.common.constants.PaymentStatus;
import com.healthcare.order.common.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    Optional<Payment> findByPaymentNumber(String paymentNumber);

    Optional<Payment> findByTransactionId(String transactionId);

    List<Payment> findByOrderId(UUID orderId);

    List<Payment> findByOrderIdAndStatus(UUID orderId, PaymentStatus status);

    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.order.id = :orderId AND p.status = 'COMPLETED'")
    BigDecimal getTotalPaidAmount(@Param("orderId") UUID orderId);

    @Query("SELECT p FROM Payment p WHERE p.status = :status AND p.createdAt < :cutoffDate")
    List<Payment> findStalePayments(@Param("status") PaymentStatus status,
                                     @Param("cutoffDate") LocalDateTime cutoffDate);

    @Query("SELECT p FROM Payment p JOIN FETCH p.order WHERE p.id = :id")
    Optional<Payment> findByIdWithOrder(@Param("id") UUID id);
}
