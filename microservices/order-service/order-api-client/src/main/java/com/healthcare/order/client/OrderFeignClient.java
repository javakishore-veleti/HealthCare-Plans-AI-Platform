package com.healthcare.order.client;

import com.healthcare.order.common.dto.request.*;
import com.healthcare.order.common.dto.response.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "order-service", url = "${order.service.url:http://localhost:8084}")
public interface OrderFeignClient extends OrderApiClient, PaymentApiClient, InvoiceApiClient {

    // Order endpoints
    @Override
    @PostMapping("/api/v1/orders")
    OrderDetailResponse createOrder(@RequestBody CreateOrderRequest request);

    @Override
    @GetMapping("/api/v1/orders/{orderId}")
    OrderDetailResponse getOrderById(@PathVariable("orderId") UUID orderId);

    @Override
    @GetMapping("/api/v1/orders/number/{orderNumber}")
    OrderDetailResponse getOrderByNumber(@PathVariable("orderNumber") String orderNumber);

    @Override
    @GetMapping("/api/v1/orders/customer/{customerId}")
    List<OrderResponse> getCustomerOrders(@PathVariable("customerId") UUID customerId);

    @Override
    @PostMapping("/api/v1/orders/search")
    PagedResponse<OrderResponse> searchOrders(@RequestBody OrderSearchRequest request);

    @Override
    @PostMapping("/api/v1/orders/{orderId}/submit")
    OrderDetailResponse submitOrder(@PathVariable("orderId") UUID orderId);

    @Override
    @PostMapping("/api/v1/orders/{orderId}/cancel")
    OrderDetailResponse cancelOrder(@PathVariable("orderId") UUID orderId,
                                    @RequestParam(required = false) String reason);

    // Payment endpoints
    @Override
    @PostMapping("/api/v1/payments")
    PaymentResponse processPayment(@RequestBody ProcessPaymentRequest request);

    @Override
    @GetMapping("/api/v1/payments/{paymentId}")
    PaymentResponse getPaymentById(@PathVariable("paymentId") UUID paymentId);

    @Override
    @GetMapping("/api/v1/orders/{orderId}/payments")
    List<PaymentResponse> getOrderPayments(@PathVariable("orderId") UUID orderId);

    @Override
    @PostMapping("/api/v1/payments/refund")
    PaymentResponse refundPayment(@RequestBody RefundRequest request);

    // Invoice endpoints
    @Override
    @PostMapping("/api/v1/orders/{orderId}/invoices")
    InvoiceDetailResponse generateInvoice(@PathVariable("orderId") UUID orderId);

    @Override
    @GetMapping("/api/v1/invoices/{invoiceId}")
    InvoiceDetailResponse getInvoiceById(@PathVariable("invoiceId") UUID invoiceId);

    @Override
    @GetMapping("/api/v1/invoices/customer/{customerId}")
    List<InvoiceSummaryResponse> getCustomerInvoices(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/invoices/customer/{customerId}/unpaid")
    List<InvoiceSummaryResponse> getUnpaidInvoices(@PathVariable("customerId") UUID customerId);

    @Override
    @PostMapping("/api/v1/invoices/{invoiceId}/send")
    InvoiceDetailResponse sendInvoice(@PathVariable("invoiceId") UUID invoiceId);
}
