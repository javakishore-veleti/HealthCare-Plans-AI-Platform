package com.healthcare.order.api.controller;

import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.request.SavePaymentMethodRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;
import com.healthcare.order.service.PaymentService;
import com.healthcare.order.service.SavedPaymentMethodService;
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
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payment", description = "Payment processing APIs")
public class PaymentController {

    private final PaymentService paymentService;
    private final SavedPaymentMethodService savedPaymentMethodService;

    @PostMapping
    @Operation(summary = "Process payment", description = "Process a payment for an order")
    public ResponseEntity<PaymentResponse> processPayment(
            @Valid @RequestBody ProcessPaymentRequest request) {
        PaymentResponse response = paymentService.processPayment(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{paymentId}")
    @Operation(summary = "Get payment", description = "Retrieve payment details")
    public ResponseEntity<PaymentResponse> getPaymentById(
            @Parameter(description = "Payment UUID") @PathVariable UUID paymentId) {
        PaymentResponse response = paymentService.getPaymentById(paymentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/order/{orderId}")
    @Operation(summary = "Get order payments", description = "Retrieve all payments for an order")
    public ResponseEntity<List<PaymentResponse>> getOrderPayments(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        List<PaymentResponse> responses = paymentService.getOrderPayments(orderId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/refund")
    @Operation(summary = "Refund payment", description = "Process a refund for a payment")
    public ResponseEntity<PaymentResponse> refundPayment(
            @Valid @RequestBody RefundRequest request) {
        PaymentResponse response = paymentService.refundPayment(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{paymentId}/retry")
    @Operation(summary = "Retry payment", description = "Retry a failed payment")
    public ResponseEntity<PaymentResponse> retryPayment(
            @Parameter(description = "Payment UUID") @PathVariable UUID paymentId) {
        PaymentResponse response = paymentService.retryPayment(paymentId);
        return ResponseEntity.ok(response);
    }

    // Saved Payment Methods
    @PostMapping("/methods")
    @Operation(summary = "Save payment method", description = "Save a payment method for future use")
    public ResponseEntity<SavedPaymentMethodResponse> savePaymentMethod(
            @Valid @RequestBody SavePaymentMethodRequest request) {
        SavedPaymentMethodResponse response = savedPaymentMethodService.savePaymentMethod(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/methods/customer/{customerId}")
    @Operation(summary = "Get saved payment methods", description = "Retrieve saved payment methods for a customer")
    public ResponseEntity<List<SavedPaymentMethodResponse>> getCustomerPaymentMethods(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<SavedPaymentMethodResponse> responses = savedPaymentMethodService.getCustomerPaymentMethods(customerId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/methods/{paymentMethodId}/default")
    @Operation(summary = "Set default payment method", description = "Set a payment method as default")
    public ResponseEntity<SavedPaymentMethodResponse> setDefaultPaymentMethod(
            @Parameter(description = "Customer UUID") @RequestParam UUID customerId,
            @Parameter(description = "Payment Method UUID") @PathVariable UUID paymentMethodId) {
        SavedPaymentMethodResponse response = savedPaymentMethodService.setDefaultPaymentMethod(customerId, paymentMethodId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/methods/{paymentMethodId}")
    @Operation(summary = "Delete payment method", description = "Delete a saved payment method")
    public ResponseEntity<Void> deletePaymentMethod(
            @Parameter(description = "Customer UUID") @RequestParam UUID customerId,
            @Parameter(description = "Payment Method UUID") @PathVariable UUID paymentMethodId) {
        savedPaymentMethodService.deletePaymentMethod(customerId, paymentMethodId);
        return ResponseEntity.noContent().build();
    }
}
