package com.healthcare.order.service.mapper;

import com.healthcare.order.common.dto.response.*;
import com.healthcare.order.common.model.*;
import org.mapstruct.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE,
        builder = @Builder(disableBuilder = true))
public interface OrderMapper {

    @Mapping(target = "paidAmount", expression = "java(order.getPaidAmount())")
    @Mapping(target = "balanceDue", expression = "java(order.getBalanceDue())")
    OrderResponse toResponse(Order order);

    @Mapping(target = "paidAmount", expression = "java(order.getPaidAmount())")
    @Mapping(target = "balanceDue", expression = "java(order.getBalanceDue())")
    @Mapping(target = "items", source = "items")
    @Mapping(target = "payments", source = "payments")
    @Mapping(target = "invoices", source = "invoices")
    OrderDetailResponse toDetailResponse(Order order);

    OrderItemResponse toOrderItemResponse(OrderItem item);

    default List<OrderItemResponse> mapItems(Set<OrderItem> items) {
        if (items == null) return null;
        return items.stream().map(this::toOrderItemResponse).collect(Collectors.toList());
    }

    default List<PaymentResponse> mapPayments(Set<Payment> payments) {
        if (payments == null) return null;
        return payments.stream().map(this::toPaymentResponse).collect(Collectors.toList());
    }

    default List<InvoiceSummaryResponse> mapInvoices(Set<Invoice> invoices) {
        if (invoices == null) return null;
        return invoices.stream().map(this::toInvoiceSummaryResponse).collect(Collectors.toList());
    }

    PaymentResponse toPaymentResponse(Payment payment);

    InvoiceSummaryResponse toInvoiceSummaryResponse(Invoice invoice);
}
