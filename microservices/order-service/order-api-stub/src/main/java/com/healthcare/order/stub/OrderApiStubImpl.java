package com.healthcare.order.stub;

import com.healthcare.order.client.OrderApiClient;
import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;
import com.healthcare.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OrderApiStubImpl implements OrderApiClient {

    private final OrderService orderService;

    @Override
    public OrderDetailResponse createOrder(CreateOrderRequest request) {
        return orderService.createOrder(request);
    }

    @Override
    public OrderDetailResponse getOrderById(UUID orderId) {
        return orderService.getOrderById(orderId);
    }

    @Override
    public OrderDetailResponse getOrderByNumber(String orderNumber) {
        return orderService.getOrderByNumber(orderNumber);
    }

    @Override
    public List<OrderResponse> getCustomerOrders(UUID customerId) {
        return orderService.getCustomerOrders(customerId);
    }

    @Override
    public PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request) {
        return orderService.searchOrders(request);
    }

    @Override
    public OrderDetailResponse submitOrder(UUID orderId) {
        return orderService.submitOrder(orderId);
    }

    @Override
    public OrderDetailResponse cancelOrder(UUID orderId, String reason) {
        return orderService.cancelOrder(orderId, reason);
    }
}
