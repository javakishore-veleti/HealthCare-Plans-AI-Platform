package com.healthcare.order.common.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemResponse {

    private UUID id;
    private UUID planId;
    private String planCode;
    private String planName;
    private Integer planYear;
    private String metalTier;
    private String description;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal discountAmount;
    private BigDecimal subsidyAmount;
    private BigDecimal totalPrice;
    private Boolean includeDependents;
    private Integer dependentCount;
}
