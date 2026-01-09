package com.healthcare.order.api.controller;

import com.healthcare.order.common.dto.response.InvoiceDetailResponse;
import com.healthcare.order.common.dto.response.InvoiceSummaryResponse;
import com.healthcare.order.service.InvoiceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/invoices")
@RequiredArgsConstructor
@Tag(name = "Invoice", description = "Invoice management APIs")
public class InvoiceController {

    private final InvoiceService invoiceService;

    @PostMapping("/order/{orderId}")
    @Operation(summary = "Generate invoice", description = "Generate an invoice for an order")
    public ResponseEntity<InvoiceDetailResponse> generateInvoice(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        InvoiceDetailResponse response = invoiceService.generateInvoice(orderId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{invoiceId}")
    @Operation(summary = "Get invoice by ID", description = "Retrieve invoice details")
    public ResponseEntity<InvoiceDetailResponse> getInvoiceById(
            @Parameter(description = "Invoice UUID") @PathVariable UUID invoiceId) {
        InvoiceDetailResponse response = invoiceService.getInvoiceById(invoiceId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/number/{invoiceNumber}")
    @Operation(summary = "Get invoice by number", description = "Retrieve invoice by invoice number")
    public ResponseEntity<InvoiceDetailResponse> getInvoiceByNumber(
            @Parameter(description = "Invoice number") @PathVariable String invoiceNumber) {
        InvoiceDetailResponse response = invoiceService.getInvoiceByNumber(invoiceNumber);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/order/{orderId}/all")
    @Operation(summary = "Get order invoices", description = "Retrieve all invoices for an order")
    public ResponseEntity<List<InvoiceSummaryResponse>> getOrderInvoices(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        List<InvoiceSummaryResponse> responses = invoiceService.getOrderInvoices(orderId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer invoices", description = "Retrieve all invoices for a customer")
    public ResponseEntity<List<InvoiceSummaryResponse>> getCustomerInvoices(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<InvoiceSummaryResponse> responses = invoiceService.getCustomerInvoices(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/customer/{customerId}/unpaid")
    @Operation(summary = "Get unpaid invoices", description = "Retrieve unpaid invoices for a customer")
    public ResponseEntity<List<InvoiceSummaryResponse>> getUnpaidInvoices(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<InvoiceSummaryResponse> responses = invoiceService.getUnpaidInvoices(customerId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/{invoiceId}/send")
    @Operation(summary = "Send invoice", description = "Send an invoice to the customer")
    public ResponseEntity<InvoiceDetailResponse> sendInvoice(
            @Parameter(description = "Invoice UUID") @PathVariable UUID invoiceId) {
        InvoiceDetailResponse response = invoiceService.sendInvoice(invoiceId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{invoiceId}/mark-paid")
    @Operation(summary = "Mark invoice as paid", description = "Mark an invoice as paid")
    public ResponseEntity<InvoiceDetailResponse> markAsPaid(
            @Parameter(description = "Invoice UUID") @PathVariable UUID invoiceId) {
        InvoiceDetailResponse response = invoiceService.markAsPaid(invoiceId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{invoiceId}")
    @Operation(summary = "Cancel invoice", description = "Cancel an invoice")
    public ResponseEntity<Void> cancelInvoice(
            @Parameter(description = "Invoice UUID") @PathVariable UUID invoiceId) {
        invoiceService.cancelInvoice(invoiceId);
        return ResponseEntity.noContent().build();
    }
}
