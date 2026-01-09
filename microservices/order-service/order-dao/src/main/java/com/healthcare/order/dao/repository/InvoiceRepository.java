package com.healthcare.order.dao.repository;

import com.healthcare.order.common.constants.InvoiceStatus;
import com.healthcare.order.common.model.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, UUID> {

    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    List<Invoice> findByOrderId(UUID orderId);

    List<Invoice> findByCustomerId(UUID customerId);

    List<Invoice> findByCustomerIdAndStatus(UUID customerId, InvoiceStatus status);

    @Query("SELECT i FROM Invoice i LEFT JOIN FETCH i.lineItems WHERE i.id = :id")
    Optional<Invoice> findByIdWithLineItems(@Param("id") UUID id);

    @Query("SELECT i FROM Invoice i WHERE i.status = 'SENT' AND i.dueDate < :today")
    List<Invoice> findOverdueInvoices(@Param("today") LocalDate today);

    @Query("SELECT i FROM Invoice i WHERE i.customerId = :customerId " +
           "AND i.status IN ('SENT', 'PARTIALLY_PAID', 'OVERDUE') " +
           "ORDER BY i.dueDate ASC")
    List<Invoice> findUnpaidInvoices(@Param("customerId") UUID customerId);
}
