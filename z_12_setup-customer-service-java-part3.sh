#!/bin/bash

# =============================================================================
# Customer Onboarding Service - Java Source Files Generator (Part 3)
# =============================================================================
# Creates: API Client, API Stub, Controllers, Config, Application, Migrations
# =============================================================================

set -e

BASE_DIR="microservices/customer-onboarding-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Customer Onboarding Service - Part 3 (API, Config, Migrations)           ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# API CLIENT
# =============================================================================
echo -e "${CYAN}Creating API Client...${NC}"

CLIENT_DIR="$BASE_DIR/customer-api-client/src/main/java/com/healthcare/customer/client"
mkdir -p "$CLIENT_DIR"

cat > "$CLIENT_DIR/CustomerApiClient.java" << 'EOF'
package com.healthcare.customer.client;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;

import java.util.UUID;

public interface CustomerApiClient {

    CustomerDetailResponse createCustomer(CreateCustomerRequest request);

    CustomerDetailResponse getCustomerById(UUID customerId);

    CustomerDetailResponse getCustomerByEmail(String email);

    PagedResponse<CustomerResponse> searchCustomers(CustomerSearchRequest request);

    CustomerDetailResponse updateCustomer(UUID customerId, UpdateCustomerRequest request);

    void deleteCustomer(UUID customerId);

    void activateCustomer(UUID customerId);

    boolean isEmailAvailable(String email);
}
EOF
echo -e "${GREEN}✓${NC} CustomerApiClient.java"

cat > "$CLIENT_DIR/EnrollmentApiClient.java" << 'EOF'
package com.healthcare.customer.client;

import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;

import java.util.List;
import java.util.UUID;

public interface EnrollmentApiClient {

    EligibilityResponse checkEligibility(UUID customerId, UUID planId);

    EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request);

    List<EnrollmentResponse> getCustomerEnrollments(UUID customerId);

    List<EnrollmentResponse> getActiveEnrollments(UUID customerId);

    void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason);
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentApiClient.java"

cat > "$CLIENT_DIR/CustomerFeignClient.java" << 'EOF'
package com.healthcare.customer.client;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "customer-service", url = "${customer.service.url:http://localhost:8082}")
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
# API STUB
# =============================================================================
echo ""
echo -e "${CYAN}Creating API Stub...${NC}"

STUB_DIR="$BASE_DIR/customer-api-stub/src/main/java/com/healthcare/customer/stub"
mkdir -p "$STUB_DIR"

cat > "$STUB_DIR/CustomerApiStubImpl.java" << 'EOF'
package com.healthcare.customer.stub;

import com.healthcare.customer.client.CustomerApiClient;
import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.service.CustomerService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CustomerApiStubImpl implements CustomerApiClient {

    private final CustomerService customerService;

    @Override
    public CustomerDetailResponse createCustomer(CreateCustomerRequest request) {
        return customerService.createCustomer(request);
    }

    @Override
    public CustomerDetailResponse getCustomerById(UUID customerId) {
        return customerService.getCustomerById(customerId);
    }

    @Override
    public CustomerDetailResponse getCustomerByEmail(String email) {
        return customerService.getCustomerByEmail(email);
    }

    @Override
    public PagedResponse<CustomerResponse> searchCustomers(CustomerSearchRequest request) {
        return customerService.searchCustomers(request);
    }

    @Override
    public CustomerDetailResponse updateCustomer(UUID customerId, UpdateCustomerRequest request) {
        return customerService.updateCustomer(customerId, request);
    }

    @Override
    public void deleteCustomer(UUID customerId) {
        customerService.deleteCustomer(customerId);
    }

    @Override
    public void activateCustomer(UUID customerId) {
        customerService.activateCustomer(customerId);
    }

    @Override
    public boolean isEmailAvailable(String email) {
        return customerService.isEmailAvailable(email);
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerApiStubImpl.java"

cat > "$STUB_DIR/EnrollmentApiStubImpl.java" << 'EOF'
package com.healthcare.customer.stub;

import com.healthcare.customer.client.EnrollmentApiClient;
import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.service.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class EnrollmentApiStubImpl implements EnrollmentApiClient {

    private final EnrollmentService enrollmentService;

    @Override
    public EligibilityResponse checkEligibility(UUID customerId, UUID planId) {
        return enrollmentService.checkEligibility(customerId, planId);
    }

    @Override
    public EnrollmentResponse enrollCustomer(UUID customerId, EnrollmentRequest request) {
        return enrollmentService.enrollCustomer(customerId, request);
    }

    @Override
    public List<EnrollmentResponse> getCustomerEnrollments(UUID customerId) {
        return enrollmentService.getCustomerEnrollments(customerId);
    }

    @Override
    public List<EnrollmentResponse> getActiveEnrollments(UUID customerId) {
        return enrollmentService.getActiveEnrollments(customerId);
    }

    @Override
    public void cancelEnrollment(UUID customerId, UUID enrollmentId, String reason) {
        enrollmentService.cancelEnrollment(customerId, enrollmentId, reason);
    }
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentApiStubImpl.java"

# =============================================================================
# CONTROLLERS
# =============================================================================
echo ""
echo -e "${CYAN}Creating Controllers...${NC}"

CONTROLLER_DIR="$BASE_DIR/customer-api/src/main/java/com/healthcare/customer/api/controller"
mkdir -p "$CONTROLLER_DIR"

cat > "$CONTROLLER_DIR/CustomerController.java" << 'EOF'
package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.*;
import com.healthcare.customer.common.dto.response.*;
import com.healthcare.customer.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/customers")
@RequiredArgsConstructor
@Tag(name = "Customer", description = "Customer management APIs")
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping
    @Operation(summary = "Create a new customer", description = "Register a new customer in the system")
    public ResponseEntity<CustomerDetailResponse> createCustomer(
            @Valid @RequestBody CreateCustomerRequest request) {
        CustomerDetailResponse response = customerService.createCustomer(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{customerId}")
    @Operation(summary = "Get customer by ID", description = "Retrieve customer details by UUID")
    public ResponseEntity<CustomerDetailResponse> getCustomerById(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        CustomerDetailResponse response = customerService.getCustomerById(customerId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/number/{customerNumber}")
    @Operation(summary = "Get customer by number", description = "Retrieve customer by customer number")
    public ResponseEntity<CustomerDetailResponse> getCustomerByNumber(
            @Parameter(description = "Customer number") @PathVariable String customerNumber) {
        CustomerDetailResponse response = customerService.getCustomerByNumber(customerNumber);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/email/{email}")
    @Operation(summary = "Get customer by email", description = "Retrieve customer by email address")
    public ResponseEntity<CustomerDetailResponse> getCustomerByEmail(
            @Parameter(description = "Email address") @PathVariable String email) {
        CustomerDetailResponse response = customerService.getCustomerByEmail(email);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/search")
    @Operation(summary = "Search customers", description = "Search customers with filters and pagination")
    public ResponseEntity<PagedResponse<CustomerResponse>> searchCustomers(
            @Valid @RequestBody CustomerSearchRequest request) {
        PagedResponse<CustomerResponse> response = customerService.searchCustomers(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{customerId}")
    @Operation(summary = "Update customer", description = "Update customer information")
    public ResponseEntity<CustomerDetailResponse> updateCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody UpdateCustomerRequest request) {
        CustomerDetailResponse response = customerService.updateCustomer(customerId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{customerId}")
    @Operation(summary = "Delete customer", description = "Soft delete a customer")
    public ResponseEntity<Void> deleteCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        customerService.deleteCustomer(customerId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{customerId}/activate")
    @Operation(summary = "Activate customer", description = "Activate a pending customer")
    public ResponseEntity<Void> activateCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        customerService.activateCustomer(customerId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{customerId}/suspend")
    @Operation(summary = "Suspend customer", description = "Suspend a customer account")
    public ResponseEntity<Void> suspendCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @RequestParam(required = false) String reason) {
        customerService.suspendCustomer(customerId, reason);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/email-available")
    @Operation(summary = "Check email availability", description = "Check if an email is available for registration")
    public ResponseEntity<Boolean> isEmailAvailable(
            @Parameter(description = "Email address") @RequestParam String email) {
        boolean available = customerService.isEmailAvailable(email);
        return ResponseEntity.ok(available);
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerController.java"

cat > "$CONTROLLER_DIR/AddressController.java" << 'EOF'
package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.AddressRequest;
import com.healthcare.customer.common.dto.response.AddressResponse;
import com.healthcare.customer.service.AddressService;
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
@RequestMapping("/api/v1/customers/{customerId}/addresses")
@RequiredArgsConstructor
@Tag(name = "Address", description = "Customer address management APIs")
public class AddressController {

    private final AddressService addressService;

    @PostMapping
    @Operation(summary = "Add address", description = "Add a new address for a customer")
    public ResponseEntity<AddressResponse> addAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody AddressRequest request) {
        AddressResponse response = addressService.addAddress(customerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "Get addresses", description = "Get all addresses for a customer")
    public ResponseEntity<List<AddressResponse>> getAddresses(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<AddressResponse> responses = addressService.getCustomerAddresses(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/primary")
    @Operation(summary = "Get primary address", description = "Get the primary address for a customer")
    public ResponseEntity<AddressResponse> getPrimaryAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        AddressResponse response = addressService.getPrimaryAddress(customerId);
        if (response == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{addressId}")
    @Operation(summary = "Update address", description = "Update an existing address")
    public ResponseEntity<AddressResponse> updateAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Address UUID") @PathVariable UUID addressId,
            @Valid @RequestBody AddressRequest request) {
        AddressResponse response = addressService.updateAddress(customerId, addressId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{addressId}")
    @Operation(summary = "Delete address", description = "Delete an address")
    public ResponseEntity<Void> deleteAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Address UUID") @PathVariable UUID addressId) {
        addressService.deleteAddress(customerId, addressId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{addressId}/set-primary")
    @Operation(summary = "Set primary address", description = "Set an address as the primary address")
    public ResponseEntity<Void> setPrimaryAddress(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Address UUID") @PathVariable UUID addressId) {
        addressService.setPrimaryAddress(customerId, addressId);
        return ResponseEntity.ok().build();
    }
}
EOF
echo -e "${GREEN}✓${NC} AddressController.java"

cat > "$CONTROLLER_DIR/DependentController.java" << 'EOF'
package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.DependentRequest;
import com.healthcare.customer.common.dto.response.DependentResponse;
import com.healthcare.customer.service.DependentService;
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
@RequestMapping("/api/v1/customers/{customerId}/dependents")
@RequiredArgsConstructor
@Tag(name = "Dependent", description = "Customer dependent management APIs")
public class DependentController {

    private final DependentService dependentService;

    @PostMapping
    @Operation(summary = "Add dependent", description = "Add a new dependent for a customer")
    public ResponseEntity<DependentResponse> addDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody DependentRequest request) {
        DependentResponse response = dependentService.addDependent(customerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    @Operation(summary = "Get dependents", description = "Get all dependents for a customer")
    public ResponseEntity<List<DependentResponse>> getDependents(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<DependentResponse> responses = dependentService.getCustomerDependents(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{dependentId}")
    @Operation(summary = "Get dependent", description = "Get a specific dependent")
    public ResponseEntity<DependentResponse> getDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Dependent UUID") @PathVariable UUID dependentId) {
        DependentResponse response = dependentService.getDependentById(customerId, dependentId);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{dependentId}")
    @Operation(summary = "Update dependent", description = "Update a dependent's information")
    public ResponseEntity<DependentResponse> updateDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Dependent UUID") @PathVariable UUID dependentId,
            @Valid @RequestBody DependentRequest request) {
        DependentResponse response = dependentService.updateDependent(customerId, dependentId, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{dependentId}")
    @Operation(summary = "Delete dependent", description = "Remove a dependent")
    public ResponseEntity<Void> deleteDependent(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Dependent UUID") @PathVariable UUID dependentId) {
        dependentService.deleteDependent(customerId, dependentId);
        return ResponseEntity.noContent().build();
    }
}
EOF
echo -e "${GREEN}✓${NC} DependentController.java"

cat > "$CONTROLLER_DIR/EnrollmentController.java" << 'EOF'
package com.healthcare.customer.api.controller;

import com.healthcare.customer.common.dto.request.EnrollmentRequest;
import com.healthcare.customer.common.dto.response.EligibilityResponse;
import com.healthcare.customer.common.dto.response.EnrollmentResponse;
import com.healthcare.customer.service.EnrollmentService;
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
@RequestMapping("/api/v1/customers/{customerId}")
@RequiredArgsConstructor
@Tag(name = "Enrollment", description = "Plan enrollment and eligibility APIs")
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    @PostMapping("/eligibility/{planId}")
    @Operation(summary = "Check eligibility", description = "Check customer eligibility for a specific plan")
    public ResponseEntity<EligibilityResponse> checkEligibility(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Plan UUID") @PathVariable UUID planId) {
        EligibilityResponse response = enrollmentService.checkEligibility(customerId, planId);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/enrollments")
    @Operation(summary = "Enroll customer", description = "Enroll a customer in a healthcare plan")
    public ResponseEntity<EnrollmentResponse> enrollCustomer(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Valid @RequestBody EnrollmentRequest request) {
        EnrollmentResponse response = enrollmentService.enrollCustomer(customerId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/enrollments")
    @Operation(summary = "Get enrollments", description = "Get all enrollments for a customer")
    public ResponseEntity<List<EnrollmentResponse>> getEnrollments(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<EnrollmentResponse> responses = enrollmentService.getCustomerEnrollments(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/enrollments/active")
    @Operation(summary = "Get active enrollments", description = "Get currently active enrollments")
    public ResponseEntity<List<EnrollmentResponse>> getActiveEnrollments(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId) {
        List<EnrollmentResponse> responses = enrollmentService.getActiveEnrollments(customerId);
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/enrollments/{enrollmentId}")
    @Operation(summary = "Get enrollment", description = "Get enrollment details by ID")
    public ResponseEntity<EnrollmentResponse> getEnrollment(
            @Parameter(description = "Enrollment UUID") @PathVariable UUID enrollmentId) {
        EnrollmentResponse response = enrollmentService.getEnrollmentById(enrollmentId);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/enrollments/{enrollmentId}")
    @Operation(summary = "Cancel enrollment", description = "Cancel an enrollment")
    public ResponseEntity<Void> cancelEnrollment(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Enrollment UUID") @PathVariable UUID enrollmentId,
            @RequestParam(required = false) String reason) {
        enrollmentService.cancelEnrollment(customerId, enrollmentId, reason);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/enrollments/{enrollmentId}/terminate")
    @Operation(summary = "Terminate enrollment", description = "Terminate an enrollment")
    public ResponseEntity<Void> terminateEnrollment(
            @Parameter(description = "Customer UUID") @PathVariable UUID customerId,
            @Parameter(description = "Enrollment UUID") @PathVariable UUID enrollmentId,
            @RequestParam(required = false) String reason) {
        enrollmentService.terminateEnrollment(customerId, enrollmentId, reason);
        return ResponseEntity.ok().build();
    }
}
EOF
echo -e "${GREEN}✓${NC} EnrollmentController.java"

# =============================================================================
# CONFIGURATION
# =============================================================================
echo ""
echo -e "${CYAN}Creating Configuration Classes...${NC}"

CONFIG_DIR="$BASE_DIR/customer-api/src/main/java/com/healthcare/customer/api/config"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/OpenApiConfig.java" << 'EOF'
package com.healthcare.customer.api.config;

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
                .title("Customer Onboarding Service API")
                .description("API for customer registration, profile management, eligibility verification, and plan enrollment")
                .version("1.0.0")
                .contact(new Contact()
                    .name("Healthcare Platform Team")
                    .email("support@healthcare-platform.com"))
                .license(new License()
                    .name("Apache 2.0")
                    .url("https://www.apache.org/licenses/LICENSE-2.0")))
            .servers(List.of(
                new Server().url("http://localhost:8082").description("Local Development")
            ));
    }
}
EOF
echo -e "${GREEN}✓${NC} OpenApiConfig.java"

cat > "$CONFIG_DIR/GlobalExceptionHandler.java" << 'EOF'
package com.healthcare.customer.api.config;

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

APP_DIR="$BASE_DIR/customer-api/src/main/java/com/healthcare/customer/api"

cat > "$APP_DIR/CustomerApiApplication.java" << 'EOF'
package com.healthcare.customer.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.healthcare.customer")
@EntityScan(basePackages = "com.healthcare.customer.common.model")
@EnableJpaRepositories(basePackages = "com.healthcare.customer.dao.repository")
public class CustomerApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(CustomerApiApplication.class, args);
    }
}
EOF
echo -e "${GREEN}✓${NC} CustomerApiApplication.java"

# =============================================================================
# RESOURCES
# =============================================================================
echo ""
echo -e "${CYAN}Creating Application Properties...${NC}"

RESOURCES_DIR="$BASE_DIR/customer-api/src/main/resources"
mkdir -p "$RESOURCES_DIR"

cat > "$RESOURCES_DIR/application.yml" << 'EOF'
spring:
  application:
    name: customer-service
  profiles:
    active: local

server:
  port: 8082

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
    url: jdbc:postgresql://localhost:5432/customer_db
    username: customer_user
    password: customer_password
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

# Plans Service for inter-service communication
plans:
  service:
    url: http://localhost:8081

logging:
  level:
    com.healthcare.customer: DEBUG
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
-- Customer Onboarding Service - Initial Schema
-- =============================================================================

-- Customers table
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    customer_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phone VARCHAR(20),
    mobile_phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20),
    ssn_last4 VARCHAR(4),
    ssn_encrypted VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    preferred_language VARCHAR(10) DEFAULT 'en',
    marketing_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    sms_opt_in BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_ssn_last4 ON customers(ssn_last4);
CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_customers_customer_number ON customers(customer_number);

-- Customer addresses table
CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL,
    address_line1 VARCHAR(200) NOT NULL,
    address_line2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    state_code VARCHAR(2) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(2) NOT NULL DEFAULT 'US',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_addresses_customer_id ON customer_addresses(customer_id);
CREATE INDEX idx_addresses_zip_code ON customer_addresses(zip_code);

-- Customer dependents table
CREATE TABLE customer_dependents (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20),
    relationship VARCHAR(20) NOT NULL,
    ssn_last4 VARCHAR(4),
    is_disabled BOOLEAN NOT NULL DEFAULT FALSE,
    is_student BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dependents_customer_id ON customer_dependents(customer_id);

-- Customer documents table
CREATE TABLE customer_documents (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    document_type VARCHAR(30) NOT NULL,
    document_name VARCHAR(200) NOT NULL,
    file_path VARCHAR(500),
    file_size BIGINT,
    mime_type VARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    expiration_date DATE,
    verified_by VARCHAR(100),
    rejection_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_documents_customer_id ON customer_documents(customer_id);
CREATE INDEX idx_documents_status ON customer_documents(status);

-- Eligibility checks table
CREATE TABLE eligibility_checks (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    check_date TIMESTAMP NOT NULL,
    expiration_date TIMESTAMP,
    eligibility_reason VARCHAR(500),
    income_verified BOOLEAN NOT NULL DEFAULT FALSE,
    residence_verified BOOLEAN NOT NULL DEFAULT FALSE,
    age_verified BOOLEAN NOT NULL DEFAULT FALSE,
    checked_by VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_eligibility_customer_id ON eligibility_checks(customer_id);
CREATE INDEX idx_eligibility_plan_id ON eligibility_checks(plan_id);

-- Customer plan enrollments table
CREATE TABLE customer_plan_enrollments (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL,
    plan_code VARCHAR(50) NOT NULL,
    plan_name VARCHAR(200) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    effective_date DATE NOT NULL,
    termination_date DATE,
    monthly_premium DECIMAL(10,2),
    subsidy_amount DECIMAL(10,2) DEFAULT 0,
    member_id VARCHAR(50),
    group_number VARCHAR(50),
    include_dependents BOOLEAN NOT NULL DEFAULT FALSE,
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    cancellation_reason VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_enrollments_customer_id ON customer_plan_enrollments(customer_id);
CREATE INDEX idx_enrollments_plan_id ON customer_plan_enrollments(plan_id);
CREATE INDEX idx_enrollments_status ON customer_plan_enrollments(status);
CREATE INDEX idx_enrollments_effective_date ON customer_plan_enrollments(effective_date);
EOF
echo -e "${GREEN}✓${NC} V1__init_schema.sql"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Part 3 Complete - API, Config, Migrations Created!                       ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Build and run:${NC}"
echo "  cd microservices/customer-onboarding-service"
echo "  mvn clean install -DskipTests"
echo "  cd customer-api"
echo "  mvn spring-boot:run -Dspring-boot.run.profiles=local"
echo ""
echo -e "${YELLOW}Test endpoints:${NC}"
echo "  Swagger UI: http://localhost:8082/swagger-ui.html"
echo "  Health:     http://localhost:8082/actuator/health"