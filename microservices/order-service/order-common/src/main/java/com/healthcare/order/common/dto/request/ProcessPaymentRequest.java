package com.healthcare.order.common.dto.request;

import com.healthcare.order.common.constants.PaymentMethod;
import jakarta.validation.constraints.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProcessPaymentRequest {

    @NotNull(message = "Order ID is required")
    private UUID orderId;

    @NotNull(message = "Payment method is required")
    private PaymentMethod paymentMethod;

    @NotNull(message = "Amount is required")
    @DecimalMin(value = "0.01", message = "Amount must be greater than 0")
    private BigDecimal amount;

    // Use saved payment method
    private UUID savedPaymentMethodId;

    // Or provide new card details
    private String cardNumber;
    private Integer cardExpiryMonth;
    private Integer cardExpiryYear;
    private String cardCvv;
    private String cardholderName;

    // Or bank details
    private String accountNumber;
    private String routingNumber;
    private String accountHolderName;

    private String billingZip;

    private Boolean savePaymentMethod;
}
