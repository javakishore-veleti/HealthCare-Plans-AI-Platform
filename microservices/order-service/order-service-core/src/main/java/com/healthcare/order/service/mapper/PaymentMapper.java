package com.healthcare.order.service.mapper;

import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;
import com.healthcare.order.common.model.Payment;
import com.healthcare.order.common.model.SavedPaymentMethod;
import org.mapstruct.*;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface PaymentMapper {

    PaymentResponse toResponse(Payment payment);

    SavedPaymentMethodResponse toSavedPaymentMethodResponse(SavedPaymentMethod method);
}
