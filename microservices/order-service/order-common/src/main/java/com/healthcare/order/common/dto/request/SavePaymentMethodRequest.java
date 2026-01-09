package com.healthcare.order.common.dto.request;

import com.healthcare.order.common.constants.PaymentMethod;
import jakarta.validation.constraints.*;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SavePaymentMethodRequest {

    @NotNull(message = "Customer ID is required")
    private UUID customerId;

    @NotNull(message = "Payment method type is required")
    private PaymentMethod paymentMethod;

    private String nickname;

    private Boolean isDefault;

    // Card details
    @Size(min = 13, max = 19)
    private String cardNumber;
    private Integer cardExpiryMonth;
    private Integer cardExpiryYear;
    private String cardholderName;

    // Bank details
    private String bankName;
    private String accountType;
    private String accountNumber;
    private String routingNumber;

    private String billingZip;
}
