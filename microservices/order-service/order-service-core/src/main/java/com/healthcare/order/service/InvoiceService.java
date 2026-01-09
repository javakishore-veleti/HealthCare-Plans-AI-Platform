package com.healthcare.order.service;

import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;

import java.util.List;
import java.util.UUID;

public interface InvoiceService {

    InvoiceDetailResponse generateInvoice(UUID orderId);

    InvoiceDetailResponse getInvoiceById(UUID invoiceId);

    InvoiceDetailResponse getInvoiceByNumber(String invoiceNumber);

    List<InvoiceSummaryResponse> getOrderInvoices(UUID orderId);

    List<InvoiceSummaryResponse> getCustomerInvoices(UUID customerId);

    List<InvoiceSummaryResponse> getUnpaidInvoices(UUID customerId);

    InvoiceDetailResponse sendInvoice(UUID invoiceId);

    InvoiceDetailResponse markAsPaid(UUID invoiceId);

    void cancelInvoice(UUID invoiceId);
}
