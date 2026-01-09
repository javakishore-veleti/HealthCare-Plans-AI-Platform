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
