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
        BigDecimal discount = BigDecimal.ZERO;
        int qty = request.getQuantity() != null ? request.getQuantity() : 1;

        BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(qty))
                .subtract(discount)
                .subtract(subsidy);

        return OrderItem.builder()
                .planId(request.getPlanId())
                .planCode("PLN-" + request.getPlanId().toString().substring(0, 8))
                .planName("Healthcare Plan") // TODO: Get from plan service
                .planYear(java.time.LocalDate.now().getYear())
                .metalTier("GOLD") // TODO: Get from plan service
                .description("Monthly healthcare plan premium")
                .quantity(qty)
                .unitPrice(unitPrice)
                .discountAmount(discount)
                .subsidyAmount(subsidy)
                .totalPrice(totalPrice)
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
