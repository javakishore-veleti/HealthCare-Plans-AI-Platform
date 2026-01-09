package com.healthcare.order.common.dto.request;

import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.constants.OrderType;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderSearchRequest {

    private UUID customerId;
    private String orderNumber;
    private OrderStatus status;
    private OrderType orderType;
    private LocalDate fromDate;
    private LocalDate toDate;

    @Builder.Default
    private Integer page = 0;

    @Builder.Default
    private Integer size = 20;

    private String sortBy;
    private String sortDirection;
}
