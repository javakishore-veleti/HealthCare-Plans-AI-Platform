package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.BillingFrequency;
import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.constants.OrderType;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class OrderResponse {

    private UUID id;
    private String orderNumber;
    private UUID customerId;
    private String customerNumber;
    private String customerName;
    private String customerEmail;
    private OrderType orderType;
    private OrderStatus status;
    private BigDecimal subtotal;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;
    private BillingFrequency billingFrequency;
    private LocalDate effectiveDate;
    private LocalDate expirationDate;
    private String promoCode;
    private LocalDateTime submittedAt;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
