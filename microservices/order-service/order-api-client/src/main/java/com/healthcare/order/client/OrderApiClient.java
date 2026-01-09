package com.healthcare.order.client;

import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;

import java.util.List;
import java.util.UUID;

public interface OrderApiClient {

    OrderDetailResponse createOrder(CreateOrderRequest request);

    OrderDetailResponse getOrderById(UUID orderId);

    OrderDetailResponse getOrderByNumber(String orderNumber);

    List<OrderResponse> getCustomerOrders(UUID customerId);

    PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request);

    OrderDetailResponse submitOrder(UUID orderId);

    OrderDetailResponse cancelOrder(UUID orderId, String reason);
}
