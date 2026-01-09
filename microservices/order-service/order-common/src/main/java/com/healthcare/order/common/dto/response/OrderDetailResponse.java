package com.healthcare.order.common.dto.response;

import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class OrderDetailResponse extends OrderResponse {

    private List<OrderItemResponse> items;
    private List<PaymentResponse> payments;
    private List<InvoiceSummaryResponse> invoices;
    private String notes;
    private String cancellationReason;
}
