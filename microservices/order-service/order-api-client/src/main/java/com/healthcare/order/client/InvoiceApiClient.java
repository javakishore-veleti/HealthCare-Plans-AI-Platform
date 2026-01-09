package com.healthcare.order.client;

import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;

import java.util.List;
import java.util.UUID;

public interface InvoiceApiClient {

    InvoiceDetailResponse generateInvoice(UUID orderId);

    InvoiceDetailResponse getInvoiceById(UUID invoiceId);

    List<InvoiceSummaryResponse> getCustomerInvoices(UUID customerId);

    List<InvoiceSummaryResponse> getUnpaidInvoices(UUID customerId);

    InvoiceDetailResponse sendInvoice(UUID invoiceId);
}
