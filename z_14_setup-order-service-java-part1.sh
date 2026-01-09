#!/bin/bash

# =============================================================================
# Order Service - Java Source Files Generator (Part 1)
# =============================================================================
# Creates: Constants, Models (Entities), DTOs
# =============================================================================

set -e

BASE_DIR="microservices/order-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}          Order Service - Part 1 (Constants, Entities, DTOs)                  ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# CONSTANTS
# =============================================================================
echo -e "${CYAN}Creating Constants...${NC}"

CONSTANTS_DIR="$BASE_DIR/order-common/src/main/java/com/healthcare/order/common/constants"
mkdir -p "$CONSTANTS_DIR"

cat > "$CONSTANTS_DIR/OrderStatus.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum OrderStatus {
    DRAFT,
    PENDING_PAYMENT,
    PAYMENT_PROCESSING,
    PAYMENT_FAILED,
    CONFIRMED,
    PROCESSING,
    COMPLETED,
    CANCELLED,
    REFUNDED
}
EOF
echo -e "${GREEN}✓${NC} OrderStatus.java"

cat > "$CONSTANTS_DIR/OrderType.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum OrderType {
    NEW_ENROLLMENT,
    PLAN_CHANGE,
    RENEWAL,
    ADD_DEPENDENT,
    REMOVE_DEPENDENT,
    CANCELLATION
}
EOF
echo -e "${GREEN}✓${NC} OrderType.java"

cat > "$CONSTANTS_DIR/PaymentStatus.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum PaymentStatus {
    PENDING,
    PROCESSING,
    COMPLETED,
    FAILED,
    REFUNDED,
    PARTIALLY_REFUNDED,
    CANCELLED
}
EOF
echo -e "${GREEN}✓${NC} PaymentStatus.java"

cat > "$CONSTANTS_DIR/PaymentMethod.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum PaymentMethod {
    CREDIT_CARD,
    DEBIT_CARD,
    BANK_TRANSFER,
    ACH,
    CHECK,
    WIRE_TRANSFER
}
EOF
echo -e "${GREEN}✓${NC} PaymentMethod.java"

cat > "$CONSTANTS_DIR/CardBrand.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum CardBrand {
    VISA,
    MASTERCARD,
    AMERICAN_EXPRESS,
    DISCOVER,
    OTHER
}
EOF
echo -e "${GREEN}✓${NC} CardBrand.java"

cat > "$CONSTANTS_DIR/InvoiceStatus.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum InvoiceStatus {
    DRAFT,
    SENT,
    PAID,
    PARTIALLY_PAID,
    OVERDUE,
    CANCELLED,
    REFUNDED
}
EOF
echo -e "${GREEN}✓${NC} InvoiceStatus.java"

cat > "$CONSTANTS_DIR/BillingFrequency.java" << 'EOF'
package com.healthcare.order.common.constants;

public enum BillingFrequency {
    MONTHLY,
    QUARTERLY,
    SEMI_ANNUAL,
    ANNUAL
}
EOF
echo -e "${GREEN}✓${NC} BillingFrequency.java"

# =============================================================================
# MODELS (ENTITIES)
# =============================================================================
echo ""
echo -e "${CYAN}Creating Entities...${NC}"

MODELS_DIR="$BASE_DIR/order-common/src/main/java/com/healthcare/order/common/model"
mkdir -p "$MODELS_DIR"

cat > "$MODELS_DIR/BaseEntity.java" << 'EOF'
package com.healthcare.order.common.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@MappedSuperclass
public abstract class BaseEntity {

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
EOF
echo -e "${GREEN}✓${NC} BaseEntity.java"

cat > "$MODELS_DIR/Order.java" << 'EOF'
package com.healthcare.order.common.model;

import com.healthcare.order.common.constants.BillingFrequency;
import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.constants.OrderType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "orders", indexes = {
    @Index(name = "idx_orders_order_number", columnList = "order_number"),
    @Index(name = "idx_orders_customer_id", columnList = "customer_id"),
    @Index(name = "idx_orders_status", columnList = "status"),
    @Index(name = "idx_orders_created_at", columnList = "created_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "order_number", nullable = false, unique = true, length = 30)
    private String orderNumber;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Column(name = "customer_number", nullable = false, length = 20)
    private String customerNumber;

    @Column(name = "customer_name", nullable = false, length = 200)
    private String customerName;

    @Column(name = "customer_email", nullable = false, length = 200)
    private String customerEmail;

    @Enumerated(EnumType.STRING)
    @Column(name = "order_type", nullable = false, length = 20)
    private OrderType orderType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 25)
    @Builder.Default
    private OrderStatus status = OrderStatus.DRAFT;

    @Column(name = "subtotal", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal subtotal = BigDecimal.ZERO;

    @Column(name = "tax_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Column(name = "discount_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Enumerated(EnumType.STRING)
    @Column(name = "billing_frequency", nullable = false, length = 15)
    @Builder.Default
    private BillingFrequency billingFrequency = BillingFrequency.MONTHLY;

    @Column(name = "effective_date", nullable = false)
    private LocalDate effectiveDate;

    @Column(name = "expiration_date")
    private LocalDate expirationDate;

    @Column(name = "submitted_at")
    private LocalDateTime submittedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "cancelled_at")
    private LocalDateTime cancelledAt;

    @Column(name = "cancellation_reason", length = 500)
    private String cancellationReason;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "promo_code", length = 50)
    private String promoCode;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<OrderItem> items = new HashSet<>();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Payment> payments = new HashSet<>();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<Invoice> invoices = new HashSet<>();

    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
        recalculateTotals();
    }

    public void removeItem(OrderItem item) {
        items.remove(item);
        item.setOrder(null);
        recalculateTotals();
    }

    public void recalculateTotals() {
        this.subtotal = items.stream()
            .map(OrderItem::getTotalPrice)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        this.totalAmount = subtotal
            .add(taxAmount != null ? taxAmount : BigDecimal.ZERO)
            .subtract(discountAmount != null ? discountAmount : BigDecimal.ZERO);
    }

    public BigDecimal getPaidAmount() {
        return payments.stream()
            .filter(p -> p.getStatus() == com.healthcare.order.common.constants.PaymentStatus.COMPLETED)
            .map(Payment::getAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public BigDecimal getBalanceDue() {
        return totalAmount.subtract(getPaidAmount());
    }
}
EOF
echo -e "${GREEN}✓${NC} Order.java"

cat > "$MODELS_DIR/OrderItem.java" << 'EOF'
package com.healthcare.order.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "order_items", indexes = {
    @Index(name = "idx_order_items_order_id", columnList = "order_id"),
    @Index(name = "idx_order_items_plan_id", columnList = "plan_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "plan_id", nullable = false)
    private UUID planId;

    @Column(name = "plan_code", nullable = false, length = 50)
    private String planCode;

    @Column(name = "plan_name", nullable = false, length = 200)
    private String planName;

    @Column(name = "plan_year")
    private Integer planYear;

    @Column(name = "metal_tier", length = 20)
    private String metalTier;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "quantity", nullable = false)
    @Builder.Default
    private Integer quantity = 1;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "discount_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "include_dependents", nullable = false)
    @Builder.Default
    private Boolean includeDependents = false;

    @Column(name = "dependent_count")
    @Builder.Default
    private Integer dependentCount = 0;

    @Column(name = "subsidy_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal subsidyAmount = BigDecimal.ZERO;

    @PrePersist
    @PreUpdate
    public void calculateTotalPrice() {
        BigDecimal basePrice = unitPrice.multiply(BigDecimal.valueOf(quantity));
        BigDecimal discount = discountAmount != null ? discountAmount : BigDecimal.ZERO;
        BigDecimal subsidy = subsidyAmount != null ? subsidyAmount : BigDecimal.ZERO;
        this.totalPrice = basePrice.subtract(discount).subtract(subsidy);
        if (this.totalPrice.compareTo(BigDecimal.ZERO) < 0) {
            this.totalPrice = BigDecimal.ZERO;
        }
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderItem.java"

cat > "$MODELS_DIR/Payment.java" << 'EOF'
package com.healthcare.order.common.model;

import com.healthcare.order.common.constants.CardBrand;
import com.healthcare.order.common.constants.PaymentMethod;
import com.healthcare.order.common.constants.PaymentStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "payments", indexes = {
    @Index(name = "idx_payments_order_id", columnList = "order_id"),
    @Index(name = "idx_payments_transaction_id", columnList = "transaction_id"),
    @Index(name = "idx_payments_status", columnList = "status"),
    @Index(name = "idx_payments_created_at", columnList = "created_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "payment_number", nullable = false, unique = true, length = 30)
    private String paymentNumber;

    @Column(name = "transaction_id", length = 100)
    private String transactionId;

    @Column(name = "external_reference", length = 100)
    private String externalReference;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_method", nullable = false, length = 20)
    private PaymentMethod paymentMethod;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 25)
    @Builder.Default
    private PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(name = "currency", nullable = false, length = 3)
    @Builder.Default
    private String currency = "USD";

    @Column(name = "processing_fee", precision = 8, scale = 2)
    @Builder.Default
    private BigDecimal processingFee = BigDecimal.ZERO;

    // Card details (masked)
    @Enumerated(EnumType.STRING)
    @Column(name = "card_brand", length = 20)
    private CardBrand cardBrand;

    @Column(name = "card_last4", length = 4)
    private String cardLast4;

    @Column(name = "card_expiry_month")
    private Integer cardExpiryMonth;

    @Column(name = "card_expiry_year")
    private Integer cardExpiryYear;

    @Column(name = "billing_name", length = 200)
    private String billingName;

    @Column(name = "billing_zip", length = 10)
    private String billingZip;

    // Bank details (masked)
    @Column(name = "bank_name", length = 100)
    private String bankName;

    @Column(name = "account_last4", length = 4)
    private String accountLast4;

    @Column(name = "routing_last4", length = 4)
    private String routingLast4;

    @Column(name = "processed_at")
    private LocalDateTime processedAt;

    @Column(name = "failed_at")
    private LocalDateTime failedAt;

    @Column(name = "failure_reason", length = 500)
    private String failureReason;

    @Column(name = "refunded_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal refundedAmount = BigDecimal.ZERO;

    @Column(name = "refund_reason", length = 500)
    private String refundReason;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @Column(name = "user_agent", length = 500)
    private String userAgent;
}
EOF
echo -e "${GREEN}✓${NC} Payment.java"

cat > "$MODELS_DIR/Invoice.java" << 'EOF'
package com.healthcare.order.common.model;

import com.healthcare.order.common.constants.InvoiceStatus;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "invoices", indexes = {
    @Index(name = "idx_invoices_order_id", columnList = "order_id"),
    @Index(name = "idx_invoices_invoice_number", columnList = "invoice_number"),
    @Index(name = "idx_invoices_customer_id", columnList = "customer_id"),
    @Index(name = "idx_invoices_status", columnList = "status"),
    @Index(name = "idx_invoices_due_date", columnList = "due_date")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Invoice extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "invoice_number", nullable = false, unique = true, length = 30)
    private String invoiceNumber;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Column(name = "customer_name", nullable = false, length = 200)
    private String customerName;

    @Column(name = "customer_email", nullable = false, length = 200)
    private String customerEmail;

    @Column(name = "billing_address", columnDefinition = "TEXT")
    private String billingAddress;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    @Builder.Default
    private InvoiceStatus status = InvoiceStatus.DRAFT;

    @Column(name = "subtotal", nullable = false, precision = 10, scale = 2)
    private BigDecimal subtotal;

    @Column(name = "tax_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal taxAmount = BigDecimal.ZERO;

    @Column(name = "discount_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @Column(name = "total_amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "paid_amount", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal paidAmount = BigDecimal.ZERO;

    @Column(name = "balance_due", precision = 10, scale = 2)
    private BigDecimal balanceDue;

    @Column(name = "currency", nullable = false, length = 3)
    @Builder.Default
    private String currency = "USD";

    @Column(name = "issue_date", nullable = false)
    private LocalDate issueDate;

    @Column(name = "due_date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "paid_date")
    private LocalDate paidDate;

    @Column(name = "period_start")
    private LocalDate periodStart;

    @Column(name = "period_end")
    private LocalDate periodEnd;

    @Column(name = "sent_at")
    private LocalDateTime sentAt;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @OneToMany(mappedBy = "invoice", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private Set<InvoiceLineItem> lineItems = new HashSet<>();

    @PrePersist
    @PreUpdate
    public void calculateBalanceDue() {
        this.balanceDue = totalAmount.subtract(paidAmount != null ? paidAmount : BigDecimal.ZERO);
    }
}
EOF
echo -e "${GREEN}✓${NC} Invoice.java"

cat > "$MODELS_DIR/InvoiceLineItem.java" << 'EOF'
package com.healthcare.order.common.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "invoice_line_items", indexes = {
    @Index(name = "idx_invoice_line_items_invoice_id", columnList = "invoice_id")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceLineItem extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "invoice_id", nullable = false)
    private Invoice invoice;

    @Column(name = "description", nullable = false, length = 500)
    private String description;

    @Column(name = "quantity", nullable = false)
    @Builder.Default
    private Integer quantity = 1;

    @Column(name = "unit_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "plan_id")
    private UUID planId;

    @Column(name = "plan_code", length = 50)
    private String planCode;

    @PrePersist
    @PreUpdate
    public void calculateTotalPrice() {
        this.totalPrice = unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
}
EOF
echo -e "${GREEN}✓${NC} InvoiceLineItem.java"

cat > "$MODELS_DIR/SavedPaymentMethod.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} SavedPaymentMethod.java"

# =============================================================================
# DTOs
# =============================================================================
echo ""
echo -e "${CYAN}Creating DTOs...${NC}"

DTO_REQUEST_DIR="$BASE_DIR/order-common/src/main/java/com/healthcare/order/common/dto/request"
DTO_RESPONSE_DIR="$BASE_DIR/order-common/src/main/java/com/healthcare/order/common/dto/response"
mkdir -p "$DTO_REQUEST_DIR"
mkdir -p "$DTO_RESPONSE_DIR"

# Request DTOs
cat > "$DTO_REQUEST_DIR/CreateOrderRequest.java" << 'EOF'
package com.healthcare.order.common.dto.request;

import com.healthcare.order.common.constants.BillingFrequency;
import com.healthcare.order.common.constants.OrderType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateOrderRequest {

    @NotNull(message = "Customer ID is required")
    private UUID customerId;

    @NotNull(message = "Order type is required")
    private OrderType orderType;

    @NotNull(message = "Effective date is required")
    @FutureOrPresent(message = "Effective date must be today or in the future")
    private LocalDate effectiveDate;

    private BillingFrequency billingFrequency;

    @NotEmpty(message = "At least one order item is required")
    @Valid
    private List<OrderItemRequest> items;

    private String promoCode;

    private String notes;
}
EOF
echo -e "${GREEN}✓${NC} CreateOrderRequest.java"

cat > "$DTO_REQUEST_DIR/OrderItemRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} OrderItemRequest.java"

cat > "$DTO_REQUEST_DIR/ProcessPaymentRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} ProcessPaymentRequest.java"

cat > "$DTO_REQUEST_DIR/SavePaymentMethodRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} SavePaymentMethodRequest.java"

cat > "$DTO_REQUEST_DIR/OrderSearchRequest.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} OrderSearchRequest.java"

cat > "$DTO_REQUEST_DIR/RefundRequest.java" << 'EOF'
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
public class RefundRequest {

    @NotNull(message = "Payment ID is required")
    private UUID paymentId;

    @NotNull(message = "Refund amount is required")
    @DecimalMin(value = "0.01", message = "Refund amount must be greater than 0")
    private BigDecimal amount;

    @NotBlank(message = "Refund reason is required")
    @Size(max = 500)
    private String reason;
}
EOF
echo -e "${GREEN}✓${NC} RefundRequest.java"

# Response DTOs
cat > "$DTO_RESPONSE_DIR/OrderResponse.java" << 'EOF'
package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.BillingFrequency;
import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.constants.OrderType;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
public class OrderResponse {

    private UUID id;
    private String orderNumber;
    private UUID customerId;
    private String customerNumber;
    private String customerName;
    private String customerEmail;
    private OrderType orderType;
    private OrderStatus status;
    private BigDecimal subtotal;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;
    private BillingFrequency billingFrequency;
    private LocalDate effectiveDate;
    private LocalDate expirationDate;
    private String promoCode;
    private LocalDateTime submittedAt;
    private LocalDateTime completedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
EOF
echo -e "${GREEN}✓${NC} OrderResponse.java"

cat > "$DTO_RESPONSE_DIR/OrderDetailResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} OrderDetailResponse.java"

cat > "$DTO_RESPONSE_DIR/OrderItemResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} OrderItemResponse.java"

cat > "$DTO_RESPONSE_DIR/PaymentResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} PaymentResponse.java"

cat > "$DTO_RESPONSE_DIR/InvoiceSummaryResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} InvoiceSummaryResponse.java"

cat > "$DTO_RESPONSE_DIR/InvoiceDetailResponse.java" << 'EOF'
package com.healthcare.order.common.dto.response;

import com.healthcare.order.common.constants.InvoiceStatus;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceDetailResponse {

    private UUID id;
    private String invoiceNumber;
    private UUID orderId;
    private String orderNumber;
    private UUID customerId;
    private String customerName;
    private String customerEmail;
    private String billingAddress;
    private InvoiceStatus status;
    private BigDecimal subtotal;
    private BigDecimal taxAmount;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal balanceDue;
    private String currency;
    private LocalDate issueDate;
    private LocalDate dueDate;
    private LocalDate paidDate;
    private LocalDate periodStart;
    private LocalDate periodEnd;
    private LocalDateTime sentAt;
    private String notes;
    private List<InvoiceLineItemResponse> lineItems;
    private LocalDateTime createdAt;
}
EOF
echo -e "${GREEN}✓${NC} InvoiceDetailResponse.java"

cat > "$DTO_RESPONSE_DIR/InvoiceLineItemResponse.java" << 'EOF'
package com.healthcare.order.common.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InvoiceLineItemResponse {

    private UUID id;
    private String description;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private UUID planId;
    private String planCode;
}
EOF
echo -e "${GREEN}✓${NC} InvoiceLineItemResponse.java"

cat > "$DTO_RESPONSE_DIR/SavedPaymentMethodResponse.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} SavedPaymentMethodResponse.java"

cat > "$DTO_RESPONSE_DIR/PagedResponse.java" << 'EOF'
package com.healthcare.order.common.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PagedResponse<T> {

    private List<T> content;
    private Integer page;
    private Integer size;
    private Long totalElements;
    private Integer totalPages;
    private Boolean first;
    private Boolean last;
}
EOF
echo -e "${GREEN}✓${NC} PagedResponse.java"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Part 1 Complete - Constants, Entities, DTOs Created!                  ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run setup-order-service-java-part2.sh${NC}"