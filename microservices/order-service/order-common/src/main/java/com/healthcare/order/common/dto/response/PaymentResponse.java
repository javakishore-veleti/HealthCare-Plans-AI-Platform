package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.CardBrand;
import com.healthcare.order.common.constants.PaymentMethod;
import com.healthcare.order.common.constants.PaymentStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentResponse {

    private UUID id;
    private String paymentNumber;
    private String transactionId;
    private PaymentMethod paymentMethod;
    private PaymentStatus status;
    private BigDecimal amount;
    private String currency;
    private BigDecimal processingFee;
    private CardBrand cardBrand;
    private String cardLast4;
    private String bankName;
    private String accountLast4;
    private LocalDateTime processedAt;
    private LocalDateTime failedAt;
    private String failureReason;
    private BigDecimal refundedAmount;
    private LocalDateTime createdAt;
}
