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
