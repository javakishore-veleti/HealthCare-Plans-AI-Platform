package com.healthcare.order.service;

import com.healthcare.order.common.constants.InvoiceStatus;
import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;
import com.healthcare.order.common.model.*;
import com.healthcare.order.dao.repository.InvoiceRepository;
import com.healthcare.order.dao.repository.OrderRepository;
import com.healthcare.order.service.mapper.InvoiceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class InvoiceServiceImpl implements InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final OrderRepository orderRepository;
    private final InvoiceMapper invoiceMapper;

    @Override
    public InvoiceDetailResponse generateInvoice(UUID orderId) {
        Order order = orderRepository.findByIdWithDetails(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        Invoice invoice = Invoice.builder()
            .order(order)
            .invoiceNumber(generateInvoiceNumber())
            .customerId(order.getCustomerId())
            .customerName(order.getCustomerName())
            .customerEmail(order.getCustomerEmail())
            .status(InvoiceStatus.DRAFT)
            .subtotal(order.getSubtotal())
            .taxAmount(order.getTaxAmount())
            .discountAmount(order.getDiscountAmount())
            .totalAmount(order.getTotalAmount())
            .issueDate(LocalDate.now())
            .dueDate(LocalDate.now().plusDays(30))
            .periodStart(order.getEffectiveDate())
            .periodEnd(order.getEffectiveDate().plusMonths(1).minusDays(1))
            .build();

        // Add line items from order items
        for (OrderItem orderItem : order.getItems()) {
            InvoiceLineItem lineItem = InvoiceLineItem.builder()
                .invoice(invoice)
                .description(orderItem.getPlanName() + " - " + orderItem.getDescription())
                .quantity(orderItem.getQuantity())
                .unitPrice(orderItem.getUnitPrice())
                .totalPrice(orderItem.getTotalPrice())
                .planId(orderItem.getPlanId())
                .planCode(orderItem.getPlanCode())
                .build();
            invoice.getLineItems().add(lineItem);
        }

        Invoice savedInvoice = invoiceRepository.save(invoice);
        log.info("Generated invoice {} for order {}", savedInvoice.getInvoiceNumber(), order.getOrderNumber());

        return invoiceMapper.toDetailResponse(savedInvoice);
    }

    @Override
    @Transactional(readOnly = true)
    public InvoiceDetailResponse getInvoiceById(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findByIdWithLineItems(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));
        return invoiceMapper.toDetailResponse(invoice);
    }

    @Override
    @Transactional(readOnly = true)
    public InvoiceDetailResponse getInvoiceByNumber(String invoiceNumber) {
        Invoice invoice = invoiceRepository.findByInvoiceNumber(invoiceNumber)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceNumber));
        return invoiceMapper.toDetailResponse(invoice);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceSummaryResponse> getOrderInvoices(UUID orderId) {
        return invoiceRepository.findByOrderId(orderId).stream()
            .map(invoiceMapper::toSummaryResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceSummaryResponse> getCustomerInvoices(UUID customerId) {
        return invoiceRepository.findByCustomerId(customerId).stream()
            .map(invoiceMapper::toSummaryResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceSummaryResponse> getUnpaidInvoices(UUID customerId) {
        return invoiceRepository.findUnpaidInvoices(customerId).stream()
            .map(invoiceMapper::toSummaryResponse)
            .collect(Collectors.toList());
    }

    @Override
    public InvoiceDetailResponse sendInvoice(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        if (invoice.getStatus() != InvoiceStatus.DRAFT) {
            throw new IllegalStateException("Only draft invoices can be sent");
        }

        invoice.setStatus(InvoiceStatus.SENT);
        invoice.setSentAt(LocalDateTime.now());

        // TODO: Send email notification
        // emailService.sendInvoice(invoice);

        Invoice savedInvoice = invoiceRepository.save(invoice);
        log.info("Sent invoice {} to {}", savedInvoice.getInvoiceNumber(), savedInvoice.getCustomerEmail());

        return invoiceMapper.toDetailResponse(savedInvoice);
    }

    @Override
    public InvoiceDetailResponse markAsPaid(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        invoice.setStatus(InvoiceStatus.PAID);
        invoice.setPaidAmount(invoice.getTotalAmount());
        invoice.setPaidDate(LocalDate.now());

        Invoice savedInvoice = invoiceRepository.save(invoice);
        log.info("Marked invoice {} as paid", savedInvoice.getInvoiceNumber());

        return invoiceMapper.toDetailResponse(savedInvoice);
    }

    @Override
    public void cancelInvoice(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        if (invoice.getStatus() == InvoiceStatus.PAID) {
            throw new IllegalStateException("Cannot cancel paid invoices");
        }

        invoice.setStatus(InvoiceStatus.CANCELLED);
        invoiceRepository.save(invoice);
        log.info("Cancelled invoice {}", invoice.getInvoiceNumber());
    }

    private String generateInvoiceNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int random = (int) (Math.random() * 10000);
        return String.format("INV-%s-%04d", timestamp, random);
    }
}
