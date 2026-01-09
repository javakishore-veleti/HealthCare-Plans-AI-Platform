package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.InvoiceStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceDetailResponse {

    private UUID id;
    private String invoiceNumber;
    private UUID orderId;
    private String orderNumber;
    private UUID customerId;
    private String customerName;
    private String customerEmail;
    private String billingAddress;
    private InvoiceStatus status;
    private BigDecimal subtotal;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;
    private String currency;
    private LocalDate issueDate;
    private LocalDate dueDate;
    private LocalDate paidDate;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private LocalDateTime sentAt;
    private String notes;
    private List<InvoiceLineItemResponse> lineItems;
    private LocalDateTime createdAt;
}
