package com.healthcare.order.common.dto.request;

import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemRequest {

    @NotNull(message = "Plan ID is required")
    private UUID planId;

    @Min(value = 1, message = "Quantity must be at least 1")
    private Integer quantity;

    private Boolean includeDependents;

    private BigDecimal subsidyAmount;
}
