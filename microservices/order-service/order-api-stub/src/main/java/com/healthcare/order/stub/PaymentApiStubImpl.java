package com.healthcare.order.stub;

import com.healthcare.order.client.PaymentApiClient;
import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PaymentApiStubImpl implements PaymentApiClient {

    private final PaymentService paymentService;

    @Override
    public PaymentResponse processPayment(ProcessPaymentRequest request) {
        return paymentService.processPayment(request);
    }

    @Override
    public PaymentResponse getPaymentById(UUID paymentId) {
        return paymentService.getPaymentById(paymentId);
    }

    @Override
    public List<PaymentResponse> getOrderPayments(UUID orderId) {
        return paymentService.getOrderPayments(orderId);
    }

    @Override
    public PaymentResponse refundPayment(RefundRequest request) {
        return paymentService.refundPayment(request);
    }
}
