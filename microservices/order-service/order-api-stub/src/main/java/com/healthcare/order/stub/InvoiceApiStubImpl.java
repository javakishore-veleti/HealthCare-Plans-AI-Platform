package com.healthcare.order.stub;

import com.healthcare.order.client.InvoiceApiClient;
import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;
import com.healthcare.order.service.InvoiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class InvoiceApiStubImpl implements InvoiceApiClient {

    private final InvoiceService invoiceService;

    @Override
    public InvoiceDetailResponse generateInvoice(UUID orderId) {
        return invoiceService.generateInvoice(orderId);
    }

    @Override
    public InvoiceDetailResponse getInvoiceById(UUID invoiceId) {
        return invoiceService.getInvoiceById(invoiceId);
    }

    @Override
    public List<InvoiceSummaryResponse> getCustomerInvoices(UUID customerId) {
        return invoiceService.getCustomerInvoices(customerId);
    }

    @Override
    public List<InvoiceSummaryResponse> getUnpaidInvoices(UUID customerId) {
        return invoiceService.getUnpaidInvoices(customerId);
    }

    @Override
    public InvoiceDetailResponse sendInvoice(UUID invoiceId) {
        return invoiceService.sendInvoice(invoiceId);
    }
}
