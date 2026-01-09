package com.healthcare.order.api.controller;

import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;
import com.healthcare.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@Tag(name = "Order", description = "Order management APIs")
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @Operation(summary = "Create order", description = "Create a new order")
    public ResponseEntity<OrderDetailResponse> createOrder(
            @Valid @RequestBody CreateOrderRequest request) {
        OrderDetailResponse response = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{orderId}")
    @Operation(summary = "Get order by ID", description = "Retrieve order details by UUID")
    public ResponseEntity<OrderDetailResponse> getOrderById(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        OrderDetailResponse response = orderService.getOrderById(orderId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/number/{orderNumber}")
    @Operation(summary = "Get order by number", description = "Retrieve order by order number")
    public ResponseEntity<OrderDetailResponse> getOrderByNumber(
            @Parameter(description = "Order number") @PathVariable String orderNumber) {
        OrderDetailResponse response = orderService.getOrderByNumber(orderNumber);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer orders", description = "Retrieve all orders for a customer")
    public ResponseEntity<List<OrderResponse>> getCustomerOrders(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<OrderResponse> responses = orderService.getCustomerOrders(customerId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/search")
    @Operation(summary = "Search orders", description = "Search orders with filters and pagination")
    public ResponseEntity<PagedResponse<OrderResponse>> searchOrders(
            @Valid @RequestBody OrderSearchRequest request) {
        PagedResponse<OrderResponse> response = orderService.searchOrders(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{orderId}/submit")
    @Operation(summary = "Submit order", description = "Submit a draft order for payment")
    public ResponseEntity<OrderDetailResponse> submitOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        OrderDetailResponse response = orderService.submitOrder(orderId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{orderId}/cancel")
    @Operation(summary = "Cancel order", description = "Cancel an order")
    public ResponseEntity<OrderDetailResponse> cancelOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId,
            @RequestParam(required = false) String reason) {
        OrderDetailResponse response = orderService.cancelOrder(orderId, reason);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{orderId}/complete")
    @Operation(summary = "Complete order", description = "Mark order as completed")
    public ResponseEntity<OrderDetailResponse> completeOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        OrderDetailResponse response = orderService.completeOrder(orderId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{orderId}")
    @Operation(summary = "Delete order", description = "Delete a draft order")
    public ResponseEntity<Void> deleteOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        orderService.deleteOrder(orderId);
        return ResponseEntity.noContent().build();
    }
}
