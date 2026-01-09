package com.healthcare.order.service;

import com.healthcare.order.common.dto.request.SavePaymentMethodRequest;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;

import java.util.List;
import java.util.UUID;

public interface SavedPaymentMethodService {

    SavedPaymentMethodResponse savePaymentMethod(SavePaymentMethodRequest request);

    List<SavedPaymentMethodResponse> getCustomerPaymentMethods(UUID customerId);

    SavedPaymentMethodResponse getDefaultPaymentMethod(UUID customerId);

    SavedPaymentMethodResponse setDefaultPaymentMethod(UUID customerId, UUID paymentMethodId);

    void deletePaymentMethod(UUID customerId, UUID paymentMethodId);
}
