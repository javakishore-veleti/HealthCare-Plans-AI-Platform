package com.healthcare.order.common.model;

import com.healthcare.order.common.constants.CardBrand;
import com.healthcare.order.common.constants.PaymentMethod;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "saved_payment_methods", indexes = {
    @Index(name = "idx_saved_payment_methods_customer_id", columnList = "customer_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SavedPaymentMethod extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Column(name = "nickname", length = 100)
    private String nickname;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", nullable = false, length = 20)
    private PaymentMethod paymentMethod;

    @Column(name = "is_default", nullable = false)
    @Builder.Default
    private Boolean isDefault = false;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    // Card details (masked/tokenized)
    @Enumerated(EnumType.STRING)
    @Column(name = "card_brand", length = 20)
    private CardBrand cardBrand;

    @Column(name = "card_last4", length = 4)
    private String cardLast4;

    @Column(name = "card_expiry_month")
    private Integer cardExpiryMonth;

    @Column(name = "card_expiry_year")
    private Integer cardExpiryYear;

    @Column(name = "cardholder_name", length = 200)
    private String cardholderName;

    // Bank details (masked)
    @Column(name = "bank_name", length = 100)
    private String bankName;

    @Column(name = "account_type", length = 20)
    private String accountType;

    @Column(name = "account_last4", length = 4)
    private String accountLast4;

    @Column(name = "routing_last4", length = 4)
    private String routingLast4;

    // Payment gateway token
    @Column(name = "gateway_token", length = 500)
    private String gatewayToken;

    @Column(name = "billing_zip", length = 10)
    private String billingZip;
}
