#!/bin/bash

# =============================================================================
# Order Service - Java Source Files Generator (Part 3)
# =============================================================================
# Creates: API Client, API Stub, Controllers, Config, Application, Migrations
# =============================================================================

set -e

BASE_DIR="microservices/order-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}          Order Service - Part 3 (API, Config, Migrations)                    ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# API CLIENT
# =============================================================================
echo -e "${CYAN}Creating API Client...${NC}"

CLIENT_DIR="$BASE_DIR/order-api-client/src/main/java/com/healthcare/order/client"
mkdir -p "$CLIENT_DIR"

cat > "$CLIENT_DIR/OrderApiClient.java" << 'EOF'
package com.healthcare.order.client;

import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;

import java.util.List;
import java.util.UUID;

public interface OrderApiClient {

    OrderDetailResponse createOrder(CreateOrderRequest request);

    OrderDetailResponse getOrderById(UUID orderId);

    OrderDetailResponse getOrderByNumber(String orderNumber);

    List<OrderResponse> getCustomerOrders(UUID customerId);

    PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request);

    OrderDetailResponse submitOrder(UUID orderId);

    OrderDetailResponse cancelOrder(UUID orderId, String reason);
}
EOF
echo -e "${GREEN}✓${NC} OrderApiClient.java"

cat > "$CLIENT_DIR/PaymentApiClient.java" << 'EOF'
package com.healthcare.order.client;

import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;

import java.util.List;
import java.util.UUID;

public interface PaymentApiClient {

    PaymentResponse processPayment(ProcessPaymentRequest request);

    PaymentResponse getPaymentById(UUID paymentId);

    List<PaymentResponse> getOrderPayments(UUID orderId);

    PaymentResponse refundPayment(RefundRequest request);
}
EOF
echo -e "${GREEN}✓${NC} PaymentApiClient.java"

cat > "$CLIENT_DIR/InvoiceApiClient.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} InvoiceApiClient.java"

cat > "$CLIENT_DIR/OrderFeignClient.java" << 'EOF'
package com.healthcare.order.client;

import com.healthcare.order.common.dto.request.*;
import com.healthcare.order.common.dto.response.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "order-service", url = "${order.service.url:http://localhost:8084}")
public interface OrderFeignClient extends OrderApiClient, PaymentApiClient, InvoiceApiClient {

    // Order endpoints
    @Override
    @PostMapping("/api/v1/orders")
    OrderDetailResponse createOrder(@RequestBody CreateOrderRequest request);

    @Override
    @GetMapping("/api/v1/orders/{orderId}")
    OrderDetailResponse getOrderById(@PathVariable("orderId") UUID orderId);

    @Override
    @GetMapping("/api/v1/orders/number/{orderNumber}")
    OrderDetailResponse getOrderByNumber(@PathVariable("orderNumber") String orderNumber);

    @Override
    @GetMapping("/api/v1/orders/customer/{customerId}")
    List<OrderResponse> getCustomerOrders(@PathVariable("customerId") UUID customerId);

    @Override
    @PostMapping("/api/v1/orders/search")
    PagedResponse<OrderResponse> searchOrders(@RequestBody OrderSearchRequest request);

    @Override
    @PostMapping("/api/v1/orders/{orderId}/submit")
    OrderDetailResponse submitOrder(@PathVariable("orderId") UUID orderId);

    @Override
    @PostMapping("/api/v1/orders/{orderId}/cancel")
    OrderDetailResponse cancelOrder(@PathVariable("orderId") UUID orderId,
                                    @RequestParam(required = false) String reason);

    // Payment endpoints
    @Override
    @PostMapping("/api/v1/payments")
    PaymentResponse processPayment(@RequestBody ProcessPaymentRequest request);

    @Override
    @GetMapping("/api/v1/payments/{paymentId}")
    PaymentResponse getPaymentById(@PathVariable("paymentId") UUID paymentId);

    @Override
    @GetMapping("/api/v1/orders/{orderId}/payments")
    List<PaymentResponse> getOrderPayments(@PathVariable("orderId") UUID orderId);

    @Override
    @PostMapping("/api/v1/payments/refund")
    PaymentResponse refundPayment(@RequestBody RefundRequest request);

    // Invoice endpoints
    @Override
    @PostMapping("/api/v1/orders/{orderId}/invoices")
    InvoiceDetailResponse generateInvoice(@PathVariable("orderId") UUID orderId);

    @Override
    @GetMapping("/api/v1/invoices/{invoiceId}")
    InvoiceDetailResponse getInvoiceById(@PathVariable("invoiceId") UUID invoiceId);

    @Override
    @GetMapping("/api/v1/invoices/customer/{customerId}")
    List<InvoiceSummaryResponse> getCustomerInvoices(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/invoices/customer/{customerId}/unpaid")
    List<InvoiceSummaryResponse> getUnpaidInvoices(@PathVariable("customerId") UUID customerId);

    @Override
    @PostMapping("/api/v1/invoices/{invoiceId}/send")
    InvoiceDetailResponse sendInvoice(@PathVariable("invoiceId") UUID invoiceId);
}
EOF
echo -e "${GREEN}✓${NC} OrderFeignClient.java"

# =============================================================================
# API STUB
# =============================================================================
echo ""
echo -e "${CYAN}Creating API Stub...${NC}"

STUB_DIR="$BASE_DIR/order-api-stub/src/main/java/com/healthcare/order/stub"
mkdir -p "$STUB_DIR"

cat > "$STUB_DIR/OrderApiStubImpl.java" << 'EOF'
package com.healthcare.order.stub;

import com.healthcare.order.client.OrderApiClient;
import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;
import com.healthcare.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OrderApiStubImpl implements OrderApiClient {

    private final OrderService orderService;

    @Override
    public OrderDetailResponse createOrder(CreateOrderRequest request) {
        return orderService.createOrder(request);
    }

    @Override
    public OrderDetailResponse getOrderById(UUID orderId) {
        return orderService.getOrderById(orderId);
    }

    @Override
    public OrderDetailResponse getOrderByNumber(String orderNumber) {
        return orderService.getOrderByNumber(orderNumber);
    }

    @Override
    public List<OrderResponse> getCustomerOrders(UUID customerId) {
        return orderService.getCustomerOrders(customerId);
    }

    @Override
    public PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request) {
        return orderService.searchOrders(request);
    }

    @Override
    public OrderDetailResponse submitOrder(UUID orderId) {
        return orderService.submitOrder(orderId);
    }

    @Override
    public OrderDetailResponse cancelOrder(UUID orderId, String reason) {
        return orderService.cancelOrder(orderId, reason);
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderApiStubImpl.java"

cat > "$STUB_DIR/PaymentApiStubImpl.java" << 'EOF'
package com.healthcare.order.stub;

import com.healthcare.order.client.PaymentApiClient;
import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PaymentApiStubImpl implements PaymentApiClient {

    private final PaymentService paymentService;

    @Override
    public PaymentResponse processPayment(ProcessPaymentRequest request) {
        return paymentService.processPayment(request);
    }

    @Override
    public PaymentResponse getPaymentById(UUID paymentId) {
        return paymentService.getPaymentById(paymentId);
    }

    @Override
    public List<PaymentResponse> getOrderPayments(UUID orderId) {
        return paymentService.getOrderPayments(orderId);
    }

    @Override
    public PaymentResponse refundPayment(RefundRequest request) {
        return paymentService.refundPayment(request);
    }
}
EOF
echo -e "${GREEN}✓${NC} PaymentApiStubImpl.java"

cat > "$STUB_DIR/InvoiceApiStubImpl.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} InvoiceApiStubImpl.java"

# =============================================================================
# CONTROLLERS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Controllers...${NC}"

CONTROLLER_DIR="$BASE_DIR/order-api/src/main/java/com/healthcare/order/api/controller"
mkdir -p "$CONTROLLER_DIR"

cat > "$CONTROLLER_DIR/OrderController.java" << 'EOF'
package com.healthcare.order.api.controller;

import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;
import com.healthcare.order.service.OrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
@Tag(name = "Order", description = "Order management APIs")
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @Operation(summary = "Create order", description = "Create a new order")
    public ResponseEntity<OrderDetailResponse> createOrder(
            @Valid @RequestBody CreateOrderRequest request) {
        OrderDetailResponse response = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{orderId}")
    @Operation(summary = "Get order by ID", description = "Retrieve order details by UUID")
    public ResponseEntity<OrderDetailResponse> getOrderById(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        OrderDetailResponse response = orderService.getOrderById(orderId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/number/{orderNumber}")
    @Operation(summary = "Get order by number", description = "Retrieve order by order number")
    public ResponseEntity<OrderDetailResponse> getOrderByNumber(
            @Parameter(description = "Order number") @PathVariable String orderNumber) {
        OrderDetailResponse response = orderService.getOrderByNumber(orderNumber);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/customer/{customerId}")
    @Operation(summary = "Get customer orders", description = "Retrieve all orders for a customer")
    public ResponseEntity<List<OrderResponse>> getCustomerOrders(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<OrderResponse> responses = orderService.getCustomerOrders(customerId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/search")
    @Operation(summary = "Search orders", description = "Search orders with filters and pagination")
    public ResponseEntity<PagedResponse<OrderResponse>> searchOrders(
            @Valid @RequestBody OrderSearchRequest request) {
        PagedResponse<OrderResponse> response = orderService.searchOrders(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{orderId}/submit")
    @Operation(summary = "Submit order", description = "Submit a draft order for payment")
    public ResponseEntity<OrderDetailResponse> submitOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        OrderDetailResponse response = orderService.submitOrder(orderId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{orderId}/cancel")
    @Operation(summary = "Cancel order", description = "Cancel an order")
    public ResponseEntity<OrderDetailResponse> cancelOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId,
            @RequestParam(required = false) String reason) {
        OrderDetailResponse response = orderService.cancelOrder(orderId, reason);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{orderId}/complete")
    @Operation(summary = "Complete order", description = "Mark order as completed")
    public ResponseEntity<OrderDetailResponse> completeOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        OrderDetailResponse response = orderService.completeOrder(orderId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{orderId}")
    @Operation(summary = "Delete order", description = "Delete a draft order")
    public ResponseEntity<Void> deleteOrder(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        orderService.deleteOrder(orderId);
        return ResponseEntity.noContent().build();
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderController.java"

cat > "$CONTROLLER_DIR/PaymentController.java" << 'EOF'
package com.healthcare.order.api.controller;

import com.healthcare.order.common.dto.request.ProcessPaymentRequest;
import com.healthcare.order.common.dto.request.RefundRequest;
import com.healthcare.order.common.dto.request.SavePaymentMethodRequest;
import com.healthcare.order.common.dto.response.PaymentResponse;
import com.healthcare.order.common.dto.response.SavedPaymentMethodResponse;
import com.healthcare.order.service.PaymentService;
import com.healthcare.order.service.SavedPaymentMethodService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
@Tag(name = "Payment", description = "Payment processing APIs")
public class PaymentController {

    private final PaymentService paymentService;
    private final SavedPaymentMethodService savedPaymentMethodService;

    @PostMapping
    @Operation(summary = "Process payment", description = "Process a payment for an order")
    public ResponseEntity<PaymentResponse> processPayment(
            @Valid @RequestBody ProcessPaymentRequest request) {
        PaymentResponse response = paymentService.processPayment(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{paymentId}")
    @Operation(summary = "Get payment", description = "Retrieve payment details")
    public ResponseEntity<PaymentResponse> getPaymentById(
            @Parameter(description = "Payment UUID") @PathVariable UUID paymentId) {
        PaymentResponse response = paymentService.getPaymentById(paymentId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/order/{orderId}")
    @Operation(summary = "Get order payments", description = "Retrieve all payments for an order")
    public ResponseEntity<List<PaymentResponse>> getOrderPayments(
            @Parameter(description = "Order UUID") @PathVariable UUID orderId) {
        List<PaymentResponse> responses = paymentService.getOrderPayments(orderId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/refund")
    @Operation(summary = "Refund payment", description = "Process a refund for a payment")
    public ResponseEntity<PaymentResponse> refundPayment(
            @Valid @RequestBody RefundRequest request) {
        PaymentResponse response = paymentService.refundPayment(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{paymentId}/retry")
    @Operation(summary = "Retry payment", description = "Retry a failed payment")
    public ResponseEntity<PaymentResponse> retryPayment(
            @Parameter(description = "Payment UUID") @PathVariable UUID paymentId) {
        PaymentResponse response = paymentService.retryPayment(paymentId);
        return ResponseEntity.ok(response);
    }

    // Saved Payment Methods
    @PostMapping("/methods")
    @Operation(summary = "Save payment method", description = "Save a payment method for future use")
    public ResponseEntity<SavedPaymentMethodResponse> savePaymentMethod(
            @Valid @RequestBody SavePaymentMethodRequest request) {
        SavedPaymentMethodResponse response = savedPaymentMethodService.savePaymentMethod(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/methods/customer/{customerId}")
    @Operation(summary = "Get saved payment methods", description = "Retrieve saved payment methods for a customer")
    public ResponseEntity<List<SavedPaymentMethodResponse>> getCustomerPaymentMethods(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<SavedPaymentMethodResponse> responses = savedPaymentMethodService.getCustomerPaymentMethods(customerId);
        return ResponseEntity.ok(responses);
    }

    @PostMapping("/methods/{paymentMethodId}/default")
    @Operation(summary = "Set default payment method", description = "Set a payment method as default")
    public ResponseEntity<SavedPaymentMethodResponse> setDefaultPaymentMethod(
            @Parameter(description = "Customer UUID") @RequestParam UUID customerId,
            @Parameter(description = "Payment Method UUID") @PathVariable UUID paymentMethodId) {
        SavedPaymentMethodResponse response = savedPaymentMethodService.setDefaultPaymentMethod(customerId, paymentMethodId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/methods/{paymentMethodId}")
    @Operation(summary = "Delete payment method", description = "Delete a saved payment method")
    public ResponseEntity<Void> deletePaymentMethod(
            @Parameter(description = "Customer UUID") @RequestParam UUID customerId,
            @Parameter(description = "Payment Method UUID") @PathVariable UUID paymentMethodId) {
        savedPaymentMethodService.deletePaymentMethod(customerId, paymentMethodId);
        return ResponseEntity.noContent().build();
    }
}
EOF
echo -e "${GREEN}✓${NC} PaymentController.java"

cat > "$CONTROLLER_DIR/InvoiceController.java" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} InvoiceController.java"

# =============================================================================
# CONFIGURATION
# =============================================================================
echo ""
echo -e "${CYAN}Creating Configuration Classes...${NC}"

CONFIG_DIR="$BASE_DIR/order-api/src/main/java/com/healthcare/order/api/config"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/OpenApiConfig.java" << 'EOF'
package com.healthcare.order.api.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Order Service API")
                .description("API for order management, payments, and invoicing")
                .version("1.0.0")
                .contact(new Contact()
                    .name("Healthcare Platform Team")
                    .email("support@healthcare-platform.com"))
                .license(new License()
                    .name("Apache 2.0")
                    .url("https://www.apache.org/licenses/LICENSE-2.0")))
            .servers(List.of(
                new Server().url("http://localhost:8084").description("Local Development")
            ));
    }
}
EOF
echo -e "${GREEN}✓${NC} OpenApiConfig.java"

cat > "$CONFIG_DIR/GlobalExceptionHandler.java" << 'EOF'
package com.healthcare.order.api.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(IllegalArgumentException ex) {
        log.warn("Bad request: {}", ex.getMessage());
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Bad Request",
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.badRequest().body(error);
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ErrorResponse> handleIllegalStateException(IllegalStateException ex) {
        log.warn("Invalid state: {}", ex.getMessage());
        ErrorResponse error = new ErrorResponse(
            HttpStatus.CONFLICT.value(),
            "Conflict",
            ex.getMessage(),
            LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String message = error.getDefaultMessage();
            errors.put(fieldName, message);
        });

        log.warn("Validation failed: {}", errors);
        ErrorResponse error = new ErrorResponse(
            HttpStatus.BAD_REQUEST.value(),
            "Validation Failed",
            errors.toString(),
            LocalDateTime.now()
        );
        return ResponseEntity.badRequest().body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        log.error("Unexpected error", ex);
        ErrorResponse error = new ErrorResponse(
            HttpStatus.INTERNAL_SERVER_ERROR.value(),
            "Internal Server Error",
            "An unexpected error occurred",
            LocalDateTime.now()
        );
        return ResponseEntity.internalServerError().body(error);
    }

    public record ErrorResponse(int status, String error, String message, LocalDateTime timestamp) {}
}
EOF
echo -e "${GREEN}✓${NC} GlobalExceptionHandler.java"

# =============================================================================
# APPLICATION
# =============================================================================
echo ""
echo -e "${CYAN}Creating Application Class...${NC}"

APP_DIR="$BASE_DIR/order-api/src/main/java/com/healthcare/order/api"

cat > "$APP_DIR/OrderApiApplication.java" << 'EOF'
package com.healthcare.order.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.healthcare.order")
@EntityScan(basePackages = "com.healthcare.order.common.model")
@EnableJpaRepositories(basePackages = "com.healthcare.order.dao.repository")
public class OrderApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderApiApplication.class, args);
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderApiApplication.java"

# =============================================================================
# RESOURCES
# =============================================================================
echo ""
echo -e "${CYAN}Creating Application Properties...${NC}"

RESOURCES_DIR="$BASE_DIR/order-api/src/main/resources"
mkdir -p "$RESOURCES_DIR"

cat > "$RESOURCES_DIR/application.yml" << 'EOF'
spring:
  application:
    name: order-service
  profiles:
    active: local

server:
  port: 8084

springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method
    tagsSorter: alpha

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when_authorized
EOF
echo -e "${GREEN}✓${NC} application.yml"

cat > "$RESOURCES_DIR/application-local.yml" << 'EOF'
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/order_db
    username: order_user
    password: order_password
    driver-class-name: org.postgresql.Driver
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000

  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.PostgreSQLDialect

  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true

# External services
plans:
  service:
    url: http://localhost:8081

customer:
  service:
    url: http://localhost:8083

logging:
  level:
    com.healthcare.order: DEBUG
    org.hibernate.SQL: DEBUG
    org.hibernate.type.descriptor.sql.BasicBinder: TRACE
EOF
echo -e "${GREEN}✓${NC} application-local.yml"

# =============================================================================
# FLYWAY MIGRATIONS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Flyway Migrations...${NC}"

MIGRATION_DIR="$RESOURCES_DIR/db/migration"
mkdir -p "$MIGRATION_DIR"

cat > "$MIGRATION_DIR/V1__init_schema.sql" << 'EOF'
-- =============================================================================
-- Order Service - Initial Schema
-- =============================================================================

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id UUID NOT NULL,
    customer_number VARCHAR(20) NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    customer_email VARCHAR(200) NOT NULL,
    order_type VARCHAR(20) NOT NULL,
    status VARCHAR(25) NOT NULL DEFAULT 'DRAFT',
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    billing_frequency VARCHAR(15) NOT NULL DEFAULT 'MONTHLY',
    effective_date DATE NOT NULL,
    expiration_date DATE,
    submitted_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason VARCHAR(500),
    notes TEXT,
    promo_code VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_order_number ON orders(order_number);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Order items table
CREATE TABLE order_items (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    plan_name VARCHAR(200) NOT NULL,
    plan_year INTEGER,
    metal_tier VARCHAR(20),
    description VARCHAR(500),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_price DECIMAL(10,2) NOT NULL,
    include_dependents BOOLEAN NOT NULL DEFAULT FALSE,
    dependent_count INTEGER DEFAULT 0,
    subsidy_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_plan_id ON order_items(plan_id);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    payment_number VARCHAR(30) NOT NULL UNIQUE,
    transaction_id VARCHAR(100),
    external_reference VARCHAR(100),
    payment_method VARCHAR(20) NOT NULL,
    status VARCHAR(25) NOT NULL DEFAULT 'PENDING',
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    processing_fee DECIMAL(8,2) DEFAULT 0,
    card_brand VARCHAR(20),
    card_last4 VARCHAR(4),
    card_expiry_month INTEGER,
    card_expiry_year INTEGER,
    billing_name VARCHAR(200),
    billing_zip VARCHAR(10),
    bank_name VARCHAR(100),
    account_last4 VARCHAR(4),
    routing_last4 VARCHAR(4),
    processed_at TIMESTAMP,
    failed_at TIMESTAMP,
    failure_reason VARCHAR(500),
    refunded_amount DECIMAL(10,2) DEFAULT 0,
    refund_reason VARCHAR(500),
    ip_address VARCHAR(50),
    user_agent VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- Invoices table
CREATE TABLE invoices (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    customer_id UUID NOT NULL,
    customer_name VARCHAR(200) NOT NULL,
    customer_email VARCHAR(200) NOT NULL,
    billing_address TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    paid_amount DECIMAL(10,2) DEFAULT 0,
    balance_due DECIMAL(10,2),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    paid_date DATE,
    period_start DATE,
    period_end DATE,
    sent_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoices_order_id ON invoices(order_id);
CREATE INDEX idx_invoices_invoice_number ON invoices(invoice_number);
CREATE INDEX idx_invoices_customer_id ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);

-- Invoice line items table
CREATE TABLE invoice_line_items (
    id UUID PRIMARY KEY,
    invoice_id UUID NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(500) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    plan_id UUID,
    plan_code VARCHAR(50),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoice_line_items_invoice_id ON invoice_line_items(invoice_id);

-- Saved payment methods table
CREATE TABLE saved_payment_methods (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL,
    nickname VARCHAR(100),
    payment_method VARCHAR(20) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    card_brand VARCHAR(20),
    card_last4 VARCHAR(4),
    card_expiry_month INTEGER,
    card_expiry_year INTEGER,
    cardholder_name VARCHAR(200),
    bank_name VARCHAR(100),
    account_type VARCHAR(20),
    account_last4 VARCHAR(4),
    routing_last4 VARCHAR(4),
    gateway_token VARCHAR(500),
    billing_zip VARCHAR(10),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_saved_payment_methods_customer_id ON saved_payment_methods(customer_id);
EOF
echo -e "${GREEN}✓${NC} V1__init_schema.sql"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}          Part 3 Complete - API, Config, Migrations Created!                  ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Build and run:${NC}"
echo "  cd microservices/order-service"
echo "  mvn clean install -DskipTests"
echo "  cd order-api"
echo "  mvn spring-boot:run -Dspring-boot.run.profiles=local"
echo ""
echo -e "${YELLOW}Test endpoints:${NC}"
echo "  Swagger UI: http://localhost:8084/swagger-ui.html"
echo "  Health:     http://localhost:8084/actuator/health"