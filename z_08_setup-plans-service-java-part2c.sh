#!/bin/bash

# =============================================================================
# Plans Service - Java Source Files Generator (Part 2c - API Layers)
# =============================================================================

set -e

BASE_DIR="microservices/plans-service"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Plans Service - Part 2c (API Layers)                                  ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# =============================================================================
# API-CLIENT: Interfaces
# =============================================================================
echo -e "${CYAN}  Creating API-Client...${NC}"

CLIENT_DIR="$BASE_DIR/plans-api-client/src/main/java/com/healthcare/plans/api/client"
mkdir -p "$CLIENT_DIR"

cat > "$CLIENT_DIR/PlanApiClient.java" << 'EOF'
package com.healthcare.plans.api.client;

import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;

import java.util.List;
import java.util.UUID;

public interface PlanApiClient {
    PlanDetailResponse createPlan(CreatePlanRequest request);
    PlanDetailResponse getPlanById(UUID planId);
    PlanDetailResponse getPlanByCode(String planCode);
    PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request);
    PlanDetailResponse updatePlan(UUID planId, UpdatePlanRequest request);
    void deletePlan(UUID planId);
    List<PlanResponse> getPlansByIds(List<UUID> planIds);
    boolean isPlanActive(UUID planId);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanApiClient.java"

cat > "$CLIENT_DIR/ReferenceDataApiClient.java" << 'EOF'
package com.healthcare.plans.api.client;

import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;

import java.util.List;

public interface ReferenceDataApiClient {
    List<StateResponse> getAllStates();
    List<AgeGroupResponse> getAllAgeGroups();
    List<CategoryResponse> getAllCategories();
}
EOF
echo -e "${GREEN}✓${NC} Created: ReferenceDataApiClient.java"

# Feign Client
FEIGN_DIR="$CLIENT_DIR/feign"
mkdir -p "$FEIGN_DIR"

cat > "$FEIGN_DIR/PlanFeignClient.java" << 'EOF'
package com.healthcare.plans.api.client.feign;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@FeignClient(name = "plans-service", url = "${services.plans.url:http://localhost:8081}")
public interface PlanFeignClient extends PlanApiClient {

    @Override
    @PostMapping("/api/v1/plans")
    PlanDetailResponse createPlan(@RequestBody CreatePlanRequest request);

    @Override
    @GetMapping("/api/v1/plans/{planId}")
    PlanDetailResponse getPlanById(@PathVariable("planId") UUID planId);

    @Override
    @GetMapping("/api/v1/plans/code/{planCode}")
    PlanDetailResponse getPlanByCode(@PathVariable("planCode") String planCode);

    @Override
    @PostMapping("/api/v1/plans/search")
    PagedResponse<PlanResponse> searchPlans(@RequestBody PlanSearchRequest request);

    @Override
    @PutMapping("/api/v1/plans/{planId}")
    PlanDetailResponse updatePlan(@PathVariable("planId") UUID planId, @RequestBody UpdatePlanRequest request);

    @Override
    @DeleteMapping("/api/v1/plans/{planId}")
    void deletePlan(@PathVariable("planId") UUID planId);

    @Override
    @PostMapping("/api/v1/plans/bulk")
    List<PlanResponse> getPlansByIds(@RequestBody List<UUID> planIds);

    @Override
    @GetMapping("/api/v1/plans/{planId}/active")
    boolean isPlanActive(@PathVariable("planId") UUID planId);
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanFeignClient.java"

# =============================================================================
# API-STUB: Implementations
# =============================================================================
echo ""
echo -e "${CYAN}  Creating API-Stub...${NC}"

STUB_DIR="$BASE_DIR/plans-api-stub/src/main/java/com/healthcare/plans/api/stub"
mkdir -p "$STUB_DIR"

cat > "$STUB_DIR/PlanApiStubImpl.java" << 'EOF'
package com.healthcare.plans.api.stub;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import com.healthcare.plans.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PlanApiStubImpl implements PlanApiClient {

    private final PlanService planService;

    @Override
    public PlanDetailResponse createPlan(CreatePlanRequest request) {
        return planService.createPlan(request);
    }

    @Override
    public PlanDetailResponse getPlanById(UUID planId) {
        return planService.getPlanById(planId);
    }

    @Override
    public PlanDetailResponse getPlanByCode(String planCode) {
        return planService.getPlanByCode(planCode);
    }

    @Override
    public PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request) {
        return planService.searchPlans(request);
    }

    @Override
    public PlanDetailResponse updatePlan(UUID planId, UpdatePlanRequest request) {
        return planService.updatePlan(planId, request);
    }

    @Override
    public void deletePlan(UUID planId) {
        planService.deletePlan(planId);
    }

    @Override
    public List<PlanResponse> getPlansByIds(List<UUID> planIds) {
        return planService.getPlansByIds(planIds);
    }

    @Override
    public boolean isPlanActive(UUID planId) {
        return planService.isPlanActive(planId);
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanApiStubImpl.java"

cat > "$STUB_DIR/ReferenceDataApiStubImpl.java" << 'EOF'
package com.healthcare.plans.api.stub;

import com.healthcare.plans.api.client.ReferenceDataApiClient;
import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;
import com.healthcare.plans.service.ReferenceDataService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class ReferenceDataApiStubImpl implements ReferenceDataApiClient {

    private final ReferenceDataService referenceDataService;

    @Override
    public List<StateResponse> getAllStates() {
        return referenceDataService.getAllStates();
    }

    @Override
    public List<AgeGroupResponse> getAllAgeGroups() {
        return referenceDataService.getAllAgeGroups();
    }

    @Override
    public List<CategoryResponse> getAllCategories() {
        return referenceDataService.getAllCategories();
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: ReferenceDataApiStubImpl.java"

# =============================================================================
# API: Controllers
# =============================================================================
echo ""
echo -e "${CYAN}  Creating API Controllers...${NC}"

CONTROLLER_DIR="$BASE_DIR/plans-api/src/main/java/com/healthcare/plans/api/controller"
mkdir -p "$CONTROLLER_DIR"

cat > "$CONTROLLER_DIR/PlanController.java" << 'EOF'
package com.healthcare.plans.api.controller;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.request.CreatePlanRequest;
import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.request.UpdatePlanRequest;
import com.healthcare.plans.common.dto.response.PagedResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PlanResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/plans")
@RequiredArgsConstructor
@Tag(name = "Plans", description = "Healthcare Plan Management APIs")
public class PlanController {

    private final PlanApiClient planApiClient;

    @PostMapping
    @Operation(summary = "Create a new plan")
    public ResponseEntity<PlanDetailResponse> createPlan(@Valid @RequestBody CreatePlanRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(planApiClient.createPlan(request));
    }

    @GetMapping("/{planId}")
    @Operation(summary = "Get plan by ID")
    public ResponseEntity<PlanDetailResponse> getPlanById(@PathVariable UUID planId) {
        return ResponseEntity.ok(planApiClient.getPlanById(planId));
    }

    @GetMapping("/code/{planCode}")
    @Operation(summary = "Get plan by code")
    public ResponseEntity<PlanDetailResponse> getPlanByCode(@PathVariable String planCode) {
        return ResponseEntity.ok(planApiClient.getPlanByCode(planCode));
    }

    @PostMapping("/search")
    @Operation(summary = "Search plans with filters")
    public ResponseEntity<PagedResponse<PlanResponse>> searchPlans(@RequestBody PlanSearchRequest request) {
        return ResponseEntity.ok(planApiClient.searchPlans(request));
    }

    @PutMapping("/{planId}")
    @Operation(summary = "Update a plan")
    public ResponseEntity<PlanDetailResponse> updatePlan(@PathVariable UUID planId, @Valid @RequestBody UpdatePlanRequest request) {
        return ResponseEntity.ok(planApiClient.updatePlan(planId, request));
    }

    @DeleteMapping("/{planId}")
    @Operation(summary = "Delete a plan (soft delete)")
    public ResponseEntity<Void> deletePlan(@PathVariable UUID planId) {
        planApiClient.deletePlan(planId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/bulk")
    @Operation(summary = "Get plans by IDs")
    public ResponseEntity<List<PlanResponse>> getPlansByIds(@RequestBody List<UUID> planIds) {
        return ResponseEntity.ok(planApiClient.getPlansByIds(planIds));
    }

    @GetMapping("/{planId}/active")
    @Operation(summary = "Check if plan is active")
    public ResponseEntity<Boolean> isPlanActive(@PathVariable UUID planId) {
        return ResponseEntity.ok(planApiClient.isPlanActive(planId));
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlanController.java"

cat > "$CONTROLLER_DIR/ReferenceDataController.java" << 'EOF'
package com.healthcare.plans.api.controller;

import com.healthcare.plans.api.client.ReferenceDataApiClient;
import com.healthcare.plans.common.dto.response.AgeGroupResponse;
import com.healthcare.plans.common.dto.response.CategoryResponse;
import com.healthcare.plans.common.dto.response.StateResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/reference")
@RequiredArgsConstructor
@Tag(name = "Reference Data", description = "Reference Data APIs")
public class ReferenceDataController {

    private final ReferenceDataApiClient referenceDataApiClient;

    @GetMapping("/states")
    @Operation(summary = "Get all US states")
    public ResponseEntity<List<StateResponse>> getAllStates() {
        return ResponseEntity.ok(referenceDataApiClient.getAllStates());
    }

    @GetMapping("/age-groups")
    @Operation(summary = "Get all age groups")
    public ResponseEntity<List<AgeGroupResponse>> getAllAgeGroups() {
        return ResponseEntity.ok(referenceDataApiClient.getAllAgeGroups());
    }

    @GetMapping("/categories")
    @Operation(summary = "Get all plan categories")
    public ResponseEntity<List<CategoryResponse>> getAllCategories() {
        return ResponseEntity.ok(referenceDataApiClient.getAllCategories());
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: ReferenceDataController.java"

# =============================================================================
# API: Config
# =============================================================================
echo ""
echo -e "${CYAN}  Creating API Config...${NC}"

CONFIG_DIR="$BASE_DIR/plans-api/src/main/java/com/healthcare/plans/api/config"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/OpenApiConfig.java" << 'EOF'
package com.healthcare.plans.api.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI plansServiceOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Plans Service API")
                .description("Healthcare Plans Management Service")
                .version("1.0.0"));
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: OpenApiConfig.java"

cat > "$CONFIG_DIR/CacheConfig.java" << 'EOF'
package com.healthcare.plans.api.config;

import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCaching
public class CacheConfig {
}
EOF
echo -e "${GREEN}✓${NC} Created: CacheConfig.java"

# =============================================================================
# API: Exception Handling
# =============================================================================
EXCEPTION_DIR="$BASE_DIR/plans-api/src/main/java/com/healthcare/plans/api/exception"
mkdir -p "$EXCEPTION_DIR"

cat > "$EXCEPTION_DIR/GlobalExceptionHandler.java" << 'EOF'
package com.healthcare.plans.api.exception;

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
    public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex) {
        log.error("Illegal argument: {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse(LocalDateTime.now(), HttpStatus.BAD_REQUEST.value(), "Bad Request", ex.getMessage(), null));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationErrors(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            errors.put(fieldName, error.getDefaultMessage());
        });
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse(LocalDateTime.now(), HttpStatus.BAD_REQUEST.value(), "Validation Failed", "Request validation failed", errors));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        log.error("Unexpected error: ", ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse(LocalDateTime.now(), HttpStatus.INTERNAL_SERVER_ERROR.value(), "Internal Server Error", "An unexpected error occurred", null));
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: GlobalExceptionHandler.java"

cat > "$EXCEPTION_DIR/ErrorResponse.java" << 'EOF'
package com.healthcare.plans.api.exception;

import lombok.*;
import java.time.LocalDateTime;
import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponse {
    private LocalDateTime timestamp;
    private int status;
    private String error;
    private String message;
    private Map<String, String> details;
}
EOF
echo -e "${GREEN}✓${NC} Created: ErrorResponse.java"

# =============================================================================
# API: Main Application
# =============================================================================
APP_DIR="$BASE_DIR/plans-api/src/main/java/com/healthcare/plans/api"

cat > "$APP_DIR/PlansApiApplication.java" << 'EOF'
package com.healthcare.plans.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication(scanBasePackages = "com.healthcare.plans")
@EntityScan(basePackages = "com.healthcare.plans.common.model")
@EnableJpaRepositories(basePackages = "com.healthcare.plans.dao.repository")
public class PlansApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(PlansApiApplication.class, args);
    }
}
EOF
echo -e "${GREEN}✓${NC} Created: PlansApiApplication.java"

# =============================================================================
# API: Application Properties
# =============================================================================
echo ""
echo -e "${CYAN}  Creating Application Properties...${NC}"

RESOURCES_DIR="$BASE_DIR/plans-api/src/main/resources"
mkdir -p "$RESOURCES_DIR/db/migration"

cat > "$RESOURCES_DIR/application.yml" << 'EOF'
spring:
  application:
    name: plans-service
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}

server:
  port: ${SERVER_PORT:8081}

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics

springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html

logging:
  level:
    com.healthcare.plans: DEBUG
EOF
echo -e "${GREEN}✓${NC} Created: application.yml"

cat > "$RESOURCES_DIR/application-local.yml" << 'EOF'
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/plans_db
    username: plans_user
    password: plans_password
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
EOF
echo -e "${GREEN}✓${NC} Created: application-local.yml"

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}        Part 2c Complete - API Layers Created!                                ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Next: Run Part 3 for Flyway migrations${NC}"
