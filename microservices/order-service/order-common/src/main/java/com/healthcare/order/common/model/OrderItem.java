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
        if (unitPrice == null) {
            unitPrice = BigDecimal.ZERO;
        }
        if (quantity == null) {
            quantity = 1;
        }
        if (discountAmount == null) {
            discountAmount = BigDecimal.ZERO;
        }
        if (subsidyAmount == null) {
            subsidyAmount = BigDecimal.ZERO;
        }

        BigDecimal basePrice = unitPrice.multiply(BigDecimal.valueOf(quantity));
        this.totalPrice = basePrice.subtract(discountAmount).subtract(subsidyAmount);

        if (this.totalPrice.compareTo(BigDecimal.ZERO) < 0) {
            this.totalPrice = BigDecimal.ZERO;
        }
    }
}
