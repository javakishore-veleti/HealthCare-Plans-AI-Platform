#!/bin/bash

# =============================================================================
# Inter-Service Feign Integration Setup
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Inter-Service Feign Integration Setup                           ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# PLANS SERVICE - Add Feign Client Interface Export
# =============================================================================
echo -e "${CYAN}Updating Plans Service API Client...${NC}"

PLANS_CLIENT_DIR="microservices/plans-service/plans-api-client/src/main/java/com/healthcare/plans/client"
mkdir -p "$PLANS_CLIENT_DIR"

# Create the Feign client interface
cat > "$PLANS_CLIENT_DIR/PlanFeignClient.java" << 'EOF'
package com.healthcare.plans.client;

import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import com.healthcare.plans.common.dto.response.ProviderResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "plans-service", url = "${plans.service.url:http://localhost:8081}")
public interface PlanFeignClient {

    @GetMapping("/api/v1/plans/{planId}")
    PlanDetailResponse getPlanById(@PathVariable("planId") UUID planId);

    @GetMapping("/api/v1/plans/code/{planCode}")
    PlanDetailResponse getPlanByCode(@PathVariable("planCode") String planCode);

    @GetMapping("/api/v1/plans")
    PagedResponse<PlanResponse> searchPlans(
        @RequestParam(required = false) String state,
        @RequestParam(required = false) String metalTier,
        @RequestParam(required = false) Integer year,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "20") int size
    );

    @GetMapping("/api/v1/plans/{planId}/providers")
    List<ProviderResponse> getPlanProviders(@PathVariable("planId") UUID planId);

    @GetMapping("/api/v1/plans/active")
    List<PlanResponse> getActivePlans(@RequestParam(required = false) String state);
}
EOF
echo -e "${GREEN}✓${NC} PlanFeignClient.java"

# =============================================================================
# CUSTOMER SERVICE - Add Feign Client Interface Export
# =============================================================================
echo ""
echo -e "${CYAN}Updating Customer Service API Client...${NC}"

CUSTOMER_CLIENT_DIR="microservices/customer-onboarding-service/customer-api-client/src/main/java/com/healthcare/customer/client"

# Update the existing Feign client with proper annotations
cat > "$CUSTOMER_CLIENT_DIR/CustomerFeignClient.java" << 'EOF'
package com.healthcare.customer.client;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "customer-service", url = "${customer.service.url:http://localhost:8083}")
public interface CustomerFeignClient extends CustomerApiClient, EnrollmentApiClient {

    // Customer endpoints
    @Override
    @PostMapping("/api/v1/customers")
    CustomerDetailResponse createCustomer(@RequestBody CreateCustomerRequest request);

    @Override
    @GetMapping("/api/v1/customers/{customerId}")
    CustomerDetailResponse getCustomerById(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/customers/email/{email}")
    CustomerDetailResponse getCustomerByEmail(@PathVariable("email") String email);

    @GetMapping("/api/v1/customers/number/{customerNumber}")
    CustomerDetailResponse getCustomerByNumber(@PathVariable("customerNumber") String customerNumber);

    @Override
    @PostMapping("/api/v1/customers/search")
    PagedResponse<CustomerResponse> searchCustomers(@RequestBody CustomerSearchRequest request);

    @Override
    @PutMapping("/api/v1/customers/{customerId}")
    CustomerDetailResponse updateCustomer(@PathVariable("customerId") UUID customerId,
                                          @RequestBody UpdateCustomerRequest request);

    @Override
    @DeleteMapping("/api/v1/customers/{customerId}")
    void deleteCustomer(@PathVariable("customerId") UUID customerId);

    @Override
    @PostMapping("/api/v1/customers/{customerId}/activate")
    void activateCustomer(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/customers/email-available")
    boolean isEmailAvailable(@RequestParam("email") String email);

    // Enrollment endpoints
    @Override
    @PostMapping("/api/v1/customers/{customerId}/eligibility/{planId}")
    EligibilityResponse checkEligibility(@PathVariable("customerId") UUID customerId,
                                         @PathVariable("planId") UUID planId);

    @Override
    @PostMapping("/api/v1/customers/{customerId}/enrollments")
    EnrollmentResponse enrollCustomer(@PathVariable("customerId") UUID customerId,
                                      @RequestBody EnrollmentRequest request);

    @Override
    @GetMapping("/api/v1/customers/{customerId}/enrollments")
    List<EnrollmentResponse> getCustomerEnrollments(@PathVariable("customerId") UUID customerId);

    @Override
    @GetMapping("/api/v1/customers/{customerId}/enrollments/active")
    List<EnrollmentResponse> getActiveEnrollments(@PathVariable("customerId") UUID customerId);

    @Override
    @DeleteMapping("/api/v1/customers/{customerId}/enrollments/{enrollmentId}")
    void cancelEnrollment(@PathVariable("customerId") UUID customerId,
                          @PathVariable("enrollmentId") UUID enrollmentId,
                          @RequestParam("reason") String reason);
}
EOF
echo -e "${GREEN}✓${NC} CustomerFeignClient.java"

# =============================================================================
# ORDER SERVICE - Enable Feign and Configure Clients
# =============================================================================
echo ""
echo -e "${CYAN}Configuring Order Service Feign Integration...${NC}"

ORDER_CONFIG_DIR="microservices/order-service/order-api/src/main/java/com/healthcare/order/api/config"
mkdir -p "$ORDER_CONFIG_DIR"

# Create Feign configuration
cat > "$ORDER_CONFIG_DIR/FeignConfig.java" << 'EOF'
package com.healthcare.order.api.config;

import feign.Logger;
import feign.Request;
import feign.Retryer;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

@Configuration
@EnableFeignClients(basePackages = {
    "com.healthcare.plans.client",
    "com.healthcare.customer.client"
})
public class FeignConfig {

    @Bean
    public Logger.Level feignLoggerLevel() {
        return Logger.Level.BASIC;
    }

    @Bean
    public Request.Options requestOptions() {
        return new Request.Options(
            5, TimeUnit.SECONDS,  // connect timeout
            10, TimeUnit.SECONDS, // read timeout
            true                   // follow redirects
        );
    }

    @Bean
    public Retryer retryer() {
        return new Retryer.Default(100, 1000, 3);
    }
}
EOF
echo -e "${GREEN}✓${NC} FeignConfig.java"

# Create a fallback/error decoder
cat > "$ORDER_CONFIG_DIR/FeignErrorDecoder.java" << 'EOF'
package com.healthcare.order.api.config;

import feign.Response;
import feign.codec.ErrorDecoder;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class FeignErrorDecoder implements ErrorDecoder {

    private final ErrorDecoder defaultDecoder = new Default();

    @Override
    public Exception decode(String methodKey, Response response) {
        log.error("Feign error - Method: {}, Status: {}, Reason: {}",
            methodKey, response.status(), response.reason());

        if (response.status() == 404) {
            return new IllegalArgumentException("Resource not found: " + methodKey);
        }

        if (response.status() == 400) {
            return new IllegalArgumentException("Bad request to external service: " + methodKey);
        }

        if (response.status() >= 500) {
            return new RuntimeException("External service unavailable: " + methodKey);
        }

        return defaultDecoder.decode(methodKey, response);
    }
}
EOF
echo -e "${GREEN}✓${NC} FeignErrorDecoder.java"

# =============================================================================
# ORDER SERVICE - Update OrderServiceImpl with Feign Clients
# =============================================================================
echo ""
echo -e "${CYAN}Updating OrderServiceImpl with Feign clients...${NC}"

ORDER_SERVICE_DIR="microservices/order-service/order-service-core/src/main/java/com/healthcare/order/service"

cat > "$ORDER_SERVICE_DIR/OrderServiceImpl.java" << 'EOF'
package com.healthcare.order.service;

import com.healthcare.customer.client.CustomerFeignClient;
import com.healthcare.customer.common.dto.response.CustomerDetailResponse;
import com.healthcare.order.common.constants.BillingFrequency;
import com.healthcare.order.common.constants.OrderStatus;
import com.healthcare.order.common.dto.request.CreateOrderRequest;
import com.healthcare.order.common.dto.request.OrderItemRequest;
import com.healthcare.order.common.dto.request.OrderSearchRequest;
import com.healthcare.order.common.dto.response.OrderDetailResponse;
import com.healthcare.order.common.dto.response.OrderResponse;
import com.healthcare.order.common.dto.response.PagedResponse;
import com.healthcare.order.common.model.Order;
import com.healthcare.order.common.model.OrderItem;
import com.healthcare.order.dao.repository.OrderRepository;
import com.healthcare.order.dao.specification.OrderSpecification;
import com.healthcare.order.service.mapper.OrderMapper;
import com.healthcare.plans.client.PlanFeignClient;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final OrderMapper orderMapper;

    // Feign clients for inter-service communication
    private final Optional<PlanFeignClient> planFeignClient;
    private final Optional<CustomerFeignClient> customerFeignClient;

    @Override
    public OrderDetailResponse createOrder(CreateOrderRequest request) {
        log.info("Creating order for customer: {}", request.getCustomerId());

        // Fetch customer details from customer-service
        String customerName = "Customer";
        String customerEmail = "customer@example.com";
        String customerNumber = "CUS" + request.getCustomerId().toString().substring(0, 8);

        if (customerFeignClient.isPresent()) {
            try {
                CustomerDetailResponse customer = customerFeignClient.get()
                    .getCustomerById(request.getCustomerId());
                customerName = customer.getFullName();
                customerEmail = customer.getEmail();
                customerNumber = customer.getCustomerNumber();
                log.debug("Fetched customer: {} ({})", customerName, customerNumber);
            } catch (Exception e) {
                log.warn("Failed to fetch customer details, using defaults: {}", e.getMessage());
            }
        }

        Order order = Order.builder()
            .orderNumber(generateOrderNumber())
            .customerId(request.getCustomerId())
            .customerNumber(customerNumber)
            .customerName(customerName)
            .customerEmail(customerEmail)
            .orderType(request.getOrderType())
            .status(OrderStatus.DRAFT)
            .billingFrequency(request.getBillingFrequency() != null ?
                request.getBillingFrequency() : BillingFrequency.MONTHLY)
            .effectiveDate(request.getEffectiveDate())
            .promoCode(request.getPromoCode())
            .notes(request.getNotes())
            .build();

        // Add items with plan details
        for (OrderItemRequest itemRequest : request.getItems()) {
            OrderItem item = createOrderItem(itemRequest, order.getBillingFrequency());
            order.addItem(item);
        }

        // Apply promo code discount if applicable
        if (StringUtils.hasText(request.getPromoCode())) {
            applyPromoCode(order, request.getPromoCode());
        }

        Order savedOrder = orderRepository.save(order);
        log.info("Created order: {} with {} items, total: ${}",
            savedOrder.getOrderNumber(), savedOrder.getItems().size(), savedOrder.getTotalAmount());

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    @Transactional(readOnly = true)
    public OrderDetailResponse getOrderById(UUID orderId) {
        Order order = orderRepository.findByIdWithDetails(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
        return orderMapper.toDetailResponse(order);
    }

    @Override
    @Transactional(readOnly = true)
    public OrderDetailResponse getOrderByNumber(String orderNumber) {
        Order order = orderRepository.findByOrderNumber(orderNumber)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderNumber));
        return orderMapper.toDetailResponse(order);
    }

    @Override
    @Transactional(readOnly = true)
    public List<OrderResponse> getCustomerOrders(UUID customerId) {
        return orderRepository.findByCustomerId(customerId).stream()
            .map(orderMapper::toResponse)
            .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public PagedResponse<OrderResponse> searchOrders(OrderSearchRequest request) {
        Sort sort = buildSort(request.getSortBy(), request.getSortDirection());
        Pageable pageable = PageRequest.of(request.getPage(), request.getSize(), sort);

        Page<Order> orderPage = orderRepository.findAll(
            OrderSpecification.buildSpecification(request), pageable);

        return PagedResponse.<OrderResponse>builder()
            .content(orderPage.getContent().stream()
                .map(orderMapper::toResponse)
                .collect(Collectors.toList()))
            .page(orderPage.getNumber())
            .size(orderPage.getSize())
            .totalElements(orderPage.getTotalElements())
            .totalPages(orderPage.getTotalPages())
            .first(orderPage.isFirst())
            .last(orderPage.isLast())
            .build();
    }

    @Override
    public OrderDetailResponse submitOrder(UUID orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only draft orders can be submitted");
        }

        if (order.getItems().isEmpty()) {
            throw new IllegalStateException("Cannot submit order with no items");
        }

        order.setStatus(OrderStatus.PENDING_PAYMENT);
        order.setSubmittedAt(LocalDateTime.now());

        Order savedOrder = orderRepository.save(order);
        log.info("Submitted order: {}", savedOrder.getOrderNumber());

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    public OrderDetailResponse cancelOrder(UUID orderId, String reason) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() == OrderStatus.COMPLETED || order.getStatus() == OrderStatus.CANCELLED) {
            throw new IllegalStateException("Cannot cancel order in status: " + order.getStatus());
        }

        order.setStatus(OrderStatus.CANCELLED);
        order.setCancelledAt(LocalDateTime.now());
        order.setCancellationReason(reason);

        Order savedOrder = orderRepository.save(order);
        log.info("Cancelled order: {} - Reason: {}", savedOrder.getOrderNumber(), reason);

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    public OrderDetailResponse completeOrder(UUID orderId) {
        Order order = orderRepository.findByIdWithDetails(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getBalanceDue().compareTo(BigDecimal.ZERO) > 0) {
            throw new IllegalStateException("Order has outstanding balance: " + order.getBalanceDue());
        }

        order.setStatus(OrderStatus.COMPLETED);
        order.setCompletedAt(LocalDateTime.now());

        Order savedOrder = orderRepository.save(order);
        log.info("Completed order: {}", savedOrder.getOrderNumber());

        // TODO: Trigger enrollment in customer-service via Feign
        // if (customerFeignClient.isPresent()) {
        //     EnrollmentRequest enrollmentRequest = ...;
        //     customerFeignClient.get().enrollCustomer(order.getCustomerId(), enrollmentRequest);
        // }

        return orderMapper.toDetailResponse(savedOrder);
    }

    @Override
    public void deleteOrder(UUID orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only draft orders can be deleted");
        }

        orderRepository.delete(order);
        log.info("Deleted order: {}", orderId);
    }

    private OrderItem createOrderItem(OrderItemRequest request, BillingFrequency billingFrequency) {
        // Default values
        String planCode = "PLN-" + request.getPlanId().toString().substring(0, 8);
        String planName = "Healthcare Plan";
        String metalTier = "SILVER";
        BigDecimal unitPrice = BigDecimal.valueOf(350.00);
        Integer planYear = java.time.LocalDate.now().getYear();

        // Fetch plan details from plans-service
        if (planFeignClient.isPresent()) {
            try {
                PlanDetailResponse plan = planFeignClient.get().getPlanById(request.getPlanId());
                planCode = plan.getPlanCode();
                planName = plan.getPlanName();
                metalTier = plan.getMetalTier();
                planYear = plan.getPlanYear();

                // Get premium based on billing frequency
                unitPrice = switch (billingFrequency) {
                    case MONTHLY -> plan.getMonthlyPremium();
                    case QUARTERLY -> plan.getMonthlyPremium().multiply(BigDecimal.valueOf(3));
                    case SEMI_ANNUAL -> plan.getMonthlyPremium().multiply(BigDecimal.valueOf(6));
                    case ANNUAL -> plan.getAnnualPremium() != null ?
                        plan.getAnnualPremium() :
                        plan.getMonthlyPremium().multiply(BigDecimal.valueOf(12));
                };

                log.debug("Fetched plan: {} - {} @ ${}/{}",
                    planCode, planName, unitPrice, billingFrequency);
            } catch (Exception e) {
                log.warn("Failed to fetch plan details, using defaults: {}", e.getMessage());
            }
        }

        BigDecimal subsidy = request.getSubsidyAmount() != null ? request.getSubsidyAmount() : BigDecimal.ZERO;
        BigDecimal discount = BigDecimal.ZERO;
        int qty = request.getQuantity() != null ? request.getQuantity() : 1;

        BigDecimal totalPrice = unitPrice.multiply(BigDecimal.valueOf(qty))
            .subtract(discount)
            .subtract(subsidy);

        if (totalPrice.compareTo(BigDecimal.ZERO) < 0) {
            totalPrice = BigDecimal.ZERO;
        }

        return OrderItem.builder()
            .planId(request.getPlanId())
            .planCode(planCode)
            .planName(planName)
            .planYear(planYear)
            .metalTier(metalTier)
            .description("Healthcare plan premium - " + billingFrequency.name().toLowerCase())
            .quantity(qty)
            .unitPrice(unitPrice)
            .discountAmount(discount)
            .subsidyAmount(subsidy)
            .totalPrice(totalPrice)
            .includeDependents(Boolean.TRUE.equals(request.getIncludeDependents()))
            .dependentCount(0)
            .build();
    }

    private void applyPromoCode(Order order, String promoCode) {
        // TODO: Validate promo code via a promotion service
        // For now, apply a simple 10% discount for any code
        BigDecimal discount = order.getSubtotal().multiply(BigDecimal.valueOf(0.10));
        order.setDiscountAmount(discount);
        order.recalculateTotals();
        log.info("Applied promo code {} - Discount: ${}", promoCode, discount);
    }

    private String generateOrderNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        int random = (int) (Math.random() * 1000);
        return String.format("ORD-%s-%03d", timestamp, random);
    }

    private Sort buildSort(String sortBy, String sortDirection) {
        String field = StringUtils.hasText(sortBy) ? sortBy : "createdAt";
        Sort.Direction direction = "asc".equalsIgnoreCase(sortDirection) ? Sort.Direction.ASC : Sort.Direction.DESC;
        return Sort.by(direction, field);
    }
}
EOF
echo -e "${GREEN}✓${NC} OrderServiceImpl.java (with Feign clients)"

# =============================================================================
# CUSTOMER SERVICE - Enable Feign for Plans Service
# =============================================================================
echo ""
echo -e "${CYAN}Configuring Customer Service Feign Integration...${NC}"

CUSTOMER_CONFIG_DIR="microservices/customer-onboarding-service/customer-api/src/main/java/com/healthcare/customer/api/config"
mkdir -p "$CUSTOMER_CONFIG_DIR"

cat > "$CUSTOMER_CONFIG_DIR/FeignConfig.java" << 'EOF'
package com.healthcare.customer.api.config;

import feign.Logger;
import feign.Request;
import feign.Retryer;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

@Configuration
@EnableFeignClients(basePackages = "com.healthcare.plans.client")
public class FeignConfig {

    @Bean
    public Logger.Level feignLoggerLevel() {
        return Logger.Level.BASIC;
    }

    @Bean
    public Request.Options requestOptions() {
        return new Request.Options(
            5, TimeUnit.SECONDS,
            10, TimeUnit.SECONDS,
            true
        );
    }

    @Bean
    public Retryer retryer() {
        return new Retryer.Default(100, 1000, 3);
    }
}
EOF
echo -e "${GREEN}✓${NC} FeignConfig.java (Customer Service)"

# =============================================================================
# UPDATE POMs - Add Feign Dependencies
# =============================================================================
echo ""
echo -e "${CYAN}Updating POM files with Feign dependencies...${NC}"

# Update Order Service parent POM to include Spring Cloud OpenFeign
cat > "microservices/order-service/order-api/pom-feign-addition.xml" << 'EOF'
<!-- Add this dependency to order-api/pom.xml -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>
EOF

# Update Customer Service parent POM
cat > "microservices/customer-onboarding-service/customer-api/pom-feign-addition.xml" << 'EOF'
<!-- Add this dependency to customer-api/pom.xml -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-openfeign</artifactId>
</dependency>

<!-- Add Plans Service client -->
<dependency>
    <groupId>com.healthcare.plans</groupId>
    <artifactId>plans-api-client</artifactId>
</dependency>
<dependency>
    <groupId>com.healthcare.plans</groupId>
    <artifactId>plans-common</artifactId>
</dependency>
EOF

echo -e "${GREEN}✓${NC} POM dependency notes created"

# =============================================================================
# UPDATE APPLICATION PROPERTIES
# =============================================================================
echo ""
echo -e "${CYAN}Updating application properties with service URLs...${NC}"

# Order Service
cat >> "microservices/order-service/order-api/src/main/resources/application-local.yml" << 'EOF'

# Feign client configuration
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
        loggerLevel: BASIC
EOF

# Customer Service
cat >> "microservices/customer-onboarding-service/customer-api/src/main/resources/application-local.yml" << 'EOF'

# Feign client configuration
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 10000
        loggerLevel: BASIC
EOF

echo -e "${GREEN}✓${NC} Application properties updated"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Feign Integration Setup Complete!                               ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Manual steps required:${NC}"
echo ""
echo "1. Add to order-api/pom.xml (inside <dependencies>):"
echo "   <dependency>"
echo "       <groupId>org.springframework.cloud</groupId>"
echo "       <artifactId>spring-cloud-starter-openfeign</artifactId>"
echo "   </dependency>"
echo ""
echo "2. Add to customer-api/pom.xml (inside <dependencies>):"
echo "   <dependency>"
echo "       <groupId>org.springframework.cloud</groupId>"
echo "       <artifactId>spring-cloud-starter-openfeign</artifactId>"
echo "   </dependency>"
echo "   <dependency>"
echo "       <groupId>com.healthcare.plans</groupId>"
echo "       <artifactId>plans-api-client</artifactId>"
echo "   </dependency>"
echo "   <dependency>"
echo "       <groupId>com.healthcare.plans</groupId>"
echo "       <artifactId>plans-common</artifactId>"
echo "   </dependency>"
echo ""
echo "3. Rebuild all services:"
echo "   cd microservices/plans-service && mvn clean install -DskipTests"
echo "   cd ../customer-onboarding-service && mvn clean install -DskipTests"
echo "   cd ../order-service && mvn clean install -DskipTests"
echo ""
echo "4. Restart services in order:"
echo "   - Plans Service (8081)"
echo "   - Customer Service (8083)"
echo "   - Order Service (8084)"