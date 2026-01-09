package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.CardBrand;
import com.healthcare.order.common.constants.PaymentMethod;
import lombok.*;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SavedPaymentMethodResponse {

    private UUID id;
    private String nickname;
    private PaymentMethod paymentMethod;
    private Boolean isDefault;
    private Boolean isActive;
    private CardBrand cardBrand;
    private String cardLast4;
    private Integer cardExpiryMonth;
    private Integer cardExpiryYear;
    private String cardholderName;
    private String bankName;
    private String accountType;
    private String accountLast4;
    private String billingZip;
}
