#!/bin/bash

# =============================================================================
# Order Service - Java Source Files Generator (Part 2)
# =============================================================================
# Creates: Repositories, Specifications, Services, Mappers
# =============================================================================

set -e

BASE_DIR="microservices/order-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}          Order Service - Part 2 (DAO & Service Layers)                       ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# REPOSITORIES
# =============================================================================
echo -e "${CYAN}Creating Repositories...${NC}"

REPO_DIR="$BASE_DIR/order-dao/src/main/java/com/healthcare/order/dao/repository"
mkdir -p "$REPO_DIR"

cat > "$REPO_DIR/OrderRepository.java" << 'EOF'
package com.healthcare.order.dao.repository;

import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface OrderRepository extends JpaRepository<Order, UUID>, JpaSpecificationExecutor<Order> {

    Optional<Order> findByOrderNumber(String orderNumber);

    boolean existsByOrderNumber(String orderNumber);

    List<Order> findByCustomerId(UUID customerId);

    List<Order> findByCustomerIdAndStatus(UUID customerId, OrderStatus status);

    @Query("SELECT o FROM Order o LEFT JOIN FETCH o.items WHERE o.id = :id")
    Optional<Order> findByIdWithItems(@Param("id") UUID id);

    @Query("SELECT o FROM Order o " +
           "LEFT JOIN FETCH o.items " +
           "LEFT JOIN FETCH o.payments " +
           "WHERE o.id = :id")
    Optional<Order> findByIdWithDetails(@Param("id") UUID id);

    @Query("SELECT o FROM Order o WHERE o.customerId = :customerId AND o.status = :status " +
           "AND o.effectiveDate <= :date ORDER BY o.effectiveDate DESC")
    List<Order> findActiveOrders(@Param("customerId") UUID customerId,
                                  @Param("status") OrderStatus status,
                                  @Param("date") LocalDate date);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.customerId = :customerId AND o.status = :status")
    long countByCustomerIdAndStatus(@Param("customerId") UUID customerId, @Param("status") OrderStatus status);

    @Query("SELECT o FROM Order o WHERE o.status = :status AND o.createdAt < :cutoffDate")
    List<Order> findStaleOrders(@Param("status") OrderStatus status,
                                 @Param("cutoffDate") java.time.LocalDateTime cutoffDate);
}
EOF
echo -e "${GREEN}✓${NC} OrderRepository.java"

cat > "$REPO_DIR/OrderItemRepository.java" << 'EOF'
package com.healthcare.order.dao.repository;

import com.healthcare.order.common.model.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, UUID> {

    List<OrderItem> findByOrderId(UUID orderId);

    List<OrderItem> findByPlanId(UUID planId);

    void deleteByOrderId(UUID orderId);
}
EOF
echo -e "${GREEN}✓${NC} OrderItemRepository.java"

cat > "$REPO_DIR/PaymentRepository.java" << 'EOF'
package com.healthcare.order.dao.repository;

import com.healthcare.order.common.constants.PaymentStatus;
import com.healthcare.order.common.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    Optional<Payment> findByPaymentNumber(String paymentNumber);

    Optional<Payment> findByTransactionId(String transactionId);

    List<Payment> findByOrderId(UUID orderId);

    List<Payment> findByOrderIdAndStatus(UUID orderId, PaymentStatus status);

    @Query("SELECT SUM(p.amount) FROM Payment p WHERE p.order.id = :orderId AND p.status = 'COMPLETED'")
    BigDecimal getTotalPaidAmount(@Param("orderId") UUID orderId);

    @Query("SELECT p FROM Payment p WHERE p.status = :status AND p.createdAt < :cutoffDate")
    List<Payment> findStalePayments(@Param("status") PaymentStatus status,
                                     @Param("cutoffDate") LocalDateTime cutoffDate);

    @Query("SELECT p FROM Payment p JOIN FETCH p.order WHERE p.id = :id")
    Optional<Payment> findByIdWithOrder(@Param("id") UUID id);
}
EOF
echo -e "${GREEN}✓${NC} PaymentRepository.java"

cat > "$REPO_DIR/InvoiceRepository.java" << 'EOF'
package com.healthcare.order.dao.repository;

import com.healthcare.order.common.constants.InvoiceStatus;
import com.healthcare.order.common.model.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, UUID> {

    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    List<Invoice> findByOrderId(UUID orderId);

    List<Invoice> findByCustomerId(UUID customerId);

    List<Invoice> findByCustomerIdAndStatus(UUID customerId, InvoiceStatus status);

    @Query("SELECT i FROM Invoice i LEFT JOIN FETCH i.lineItems WHERE i.id = :id")
    Optional<Invoice> findByIdWithLineItems(@Param("id") UUID id);

    @Query("SELECT i FROM Invoice i WHERE i.status = 'SENT' AND i.dueDate < :today")
    List<Invoice> findOverdueInvoices(@Param("today") LocalDate today);

    @Query("SELECT i FROM Invoice i WHERE i.customerId = :customerId " +
           "AND i.status IN ('SENT', 'PARTIALLY_PAID', 'OVERDUE') " +
           "ORDER BY i.dueDate ASC")
    List<Invoice> findUnpaidInvoices(@Param("customerId") UUID customerId);
}
EOF
echo -e "${GREEN}✓${NC} InvoiceRepository.java"

cat > "$REPO_DIR/InvoiceLineItemRepository.java" << 'EOF'
package com.healthcare.order.dao.repository;

import com.healthcare.order.common.model.InvoiceLineItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface InvoiceLineItemRepository extends JpaRepository<InvoiceLineItem, UUID> {

    List<InvoiceLineItem> findByInvoiceId(UUID invoiceId);

    void deleteByInvoiceId(UUID invoiceId);
}
EOF
echo -e "${GREEN}✓${NC} InvoiceLineItemRepository.java"

cat > "$REPO_DIR/SavedPaymentMethodRepository.java" << 'EOF'
package com.healthcare.order.dao.repository;

import com.healthcare.order.common.model.SavedPaymentMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface SavedPaymentMethodRepository extends JpaRepository<SavedPaymentMethod, UUID> {

    List<SavedPaymentMethod> findByCustomerIdAndIsActiveTrue(UUID customerId);

    Optional<SavedPaymentMethod> findByCustomerIdAndIsDefaultTrue(UUID customerId);

    @Modifying
    @Query("UPDATE SavedPaymentMethod s SET s.isDefault = false WHERE s.customerId = :customerId")
    void clearDefaultPaymentMethods(@Param("customerId") UUID customerId);

    @Query("SELECT s FROM SavedPaymentMethod s WHERE s.customerId = :customerId AND s.isActive = true " +
           "ORDER BY s.isDefault DESC, s.createdAt DESC")
    List<SavedPaymentMethod> findActivePaymentMethods(@Param("customerId") UUID customerId);
}
EOF
echo -e "${GREEN}✓${NC} SavedPaymentMethodRepository.java"

# =============================================================================
# SPECIFICATIONS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Specifications...${NC}"

SPEC_DIR="$BASE_DIR/order-dao/src/main/java/com/healthcare/order/dao/specification"
mkdir -p "$SPEC_DIR"

cat > "$SPEC_DIR/OrderSpecification.java" << 'EOF'
package com.healthcare.order.dao.specification;

import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.model.Order;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class OrderSpecification {

    public static Specification<Order> buildSpecification(OrderSearchRequest request) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();

            if (request.getCustomerId() != null) {
                predicates.add(cb.equal(root.get("customerId"), request.getCustomerId()));
            }

            if (StringUtils.hasText(request.getOrderNumber())) {
                predicates.add(cb.equal(root.get("orderNumber"), request.getOrderNumber()));
            }

            if (request.getStatus() != null) {
                predicates.add(cb.equal(root.get("status"), request.getStatus()));
            }

            if (request.getOrderType() != null) {
                predicates.add(cb.equal(root.get("orderType"), request.getOrderType()));
            }

            if (request.getFromDate() != null) {
                predicates.add(cb.greaterThanOrEqualTo(root.get("createdAt"),
                    request.getFromDate().atStartOfDay()));
            }

            if (request.getToDate() != null) {
                predicates.add(cb.lessThanOrEqualTo(root.get("createdAt"),
                    request.getToDate().atTime(LocalTime.MAX)));
            }

            query.distinct(true);
            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderSpecification.java"

# =============================================================================
# SERVICES
# =============================================================================
echo ""
echo -e "${CYAN}Creating Services...${NC}"

SERVICE_DIR="$BASE_DIR/order-service-core/src/main/java/com/healthcare/order/service"
mkdir -p "$SERVICE_DIR"

cat > "$SERVICE_DIR/OrderService.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;

import java.util.List;
import java.util.UUID;

public interface OrderService {

    OrderDetailResponse createOrder(CreateOrderRequest request);

    OrderDetailResponse getOrderById(UUID orderId);

    OrderDetailResponse getOrderByNumber(String orderNumber);

    List<OrderResponse> getCustomerOrders(UUID customerId);

    PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request);

    OrderDetailResponse submitOrder(UUID orderId);

    OrderDetailResponse cancelOrder(UUID orderId, String reason);

    OrderDetailResponse completeOrder(UUID orderId);

    void deleteOrder(UUID orderId);
}
EOF
echo -e "${GREEN}✓${NC} OrderService.java"

cat > "$SERVICE_DIR/PaymentService.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;

import java.util.List;
import java.util.UUID;

public interface PaymentService {

    PaymentResponse processPayment(ProcessPaymentRequest request);

    PaymentResponse getPaymentById(UUID paymentId);

    List<PaymentResponse> getOrderPayments(UUID orderId);

    PaymentResponse refundPayment(RefundRequest request);

    PaymentResponse retryPayment(UUID paymentId);
}
EOF
echo -e "${GREEN}✓${NC} PaymentService.java"

cat > "$SERVICE_DIR/InvoiceService.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;

import java.util.List;
import java.util.UUID;

public interface InvoiceService {

    InvoiceDetailResponse generateInvoice(UUID orderId);

    InvoiceDetailResponse getInvoiceById(UUID invoiceId);

    InvoiceDetailResponse getInvoiceByNumber(String invoiceNumber);

    List<InvoiceSummaryResponse> getOrderInvoices(UUID orderId);

    List<InvoiceSummaryResponse> getCustomerInvoices(UUID customerId);

    List<InvoiceSummaryResponse> getUnpaidInvoices(UUID customerId);

    InvoiceDetailResponse sendInvoice(UUID invoiceId);

    InvoiceDetailResponse markAsPaid(UUID invoiceId);

    void cancelInvoice(UUID invoiceId);
}
EOF
echo -e "${GREEN}✓${NC} InvoiceService.java"

cat > "$SERVICE_DIR/SavedPaymentMethodService.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.dto.request.SavePaymentMethodRequest;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;

import java.util.List;
import java.util.UUID;

public interface SavedPaymentMethodService {

    SavedPaymentMethodResponse savePaymentMethod(SavePaymentMethodRequest request);

    List<SavedPaymentMethodResponse> getCustomerPaymentMethods(UUID customerId);

    SavedPaymentMethodResponse getDefaultPaymentMethod(UUID customerId);

    SavedPaymentMethodResponse setDefaultPaymentMethod(UUID customerId, UUID paymentMethodId);

    void deletePaymentMethod(UUID customerId, UUID paymentMethodId);
}
EOF
echo -e "${GREEN}✓${NC} SavedPaymentMethodService.java"

# Service Implementations
cat > "$SERVICE_DIR/OrderServiceImpl.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderItemRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;
import com.healthcare.order.common.model.Order;
import com.healthcare.order.common.model.OrderItem;
import com.healthcare.order.dao.repository.OrderRepository;
import com.healthcare.order.dao.specification.OrderSpecification;
import com.healthcare.order.service.mapper.OrderMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final OrderMapper orderMapper;

    // TODO: Inject Plan and Customer API clients
    // private final PlanApiClient planApiClient;
    // private final CustomerApiClient customerApiClient;

    @Override
    public OrderDetailResponse createOrder(CreateOrderRequest request) {
        log.info("Creating order for customer: {}", request.getCustomerId());

        // TODO: Fetch customer details from customer-service
        // CustomerDetailResponse customer = customerApiClient.getCustomerById(request.getCustomerId());

        Order order = Order.builder()
            .orderNumber(generateOrderNumber())
            .customerId(request.getCustomerId())
            .customerNumber("CUS" + request.getCustomerId().toString().substring(0, 8))
            .customerName("Customer Name") // TODO: Get from customer service
            .customerEmail("customer@example.com") // TODO: Get from customer service
            .orderType(request.getOrderType())
            .status(OrderStatus.DRAFT)
            .billingFrequency(request.getBillingFrequency() != null ? 
                request.getBillingFrequency() : 
                com.healthcare.order.common.constants.BillingFrequency.MONTHLY)
            .effectiveDate(request.getEffectiveDate())
            .promoCode(request.getPromoCode())
            .notes(request.getNotes())
            .build();

        // Add items
        for (OrderItemRequest itemRequest : request.getItems()) {
            OrderItem item = createOrderItem(itemRequest);
            order.addItem(item);
        }

        // Apply promo code discount if applicable
        if (StringUtils.hasText(request.getPromoCode())) {
            applyPromoCode(order, request.getPromoCode());
        }

        Order savedOrder = orderRepository.save(order);
        log.info("Created order: {} with {} items", savedOrder.getOrderNumber(), savedOrder.getItems().size());

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    @Transactional(readOnly = true)
    public OrderDetailResponse getOrderById(UUID orderId) {
        Order order = orderRepository.findByIdWithDetails(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
        return orderMapper.toDetailResponse(order);
    }

    @Override
    @Transactional(readOnly = true)
    public OrderDetailResponse getOrderByNumber(String orderNumber) {
        Order order = orderRepository.findByOrderNumber(orderNumber)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderNumber));
        return orderMapper.toDetailResponse(order);
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrderResponse> getCustomerOrders(UUID customerId) {
        return orderRepository.findByCustomerId(customerId).stream()
            .map(orderMapper::toResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request) {
        Sort sort = buildSort(request.getSortBy(), request.getSortDirection());
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize(), sort);

        Page<Order> orderPage = orderRepository.findAll(
            OrderSpecification.buildSpecification(request), pageable);

        return PagedResponse.<OrderResponse>builder()
            .content(orderPage.getContent().stream()
                .map(orderMapper::toResponse)
                .collect(Collectors.toList()))
            .page(orderPage.getNumber())
            .size(orderPage.getSize())
            .totalElements(orderPage.getTotalElements())
            .totalPages(orderPage.getTotalPages())
            .first(orderPage.isFirst())
            .last(orderPage.isLast())
            .build();
    }

    @Override
    public OrderDetailResponse submitOrder(UUID orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only draft orders can be submitted");
        }

        if (order.getItems().isEmpty()) {
            throw new IllegalStateException("Cannot submit order with no items");
        }

        order.setStatus(OrderStatus.PENDING_PAYMENT);
        order.setSubmittedAt(LocalDateTime.now());

        Order savedOrder = orderRepository.save(order);
        log.info("Submitted order: {}", savedOrder.getOrderNumber());

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    public OrderDetailResponse cancelOrder(UUID orderId, String reason) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() == OrderStatus.COMPLETED || order.getStatus() == OrderStatus.CANCELLED) {
            throw new IllegalStateException("Cannot cancel order in status: " + order.getStatus());
        }

        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelledAt(LocalDateTime.now());
        order.setCancellationReason(reason);

        Order savedOrder = orderRepository.save(order);
        log.info("Cancelled order: {} - Reason: {}", savedOrder.getOrderNumber(), reason);

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    public OrderDetailResponse completeOrder(UUID orderId) {
        Order order = orderRepository.findByIdWithDetails(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getBalanceDue().compareTo(BigDecimal.ZERO) > 0) {
            throw new IllegalStateException("Order has outstanding balance: " + order.getBalanceDue());
        }

        order.setStatus(OrderStatus.COMPLETED);
        order.setCompletedAt(LocalDateTime.now());

        Order savedOrder = orderRepository.save(order);
        log.info("Completed order: {}", savedOrder.getOrderNumber());

        // TODO: Trigger enrollment in customer-service
        // customerApiClient.enrollCustomer(order.getCustomerId(), enrollmentRequest);

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    public void deleteOrder(UUID orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only draft orders can be deleted");
        }

        orderRepository.delete(order);
        log.info("Deleted order: {}", orderId);
    }

    private OrderItem createOrderItem(OrderItemRequest request) {
        // TODO: Fetch plan details from plans-service
        // PlanDetailResponse plan = planApiClient.getPlanById(request.getPlanId());

        BigDecimal unitPrice = BigDecimal.valueOf(350.00); // TODO: Get from plan service
        BigDecimal subsidy = request.getSubsidyAmount() != null ? request.getSubsidyAmount() : BigDecimal.ZERO;

        return OrderItem.builder()
            .planId(request.getPlanId())
            .planCode("PLN-" + request.getPlanId().toString().substring(0, 8))
            .planName("Healthcare Plan") // TODO: Get from plan service
            .planYear(java.time.LocalDate.now().getYear())
            .metalTier("GOLD") // TODO: Get from plan service
            .description("Monthly healthcare plan premium")
            .quantity(request.getQuantity() != null ? request.getQuantity() : 1)
            .unitPrice(unitPrice)
            .subsidyAmount(subsidy)
            .includeDependents(Boolean.TRUE.equals(request.getIncludeDependents()))
            .dependentCount(0)
            .build();
    }

    private void applyPromoCode(Order order, String promoCode) {
        // TODO: Validate promo code and apply discount
        // For now, apply a simple 10% discount for any code
        BigDecimal discount = order.getSubtotal().multiply(BigDecimal.valueOf(0.10));
        order.setDiscountAmount(discount);
        order.recalculateTotals();
        log.info("Applied promo code {} - Discount: {}", promoCode, discount);
    }

    private String generateOrderNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = (int) (Math.random() * 1000);
        return String.format("ORD-%s-%03d", timestamp, random);
    }

    private Sort buildSort(String sortBy, String sortDirection) {
        String field = StringUtils.hasText(sortBy) ? sortBy : "createdAt";
        Sort.Direction direction = "asc".equalsIgnoreCase(sortDirection) ? Sort.Direction.ASC : Sort.Direction.DESC;
        return Sort.by(direction, field);
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderServiceImpl.java"

cat > "$SERVICE_DIR/PaymentServiceImpl.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.constants.CardBrand;
import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.constants.PaymentStatus;
import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.common.model.Order;
import com.healthcare.order.common.model.Payment;
import com.healthcare.order.common.model.SavedPaymentMethod;
import com.healthcare.order.dao.repository.OrderRepository;
import com.healthcare.order.dao.repository.PaymentRepository;
import com.healthcare.order.dao.repository.SavedPaymentMethodRepository;
import com.healthcare.order.service.mapper.PaymentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class PaymentServiceImpl implements PaymentService {

    private final PaymentRepository paymentRepository;
    private final OrderRepository orderRepository;
    private final SavedPaymentMethodRepository savedPaymentMethodRepository;
    private final PaymentMapper paymentMapper;

    @Override
    public PaymentResponse processPayment(ProcessPaymentRequest request) {
        Order order = orderRepository.findById(request.getOrderId())
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + request.getOrderId()));

        if (order.getStatus() != OrderStatus.PENDING_PAYMENT && 
            order.getStatus() != OrderStatus.PAYMENT_FAILED) {
            throw new IllegalStateException("Order is not awaiting payment: " + order.getStatus());
        }

        if (request.getAmount().compareTo(order.getBalanceDue()) > 0) {
            throw new IllegalArgumentException("Payment amount exceeds balance due");
        }

        Payment payment = Payment.builder()
            .order(order)
            .paymentNumber(generatePaymentNumber())
            .paymentMethod(request.getPaymentMethod())
            .amount(request.getAmount())
            .status(PaymentStatus.PROCESSING)
            .build();

        // Use saved payment method or new details
        if (request.getSavedPaymentMethodId() != null) {
            SavedPaymentMethod saved = savedPaymentMethodRepository.findById(request.getSavedPaymentMethodId())
                .orElseThrow(() -> new IllegalArgumentException("Saved payment method not found"));
            
            payment.setCardBrand(saved.getCardBrand());
            payment.setCardLast4(saved.getCardLast4());
            payment.setCardExpiryMonth(saved.getCardExpiryMonth());
            payment.setCardExpiryYear(saved.getCardExpiryYear());
            payment.setBillingName(saved.getCardholderName());
            payment.setBankName(saved.getBankName());
            payment.setAccountLast4(saved.getAccountLast4());
        } else if (request.getCardNumber() != null) {
            payment.setCardBrand(detectCardBrand(request.getCardNumber()));
            payment.setCardLast4(request.getCardNumber().substring(request.getCardNumber().length() - 4));
            payment.setCardExpiryMonth(request.getCardExpiryMonth());
            payment.setCardExpiryYear(request.getCardExpiryYear());
            payment.setBillingName(request.getCardholderName());
            payment.setBillingZip(request.getBillingZip());
        } else if (request.getAccountNumber() != null) {
            payment.setAccountLast4(request.getAccountNumber().substring(request.getAccountNumber().length() - 4));
            payment.setRoutingLast4(request.getRoutingNumber().substring(request.getRoutingNumber().length() - 4));
            payment.setBillingName(request.getAccountHolderName());
        }

        // Simulate payment processing
        boolean paymentSuccess = simulatePaymentProcessing(payment);

        if (paymentSuccess) {
            payment.setStatus(PaymentStatus.COMPLETED);
            payment.setProcessedAt(LocalDateTime.now());
            payment.setTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase());

            // Update order status
            order.setStatus(OrderStatus.CONFIRMED);
            if (order.getBalanceDue().subtract(request.getAmount()).compareTo(BigDecimal.ZERO) <= 0) {
                order.setStatus(OrderStatus.PROCESSING);
            }
        } else {
            payment.setStatus(PaymentStatus.FAILED);
            payment.setFailedAt(LocalDateTime.now());
            payment.setFailureReason("Payment declined by processor");
            order.setStatus(OrderStatus.PAYMENT_FAILED);
        }

        orderRepository.save(order);
        Payment savedPayment = paymentRepository.save(payment);

        log.info("Processed payment {} for order {} - Status: {}", 
            savedPayment.getPaymentNumber(), order.getOrderNumber(), savedPayment.getStatus());

        return paymentMapper.toResponse(savedPayment);
    }

    @Override
    @Transactional(readOnly = true)
    public PaymentResponse getPaymentById(UUID paymentId) {
        Payment payment = paymentRepository.findById(paymentId)
            .orElseThrow(() -> new IllegalArgumentException("Payment not found: " + paymentId));
        return paymentMapper.toResponse(payment);
    }

    @Override
    @Transactional(readOnly = true)
    public List<PaymentResponse> getOrderPayments(UUID orderId) {
        return paymentRepository.findByOrderId(orderId).stream()
            .map(paymentMapper::toResponse)
            .collect(Collectors.toList());
    }

    @Override
    public PaymentResponse refundPayment(RefundRequest request) {
        Payment payment = paymentRepository.findByIdWithOrder(request.getPaymentId())
            .orElseThrow(() -> new IllegalArgumentException("Payment not found: " + request.getPaymentId()));

        if (payment.getStatus() != PaymentStatus.COMPLETED) {
            throw new IllegalStateException("Can only refund completed payments");
        }

        BigDecimal availableForRefund = payment.getAmount().subtract(
            payment.getRefundedAmount() != null ? payment.getRefundedAmount() : BigDecimal.ZERO);

        if (request.getAmount().compareTo(availableForRefund) > 0) {
            throw new IllegalArgumentException("Refund amount exceeds available amount");
        }

        // Process refund
        BigDecimal newRefundedAmount = (payment.getRefundedAmount() != null ? 
            payment.getRefundedAmount() : BigDecimal.ZERO).add(request.getAmount());
        
        payment.setRefundedAmount(newRefundedAmount);
        payment.setRefundReason(request.getReason());

        if (newRefundedAmount.compareTo(payment.getAmount()) >= 0) {
            payment.setStatus(PaymentStatus.REFUNDED);
        } else {
            payment.setStatus(PaymentStatus.PARTIALLY_REFUNDED);
        }

        // Update order status if fully refunded
        Order order = payment.getOrder();
        if (payment.getStatus() == PaymentStatus.REFUNDED) {
            order.setStatus(OrderStatus.REFUNDED);
            orderRepository.save(order);
        }

        Payment savedPayment = paymentRepository.save(payment);
        log.info("Refunded {} for payment {} - Reason: {}", 
            request.getAmount(), savedPayment.getPaymentNumber(), request.getReason());

        return paymentMapper.toResponse(savedPayment);
    }

    @Override
    public PaymentResponse retryPayment(UUID paymentId) {
        Payment failedPayment = paymentRepository.findByIdWithOrder(paymentId)
            .orElseThrow(() -> new IllegalArgumentException("Payment not found: " + paymentId));

        if (failedPayment.getStatus() != PaymentStatus.FAILED) {
            throw new IllegalStateException("Can only retry failed payments");
        }

        // Create a new payment attempt
        Payment newPayment = Payment.builder()
            .order(failedPayment.getOrder())
            .paymentNumber(generatePaymentNumber())
            .paymentMethod(failedPayment.getPaymentMethod())
            .amount(failedPayment.getAmount())
            .status(PaymentStatus.PROCESSING)
            .cardBrand(failedPayment.getCardBrand())
            .cardLast4(failedPayment.getCardLast4())
            .cardExpiryMonth(failedPayment.getCardExpiryMonth())
            .cardExpiryYear(failedPayment.getCardExpiryYear())
            .billingName(failedPayment.getBillingName())
            .billingZip(failedPayment.getBillingZip())
            .bankName(failedPayment.getBankName())
            .accountLast4(failedPayment.getAccountLast4())
            .build();

        // Simulate retry
        boolean success = simulatePaymentProcessing(newPayment);
        
        if (success) {
            newPayment.setStatus(PaymentStatus.COMPLETED);
            newPayment.setProcessedAt(LocalDateTime.now());
            newPayment.setTransactionId("TXN-" + UUID.randomUUID().toString().substring(0, 12).toUpperCase());
            
            Order order = failedPayment.getOrder();
            order.setStatus(OrderStatus.CONFIRMED);
            orderRepository.save(order);
        } else {
            newPayment.setStatus(PaymentStatus.FAILED);
            newPayment.setFailedAt(LocalDateTime.now());
            newPayment.setFailureReason("Payment declined on retry");
        }

        Payment savedPayment = paymentRepository.save(newPayment);
        return paymentMapper.toResponse(savedPayment);
    }

    private boolean simulatePaymentProcessing(Payment payment) {
        // Simulate 95% success rate
        return Math.random() > 0.05;
    }

    private CardBrand detectCardBrand(String cardNumber) {
        if (cardNumber.startsWith("4")) return CardBrand.VISA;
        if (cardNumber.startsWith("5")) return CardBrand.MASTERCARD;
        if (cardNumber.startsWith("34") || cardNumber.startsWith("37")) return CardBrand.AMERICAN_EXPRESS;
        if (cardNumber.startsWith("6")) return CardBrand.DISCOVER;
        return CardBrand.OTHER;
    }

    private String generatePaymentNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = (int) (Math.random() * 1000);
        return String.format("PAY-%s-%03d", timestamp, random);
    }
}
EOF
echo -e "${GREEN}✓${NC} PaymentServiceImpl.java"

cat > "$SERVICE_DIR/InvoiceServiceImpl.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.constants.InvoiceStatus;
import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;
import com.healthcare.order.common.model.*;
import com.healthcare.order.dao.repository.InvoiceRepository;
import com.healthcare.order.dao.repository.OrderRepository;
import com.healthcare.order.service.mapper.InvoiceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class InvoiceServiceImpl implements InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final OrderRepository orderRepository;
    private final InvoiceMapper invoiceMapper;

    @Override
    public InvoiceDetailResponse generateInvoice(UUID orderId) {
        Order order = orderRepository.findByIdWithDetails(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        Invoice invoice = Invoice.builder()
            .order(order)
            .invoiceNumber(generateInvoiceNumber())
            .customerId(order.getCustomerId())
            .customerName(order.getCustomerName())
            .customerEmail(order.getCustomerEmail())
            .status(InvoiceStatus.DRAFT)
            .subtotal(order.getSubtotal())
            .taxAmount(order.getTaxAmount())
            .discountAmount(order.getDiscountAmount())
            .totalAmount(order.getTotalAmount())
            .issueDate(LocalDate.now())
            .dueDate(LocalDate.now().plusDays(30))
            .periodStart(order.getEffectiveDate())
            .periodEnd(order.getEffectiveDate().plusMonths(1).minusDays(1))
            .build();

        // Add line items from order items
        for (OrderItem orderItem : order.getItems()) {
            InvoiceLineItem lineItem = InvoiceLineItem.builder()
                .invoice(invoice)
                .description(orderItem.getPlanName() + " - " + orderItem.getDescription())
                .quantity(orderItem.getQuantity())
                .unitPrice(orderItem.getUnitPrice())
                .totalPrice(orderItem.getTotalPrice())
                .planId(orderItem.getPlanId())
                .planCode(orderItem.getPlanCode())
                .build();
            invoice.getLineItems().add(lineItem);
        }

        Invoice savedInvoice = invoiceRepository.save(invoice);
        log.info("Generated invoice {} for order {}", savedInvoice.getInvoiceNumber(), order.getOrderNumber());

        return invoiceMapper.toDetailResponse(savedInvoice);
    }

    @Override
    @Transactional(readOnly = true)
    public InvoiceDetailResponse getInvoiceById(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findByIdWithLineItems(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));
        return invoiceMapper.toDetailResponse(invoice);
    }

    @Override
    @Transactional(readOnly = true)
    public InvoiceDetailResponse getInvoiceByNumber(String invoiceNumber) {
        Invoice invoice = invoiceRepository.findByInvoiceNumber(invoiceNumber)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceNumber));
        return invoiceMapper.toDetailResponse(invoice);
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceSummaryResponse> getOrderInvoices(UUID orderId) {
        return invoiceRepository.findByOrderId(orderId).stream()
            .map(invoiceMapper::toSummaryResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceSummaryResponse> getCustomerInvoices(UUID customerId) {
        return invoiceRepository.findByCustomerId(customerId).stream()
            .map(invoiceMapper::toSummaryResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<InvoiceSummaryResponse> getUnpaidInvoices(UUID customerId) {
        return invoiceRepository.findUnpaidInvoices(customerId).stream()
            .map(invoiceMapper::toSummaryResponse)
            .collect(Collectors.toList());
    }

    @Override
    public InvoiceDetailResponse sendInvoice(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        if (invoice.getStatus() != InvoiceStatus.DRAFT) {
            throw new IllegalStateException("Only draft invoices can be sent");
        }

        invoice.setStatus(InvoiceStatus.SENT);
        invoice.setSentAt(LocalDateTime.now());

        // TODO: Send email notification
        // emailService.sendInvoice(invoice);

        Invoice savedInvoice = invoiceRepository.save(invoice);
        log.info("Sent invoice {} to {}", savedInvoice.getInvoiceNumber(), savedInvoice.getCustomerEmail());

        return invoiceMapper.toDetailResponse(savedInvoice);
    }

    @Override
    public InvoiceDetailResponse markAsPaid(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        invoice.setStatus(InvoiceStatus.PAID);
        invoice.setPaidAmount(invoice.getTotalAmount());
        invoice.setPaidDate(LocalDate.now());

        Invoice savedInvoice = invoiceRepository.save(invoice);
        log.info("Marked invoice {} as paid", savedInvoice.getInvoiceNumber());

        return invoiceMapper.toDetailResponse(savedInvoice);
    }

    @Override
    public void cancelInvoice(UUID invoiceId) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Invoice not found: " + invoiceId));

        if (invoice.getStatus() == InvoiceStatus.PAID) {
            throw new IllegalStateException("Cannot cancel paid invoices");
        }

        invoice.setStatus(InvoiceStatus.CANCELLED);
        invoiceRepository.save(invoice);
        log.info("Cancelled invoice {}", invoice.getInvoiceNumber());
    }

    private String generateInvoiceNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        int random = (int) (Math.random() * 10000);
        return String.format("INV-%s-%04d", timestamp, random);
    }
}
EOF
echo -e "${GREEN}✓${NC} InvoiceServiceImpl.java"

cat > "$SERVICE_DIR/SavedPaymentMethodServiceImpl.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.order.common.constants.CardBrand;
import com.healthcare.order.common.dto.request.SavePaymentMethodRequest;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;
import com.healthcare.order.common.model.SavedPaymentMethod;
import com.healthcare.order.dao.repository.SavedPaymentMethodRepository;
import com.healthcare.order.service.mapper.PaymentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class SavedPaymentMethodServiceImpl implements SavedPaymentMethodService {

    private final SavedPaymentMethodRepository repository;
    private final PaymentMapper paymentMapper;

    @Override
    public SavedPaymentMethodResponse savePaymentMethod(SavePaymentMethodRequest request) {
        SavedPaymentMethod method = SavedPaymentMethod.builder()
            .customerId(request.getCustomerId())
            .nickname(request.getNickname())
            .paymentMethod(request.getPaymentMethod())
            .isDefault(Boolean.TRUE.equals(request.getIsDefault()))
            .isActive(true)
            .billingZip(request.getBillingZip())
            .build();

        if (request.getCardNumber() != null) {
            method.setCardBrand(detectCardBrand(request.getCardNumber()));
            method.setCardLast4(request.getCardNumber().substring(request.getCardNumber().length() - 4));
            method.setCardExpiryMonth(request.getCardExpiryMonth());
            method.setCardExpiryYear(request.getCardExpiryYear());
            method.setCardholderName(request.getCardholderName());
            method.setGatewayToken("tok_" + UUID.randomUUID().toString().replace("-", "").substring(0, 24));
        }

        if (request.getAccountNumber() != null) {
            method.setBankName(request.getBankName());
            method.setAccountType(request.getAccountType());
            method.setAccountLast4(request.getAccountNumber().substring(request.getAccountNumber().length() - 4));
            method.setRoutingLast4(request.getRoutingNumber().substring(request.getRoutingNumber().length() - 4));
        }

        if (Boolean.TRUE.equals(request.getIsDefault())) {
            repository.clearDefaultPaymentMethods(request.getCustomerId());
        }

        SavedPaymentMethod saved = repository.save(method);
        log.info("Saved payment method {} for customer {}", saved.getId(), request.getCustomerId());

        return paymentMapper.toSavedPaymentMethodResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SavedPaymentMethodResponse> getCustomerPaymentMethods(UUID customerId) {
        return repository.findActivePaymentMethods(customerId).stream()
            .map(paymentMapper::toSavedPaymentMethodResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public SavedPaymentMethodResponse getDefaultPaymentMethod(UUID customerId) {
        return repository.findByCustomerIdAndIsDefaultTrue(customerId)
            .map(paymentMapper::toSavedPaymentMethodResponse)
            .orElse(null);
    }

    @Override
    public SavedPaymentMethodResponse setDefaultPaymentMethod(UUID customerId, UUID paymentMethodId) {
        SavedPaymentMethod method = repository.findById(paymentMethodId)
            .orElseThrow(() -> new IllegalArgumentException("Payment method not found"));

        if (!method.getCustomerId().equals(customerId)) {
            throw new IllegalArgumentException("Payment method does not belong to customer");
        }

        repository.clearDefaultPaymentMethods(customerId);
        method.setIsDefault(true);
        
        SavedPaymentMethod saved = repository.save(method);
        return paymentMapper.toSavedPaymentMethodResponse(saved);
    }

    @Override
    public void deletePaymentMethod(UUID customerId, UUID paymentMethodId) {
        SavedPaymentMethod method = repository.findById(paymentMethodId)
            .orElseThrow(() -> new IllegalArgumentException("Payment method not found"));

        if (!method.getCustomerId().equals(customerId)) {
            throw new IllegalArgumentException("Payment method does not belong to customer");
        }

        method.setIsActive(false);
        repository.save(method);
        log.info("Deactivated payment method {} for customer {}", paymentMethodId, customerId);
    }

    private CardBrand detectCardBrand(String cardNumber) {
        if (cardNumber.startsWith("4")) return CardBrand.VISA;
        if (cardNumber.startsWith("5")) return CardBrand.MASTERCARD;
        if (cardNumber.startsWith("34") || cardNumber.startsWith("37")) return CardBrand.AMERICAN_EXPRESS;
        if (cardNumber.startsWith("6")) return CardBrand.DISCOVER;
        return CardBrand.OTHER;
    }
}
EOF
echo -e "${GREEN}✓${NC} SavedPaymentMethodServiceImpl.java"

# =============================================================================
# MAPPERS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Mappers...${NC}"

MAPPER_DIR="$BASE_DIR/order-service-core/src/main/java/com/healthcare/order/service/mapper"
mkdir -p "$MAPPER_DIR"

cat > "$MAPPER_DIR/OrderMapper.java" << 'EOF'
package com.healthcare.order.service.mapper;

import com.healthcare.order.common.dto.response.*;
import com.healthcare.order.common.model.*;
import org.mapstruct.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface OrderMapper {

    @Mapping(target = "paidAmount", expression = "java(order.getPaidAmount())")
    @Mapping(target = "balanceDue", expression = "java(order.getBalanceDue())")
    OrderResponse toResponse(Order order);

    @Mapping(target = "paidAmount", expression = "java(order.getPaidAmount())")
    @Mapping(target = "balanceDue", expression = "java(order.getBalanceDue())")
    @Mapping(target = "items", source = "items")
    @Mapping(target = "payments", source = "payments")
    @Mapping(target = "invoices", source = "invoices")
    OrderDetailResponse toDetailResponse(Order order);

    OrderItemResponse toOrderItemResponse(OrderItem item);

    default List<OrderItemResponse> mapItems(Set<OrderItem> items) {
        if (items == null) return null;
        return items.stream().map(this::toOrderItemResponse).collect(Collectors.toList());
    }

    default List<PaymentResponse> mapPayments(Set<Payment> payments) {
        if (payments == null) return null;
        return payments.stream().map(this::toPaymentResponse).collect(Collectors.toList());
    }

    default List<InvoiceSummaryResponse> mapInvoices(Set<Invoice> invoices) {
        if (invoices == null) return null;
        return invoices.stream().map(this::toInvoiceSummaryResponse).collect(Collectors.toList());
    }

    PaymentResponse toPaymentResponse(Payment payment);

    InvoiceSummaryResponse toInvoiceSummaryResponse(Invoice invoice);
}
EOF
echo -e "${GREEN}✓${NC} OrderMapper.java"

cat > "$MAPPER_DIR/PaymentMapper.java" << 'EOF'
package com.healthcare.order.service.mapper;

import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;
import com.healthcare.order.common.model.Payment;
import com.healthcare.order.common.model.SavedPaymentMethod;
import org.mapstruct.*;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface PaymentMapper {

    PaymentResponse toResponse(Payment payment);

    SavedPaymentMethodResponse toSavedPaymentMethodResponse(SavedPaymentMethod method);
}
EOF
echo -e "${GREEN}✓${NC} PaymentMapper.java"

cat > "$MAPPER_DIR/InvoiceMapper.java" << 'EOF'
package com.healthcare.order.service.mapper;

import com.healthcare.order.common.dto.response.*;
import com.healthcare.order.common.model.*;
import org.mapstruct.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface InvoiceMapper {

    InvoiceSummaryResponse toSummaryResponse(Invoice invoice);

    @Mapping(target = "orderId", source = "order.id")
    @Mapping(target = "orderNumber", source = "order.orderNumber")
    @Mapping(target = "lineItems", source = "lineItems")
    InvoiceDetailResponse toDetailResponse(Invoice invoice);

    InvoiceLineItemResponse toLineItemResponse(InvoiceLineItem item);

    default List<InvoiceLineItemResponse> mapLineItems(Set<InvoiceLineItem> items) {
        if (items == null) return null;
        return items.stream().map(this::toLineItemResponse).collect(Collectors.toList());
    }
}
EOF
echo -e "${GREEN}✓${NC} InvoiceMapper.java"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Part 2 Complete - DAO & Service Layers Created!                       ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run setup-order-service-java-part3.sh${NC}"