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
public interface InvoiceMapper {

    InvoiceSummaryResponse toSummaryResponse(Invoice invoice);

    @Mapping(target = "orderId", source = "order.id")
    @Mapping(target = "orderNumber", source = "order.orderNumber")
    @Mapping(target = "lineItems", source = "lineItems")
    InvoiceDetailResponse toDetailResponse(Invoice invoice);

    InvoiceLineItemResponse toLineItemResponse(InvoiceLineItem item);

    default List<InvoiceLineItemResponse> mapLineItems(Set<InvoiceLineItem> items) {
        if (items == null) return null;
        return items.stream().map(this::toLineItemResponse).collect(Collectors.toList());
    }
}
