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
