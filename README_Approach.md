# Development Approach

This document outlines the development approach, build order, data models, and synthetic data generation strategy for the Healthcare Plans AI Platform.

---

## Technology Stack (Confirmed)

| Component | Version/Choice |
|-----------|----------------|
| **JDK** | 21 (LTS) |
| **Spring Boot** | 3.5.6 |
| **Build Tool** | Maven (Multi-module) |
| **Database** | PostgreSQL 15+ |
| **API Documentation** | OpenAPI 3.0 (SpringDoc) |
| **Database Migration** | Flyway |
| **Testing** | JUnit 5 + Testcontainers |

---

## Maven Multi-Module Architecture

Each microservice follows a **consistent multi-module structure** enabling clean separation of concerns and inter-service communication via API clients.

### Module Structure Per Microservice

```
{service-name}/
├── pom.xml                          # Parent POM
│
├── {service}-common/                # Shared within this service
│   ├── {service}-common-models/     # JPA Entities
│   ├── {service}-common-dto/        # Request/Response DTOs
│   ├── {service}-common-utils/      # Utility classes
│   └── {service}-common-constants/  # Constants, Enums
│
├── {service}-dao/                   # Data Access Layer
│   └── Repositories, DB configs
│
├── {service}-service/               # Business Logic Layer
│   └── Service implementations
│
├── {service}-api-client/            # OpenAPI Client (for other services to use)
│   └── Generated/manual API interfaces + Feign clients
│
├── {service}-api-stub/              # API Implementation (business logic)
│   └── Implements api-client interfaces
│
└── {service}-api/                   # REST Controllers (Entry point)
    └── Controllers, Security, App config
```

### Module Dependency Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MAVEN MODULE DEPENDENCIES                              │
└─────────────────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────────┐
                    │      {service}-api       │  ← Spring Boot Application
                    │    (RestControllers)     │  ← @SpringBootApplication
                    └────────────┬─────────────┘
                                 │
                    depends on   │
                                 ▼
         ┌───────────────────────┴───────────────────────┐
         │                                               │
         ▼                                               ▼
┌─────────────────────┐                    ┌─────────────────────────┐
│ {service}-api-stub  │                    │ {other-service}-api-client│
│ (Implementation)    │                    │ (Inter-service calls)   │
└─────────┬───────────┘                    └─────────────────────────┘
          │
          │ depends on
          ▼
┌─────────────────────┐
│{service}-api-client │  ← API Interfaces (contracts)
│   (Interfaces)      │  ← DTOs for request/response
└─────────┬───────────┘
          │
          │ depends on
          ▼
┌─────────────────────┐
│ {service}-service   │  ← Business logic
└─────────┬───────────┘
          │
          │ depends on
          ▼
┌─────────────────────┐
│   {service}-dao     │  ← Repository interfaces
└─────────┬───────────┘
          │
          │ depends on
          ▼
┌─────────────────────────────────────────────────────┐
│              {service}-common-*                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ │
│  │ models  │ │   dto   │ │  utils  │ │ constants │ │
│  └─────────┘ └─────────┘ └─────────┘ └───────────┘ │
└─────────────────────────────────────────────────────┘
```

### Inter-Service Communication Pattern

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    INTER-SERVICE COMMUNICATION                              │
└─────────────────────────────────────────────────────────────────────────────┘

Example: order-service needs to call plans-service

ORDER-SERVICE                                    PLANS-SERVICE
─────────────                                    ─────────────

┌─────────────────────┐                         ┌─────────────────────┐
│   order-api         │                         │   plans-api         │
│                     │    HTTP/REST            │                     │
│  OrderController    │ ───────────────────────►│  PlanController     │
│                     │                         │                     │
└─────────┬───────────┘                         └─────────────────────┘
          │                                               ▲
          │ uses                                          │ implements
          ▼                                               │
┌─────────────────────┐                         ┌─────────┴───────────┐
│ plans-api-client    │ ◄─── same interface ───►│ plans-api-stub      │
│                     │                         │                     │
│ • PlanApiClient     │                         │ • PlanApiStubImpl   │
│   (Feign Client)    │                         │   (Business Logic)  │
│ • PlanDTO           │                         │                     │
│ • PlanSearchRequest │                         │                     │
└─────────────────────┘                         └─────────────────────┘

Maven dependency in order-service pom.xml:
┌─────────────────────────────────────────────────────────────────────────────┐
│ <dependency>                                                                │
│     <groupId>com.healthcare</groupId>                                       │
│     <artifactId>plans-api-client</artifactId>                              │
│     <version>${plans.service.version}</version>                            │
│ </dependency>                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Complete Project Structure

```
healthcare-plans-ai-platform/
│
├── microservices/
│   │
│   ├── pom.xml                              # Root parent POM (optional)
│   │
│   │── ═══════════════════════════════════════════════════════════════════
│   │                         PLANS SERVICE
│   │── ═══════════════════════════════════════════════════════════════════
│   │
│   ├── plans-service/
│   │   ├── pom.xml                          # Parent POM for plans-service
│   │   │
│   │   ├── plans-common/
│   │   │   ├── pom.xml                      # Aggregator for common modules
│   │   │   │
│   │   │   ├── plans-common-models/
│   │   │   │   ├── pom.xml
│   │   │   │   └── src/main/java/com/healthcare/plans/common/models/
│   │   │   │       ├── Plan.java
│   │   │   │       ├── PlanCategory.java
│   │   │   │       ├── PlanInclusion.java
│   │   │   │       ├── PlanExclusion.java
│   │   │   │       ├── HealthcareProvider.java
│   │   │   │       ├── HealthcareSpecialist.java
│   │   │   │       ├── Specialty.java
│   │   │   │       ├── State.java
│   │   │   │       └── AgeGroup.java
│   │   │   │
│   │   │   ├── plans-common-dto/
│   │   │   │   ├── pom.xml
│   │   │   │   └── src/main/java/com/healthcare/plans/common/dto/
│   │   │   │       ├── request/
│   │   │   │       │   ├── CreatePlanRequest.java
│   │   │   │       │   ├── UpdatePlanRequest.java
│   │   │   │       │   ├── PlanSearchRequest.java
│   │   │   │       │   └── PlanFilterRequest.java
│   │   │   │       └── response/
│   │   │   │           ├── PlanResponse.java
│   │   │   │           ├── PlanDetailResponse.java
│   │   │   │           ├── PlanSummaryResponse.java
│   │   │   │           ├── ProviderResponse.java
│   │   │   │           └── PagedResponse.java
│   │   │   │
│   │   │   ├── plans-common-utils/
│   │   │   │   ├── pom.xml
│   │   │   │   └── src/main/java/com/healthcare/plans/common/utils/
│   │   │   │       ├── PlanCodeGenerator.java
│   │   │   │       ├── ValidationUtils.java
│   │   │   │       └── DateUtils.java
│   │   │   │
│   │   │   └── plans-common-constants/
│   │   │       ├── pom.xml
│   │   │       └── src/main/java/com/healthcare/plans/common/constants/
│   │   │           ├── PlanStatus.java          # Enum
│   │   │           ├── PlanType.java            # Enum: HMO, PPO, EPO, POS
│   │   │           ├── MetalTier.java           # Enum: BRONZE, SILVER, GOLD, PLATINUM
│   │   │           ├── ProviderType.java        # Enum
│   │   │           ├── NetworkStatus.java       # Enum
│   │   │           └── ApiConstants.java
│   │   │
│   │   ├── plans-dao/
│   │   │   ├── pom.xml
│   │   │   └── src/main/java/com/healthcare/plans/dao/
│   │   │       ├── repository/
│   │   │       │   ├── PlanRepository.java
│   │   │       │   ├── PlanCategoryRepository.java
│   │   │       │   ├── ProviderRepository.java
│   │   │       │   ├── SpecialistRepository.java
│   │   │       │   ├── StateRepository.java
│   │   │       │   └── AgeGroupRepository.java
│   │   │       ├── specification/
│   │   │       │   └── PlanSpecification.java   # Dynamic queries
│   │   │       └── config/
│   │   │           └── JpaConfig.java
│   │   │
│   │   ├── plans-service/
│   │   │   ├── pom.xml
│   │   │   └── src/main/java/com/healthcare/plans/service/
│   │   │       ├── PlanService.java
│   │   │       ├── PlanServiceImpl.java
│   │   │       ├── ProviderService.java
│   │   │       ├── ProviderServiceImpl.java
│   │   │       ├── SpecialistService.java
│   │   │       ├── SpecialistServiceImpl.java
│   │   │       ├── ReferenceDataService.java
│   │   │       ├── ReferenceDataServiceImpl.java
│   │   │       └── mapper/
│   │   │           ├── PlanMapper.java
│   │   │           └── ProviderMapper.java
│   │   │
│   │   ├── plans-api-client/
│   │   │   ├── pom.xml
│   │   │   └── src/main/java/com/healthcare/plans/api/client/
│   │   │       ├── PlanApiClient.java           # Interface
│   │   │       ├── ProviderApiClient.java       # Interface
│   │   │       ├── SpecialistApiClient.java     # Interface
│   │   │       ├── ReferenceDataApiClient.java  # Interface
│   │   │       └── feign/
│   │   │           ├── PlanFeignClient.java     # Feign implementation
│   │   │           └── FeignConfig.java
│   │   │
│   │   ├── plans-api-stub/
│   │   │   ├── pom.xml
│   │   │   └── src/main/java/com/healthcare/plans/api/stub/
│   │   │       ├── PlanApiStub.java
│   │   │       ├── PlanApiStubImpl.java
│   │   │       ├── ProviderApiStub.java
│   │   │       ├── ProviderApiStubImpl.java
│   │   │       ├── SpecialistApiStub.java
│   │   │       ├── SpecialistApiStubImpl.java
│   │   │       └── ReferenceDataApiStubImpl.java
│   │   │
│   │   ├── plans-api/
│   │   │   ├── pom.xml
│   │   │   ├── Dockerfile
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       │   ├── java/com/healthcare/plans/api/
│   │   │       │   │   ├── PlansApiApplication.java
│   │   │       │   │   ├── controller/
│   │   │       │   │   │   ├── PlanController.java
│   │   │       │   │   │   ├── ProviderController.java
│   │   │       │   │   │   ├── SpecialistController.java
│   │   │       │   │   │   └── ReferenceDataController.java
│   │   │       │   │   ├── config/
│   │   │       │   │   │   ├── SecurityConfig.java
│   │   │       │   │   │   ├── OpenApiConfig.java
│   │   │       │   │   │   └── WebConfig.java
│   │   │       │   │   └── exception/
│   │   │       │   │       ├── GlobalExceptionHandler.java
│   │   │       │   │       └── PlanNotFoundException.java
│   │   │       │   └── resources/
│   │   │       │       ├── application.yml
│   │   │       │       ├── application-local.yml
│   │   │       │       ├── application-dev.yml
│   │   │       │       ├── application-prod.yml
│   │   │       │       └── db/migration/
│   │   │       │           ├── V1__create_reference_tables.sql
│   │   │       │           ├── V2__create_plans_tables.sql
│   │   │       │           ├── V3__create_providers_tables.sql
│   │   │       │           └── V4__create_specialists_tables.sql
│   │   │       └── test/
│   │   │
│   │   ├── devops/
│   │   │   ├── local/
│   │   │   ├── aws/
│   │   │   ├── azure/
│   │   │   └── gcp/
│   │   │
│   │   └── README.md
│   │
│   │── ═══════════════════════════════════════════════════════════════════
│   │                    CUSTOMER ONBOARDING SERVICE
│   │── ═══════════════════════════════════════════════════════════════════
│   │
│   ├── customer-onboarding-service/
│   │   ├── pom.xml
│   │   │
│   │   ├── customer-common/
│   │   │   ├── customer-common-models/
│   │   │   │   └── src/main/java/.../models/
│   │   │   │       ├── Customer.java
│   │   │   │       ├── HealthProfile.java
│   │   │   │       ├── HealthCondition.java
│   │   │   │       └── CustomerPreference.java
│   │   │   ├── customer-common-dto/
│   │   │   │   └── src/main/java/.../dto/
│   │   │   │       ├── request/
│   │   │   │       │   ├── SignupRequest.java
│   │   │   │       │   ├── LoginRequest.java
│   │   │   │       │   ├── UpdateProfileRequest.java
│   │   │   │       │   └── UpdatePreferencesRequest.java
│   │   │   │       └── response/
│   │   │   │           ├── CustomerResponse.java
│   │   │   │           ├── LoginResponse.java
│   │   │   │           └── ProfileResponse.java
│   │   │   ├── customer-common-utils/
│   │   │   └── customer-common-constants/
│   │   │       └── src/main/java/.../constants/
│   │   │           ├── CustomerStatus.java
│   │   │           ├── Priority.java
│   │   │           └── Severity.java
│   │   │
│   │   ├── customer-dao/
│   │   ├── customer-service/
│   │   ├── customer-api-client/
│   │   ├── customer-api-stub/
│   │   ├── customer-api/
│   │   ├── devops/
│   │   └── README.md
│   │
│   │── ═══════════════════════════════════════════════════════════════════
│   │                         ORDER SERVICE
│   │── ═══════════════════════════════════════════════════════════════════
│   │
│   ├── order-service/
│   │   ├── pom.xml
│   │   │
│   │   ├── order-common/
│   │   │   ├── order-common-models/
│   │   │   │   └── src/main/java/.../models/
│   │   │   │       ├── Cart.java
│   │   │   │       ├── CartItem.java
│   │   │   │       ├── Order.java
│   │   │   │       └── OrderItem.java
│   │   │   ├── order-common-dto/
│   │   │   │   └── src/main/java/.../dto/
│   │   │   │       ├── request/
│   │   │   │       │   ├── AddToCartRequest.java
│   │   │   │       │   ├── CheckoutRequest.java
│   │   │   │       │   └── CreateOrderRequest.java
│   │   │   │       └── response/
│   │   │   │           ├── CartResponse.java
│   │   │   │           ├── OrderResponse.java
│   │   │   │           └── OrderSummaryResponse.java
│   │   │   ├── order-common-utils/
│   │   │   └── order-common-constants/
│   │   │       └── src/main/java/.../constants/
│   │   │           ├── CartStatus.java
│   │   │           └── OrderStatus.java
│   │   │
│   │   ├── order-dao/
│   │   ├── order-service/
│   │   │   └── src/main/java/.../service/
│   │   │       ├── CartService.java
│   │   │       ├── CartServiceImpl.java      # Uses plans-api-client
│   │   │       ├── OrderService.java
│   │   │       └── OrderServiceImpl.java     # Uses plans-api-client, customer-api-client
│   │   ├── order-api-client/
│   │   ├── order-api-stub/
│   │   ├── order-api/
│   │   │   └── pom.xml                       # Includes plans-api-client dependency
│   │   ├── devops/
│   │   └── README.md
│   │
│   │── ═══════════════════════════════════════════════════════════════════
│   │                       AI GATEWAY SERVICE
│   │── ═══════════════════════════════════════════════════════════════════
│   │
│   └── ai-gateway-service/
│       ├── pom.xml
│       │
│       ├── ai-gateway-common/
│       │   ├── ai-gateway-common-models/
│       │   ├── ai-gateway-common-dto/
│       │   │   └── src/main/java/.../dto/
│       │   │       ├── request/
│       │   │       │   ├── SemanticSearchRequest.java
│       │   │       │   ├── RecommendationRequest.java
│       │   │       │   └── ChatRequest.java
│       │   │       └── response/
│       │   │           ├── SearchResultResponse.java
│       │   │           ├── RecommendationResponse.java
│       │   │           ├── ChatResponse.java
│       │   │           └── CitationResponse.java
│       │   ├── ai-gateway-common-utils/
│       │   └── ai-gateway-common-constants/
│       │       └── src/main/java/.../constants/
│       │           ├── Verdict.java           # RECOMMENDED, UNDECIDABLE
│       │           └── RAGConstants.java
│       │
│       ├── ai-gateway-dao/                    # Minimal - mainly for chat history
│       ├── ai-gateway-service/
│       │   └── src/main/java/.../service/
│       │       ├── QueryProcessorService.java
│       │       ├── RetrievalService.java
│       │       ├── RerankingService.java
│       │       ├── AbstentionService.java
│       │       ├── LLMReasoningService.java
│       │       └── ChatSessionService.java
│       ├── ai-gateway-rag/                    # ReGAIN implementation module
│       │   └── src/main/java/.../rag/
│       │       ├── HierarchicalRetrievalPipeline.java
│       │       ├── MetadataFilterBuilder.java
│       │       ├── MMRDiversitySampler.java
│       │       └── CitationExtractor.java
│       ├── ai-gateway-api-client/
│       ├── ai-gateway-api-stub/
│       │   └── src/main/java/.../stub/
│       │       └── ...Impl.java              # Uses plans-api-client, customer-api-client
│       ├── ai-gateway-api/
│       ├── devops/
│       └── README.md
```

---

## Parent POM Structure

### Root Parent POM (microservices/pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.healthcare</groupId>
    <artifactId>healthcare-platform-parent</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>Healthcare Plans AI Platform</name>
    <description>Parent POM for Healthcare Plans AI Platform Microservices</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.5.6</version>
        <relativePath/>
    </parent>

    <modules>
        <module>plans-service</module>
        <module>customer-onboarding-service</module>
        <module>order-service</module>
        <module>ai-gateway-service</module>
    </modules>

    <properties>
        <java.version>21</java.version>
        <maven.compiler.source>21</maven.compiler.source>
        <maven.compiler.target>21</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        
        <!-- Dependency versions -->
        <springdoc.version>2.3.0</springdoc.version>
        <mapstruct.version>1.5.5.Final</mapstruct.version>
        <lombok.version>1.18.30</lombok.version>
        <feign.version>13.1</feign.version>
        <testcontainers.version>1.19.3</testcontainers.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <!-- OpenAPI / Swagger -->
            <dependency>
                <groupId>org.springdoc</groupId>
                <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
                <version>${springdoc.version}</version>
            </dependency>

            <!-- MapStruct -->
            <dependency>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct</artifactId>
                <version>${mapstruct.version}</version>
            </dependency>

            <!-- Feign Client -->
            <dependency>
                <groupId>io.github.openfeign</groupId>
                <artifactId>feign-core</artifactId>
                <version>${feign.version}</version>
            </dependency>

            <!-- Testcontainers -->
            <dependency>
                <groupId>org.testcontainers</groupId>
                <artifactId>testcontainers-bom</artifactId>
                <version>${testcontainers.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <dependencies>
        <!-- Common dependencies for all modules -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
    </dependencies>

</project>
```

### Service Parent POM Example (plans-service/pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.healthcare</groupId>
        <artifactId>healthcare-platform-parent</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <artifactId>plans-service-parent</artifactId>
    <packaging>pom</packaging>
    <name>Plans Service Parent</name>

    <modules>
        <module>plans-common</module>
        <module>plans-dao</module>
        <module>plans-service</module>
        <module>plans-api-client</module>
        <module>plans-api-stub</module>
        <module>plans-api</module>
    </modules>

    <properties>
        <plans.service.version>${project.version}</plans.service.version>
    </properties>

</project>
```

---

## API Client Interface Example

### plans-api-client: PlanApiClient.java

```java
package com.healthcare.plans.api.client;

import com.healthcare.plans.common.dto.request.PlanSearchRequest;
import com.healthcare.plans.common.dto.response.PlanResponse;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import com.healthcare.plans.common.dto.response.PagedResponse;

import java.util.UUID;

/**
 * API Client interface for Plans Service.
 * This interface is implemented by:
 * 1. PlanApiStubImpl (for local calls within plans-service)
 * 2. PlanFeignClient (for remote calls from other services)
 */
public interface PlanApiClient {

    /**
     * Get plan by ID
     */
    PlanDetailResponse getPlanById(UUID planId);

    /**
     * Get plan by plan code
     */
    PlanDetailResponse getPlanByCode(String planCode);

    /**
     * Search plans with filters
     */
    PagedResponse<PlanResponse> searchPlans(PlanSearchRequest request);

    /**
     * Get plans by IDs (bulk)
     */
    List<PlanResponse> getPlansByIds(List<UUID> planIds);

    /**
     * Check if plan exists and is active
     */
    boolean isPlanActive(UUID planId);
}
```

### plans-api-client: PlanFeignClient.java

```java
package com.healthcare.plans.api.client.feign;

import com.healthcare.plans.api.client.PlanApiClient;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(
    name = "plans-service",
    url = "${services.plans.url}",
    configuration = FeignConfig.class
)
public interface PlanFeignClient extends PlanApiClient {

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
    @PostMapping("/api/v1/plans/bulk")
    List<PlanResponse> getPlansByIds(@RequestBody List<UUID> planIds);

    @Override
    @GetMapping("/api/v1/plans/{planId}/active")
    boolean isPlanActive(@PathVariable("planId") UUID planId);
}
```

### plans-api-stub: PlanApiStubImpl.java

```java
package com.healthcare.plans.api.stub;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.service.PlanService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PlanApiStubImpl implements PlanApiClient {

    private final PlanService planService;

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
    public List<PlanResponse> getPlansByIds(List<UUID> planIds) {
        return planService.getPlansByIds(planIds);
    }

    @Override
    public boolean isPlanActive(UUID planId) {
        return planService.isPlanActive(planId);
    }
}
```

---

## Inter-Service Communication Example

### order-service using plans-api-client

```java
// order-service/pom.xml dependency
<dependency>
    <groupId>com.healthcare</groupId>
    <artifactId>plans-api-client</artifactId>
    <version>${plans.service.version}</version>
</dependency>

// OrderServiceImpl.java
package com.healthcare.order.service;

import com.healthcare.plans.api.client.PlanApiClient;
import com.healthcare.plans.common.dto.response.PlanDetailResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final PlanApiClient planApiClient;  // Injected Feign client
    private final OrderRepository orderRepository;

    @Override
    public OrderResponse createOrder(CreateOrderRequest request) {
        // Validate plan exists and get details
        PlanDetailResponse plan = planApiClient.getPlanById(request.getPlanId());
        
        if (!planApiClient.isPlanActive(request.getPlanId())) {
            throw new InvalidPlanException("Plan is not active");
        }

        // Create order with plan snapshot
        Order order = Order.builder()
            .customerId(request.getCustomerId())
            .planId(plan.getId())
            .planCode(plan.getPlanCode())
            .planName(plan.getPlanName())
            .monthlyPremium(plan.getMonthlyPremium())
            .planSnapshot(objectMapper.writeValueAsString(plan))
            .status(OrderStatus.PENDING)
            .build();

        return orderRepository.save(order);
    }
}
```

---

## Build Order

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        BUILD SEQUENCE                                       │
└─────────────────────────────────────────────────────────────────────────────┘

Step 1: plans-service (Foundation - no dependencies on other services)
        │
        │ Build order within plans-service:
        │ 1. plans-common-constants
        │ 2. plans-common-models (depends on constants)
        │ 3. plans-common-dto (depends on constants)
        │ 4. plans-common-utils
        │ 5. plans-dao (depends on models)
        │ 6. plans-service (depends on dao)
        │ 7. plans-api-client (depends on dto)
        │ 8. plans-api-stub (depends on api-client, service)
        │ 9. plans-api (depends on api-stub)
        ▼
Step 2: customer-onboarding-service (No service dependencies)
        │
        ▼
Step 3: order-service (Depends on plans-api-client, customer-api-client)
        │
        ▼
Step 4: ai-gateway-service (Depends on plans-api-client, customer-api-client)
        │
        ▼
Step 5: Synthetic Data Generator (Uses all api-clients)
        │
        ▼
Step 6: data-engineering (Connects to DBs for vector indexing)
```

---

## Synthetic Data Volume

| Entity | Count | Description |
|--------|-------|-------------|
| States | 51 | 50 US states + DC |
| Plan Categories | ~50 | diabetes, maternity, preventive, dental, vision, etc. |
| Age Groups | ~6 | 0-17, 18-25, 26-45, 46-65, 65+ |
| Specialties | ~50 | cardiology, endocrinology, pediatrics, etc. |
| Plans | 10,000 | Across years, states, age groups, categories |
| Healthcare Specialists | 10,000 | Doctors, specialists by type |
| Healthcare Providers | 10,000 | Hospitals, clinics, pharmacies, labs |
| Customers | 100,000 | Various demographics, health profiles |
| Orders | ~50,000 | Generated after customer flows |

---

## Database Schema

(See original schema documentation - unchanged)

---

## Next Steps

1. ✅ Confirm technology stack (JDK 21, Spring Boot 3.5.6, Maven multi-module)
2. ✅ Confirm module structure (common/dao/service/api-client/api-stub/api)
3. **Create plans-service** - Start with Maven POMs and project structure
4. **Implement entities and DTOs** - JPA models, request/response classes
5. **Build DAOs and Services** - Repositories, business logic
6. **Create API layer** - Controllers, OpenAPI docs
7. **Build synthetic data generator** - Python scripts
8. **Create GitHub workflow** - Manual trigger for data generation