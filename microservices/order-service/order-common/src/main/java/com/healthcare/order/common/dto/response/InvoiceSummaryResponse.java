package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.InvoiceStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceSummaryResponse {

    private UUID id;
    private String invoiceNumber;
    private InvoiceStatus status;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;
    private LocalDate issueDate;
    private LocalDate dueDate;
    private LocalDate paidDate;
}
