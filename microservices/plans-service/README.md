# Plans Service

Spring Boot microservice managing healthcare plans catalog, search, and plan details.

## Features

- Plan CRUD operations
- Plan filtering (year, state, age group, cost)
- Plan details with coverage information
- Plan comparison
- In-network hospitals lookup
- Event publishing (PlanCreated, PlanUpdated)

## Tech Stack

- Java 17
- Spring Boot 3
- Spring Data JPA
- PostgreSQL
- Flyway (migrations)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/plans` | List plans (with filters) |
| GET | `/api/v1/plans/{id}` | Get plan by ID |
| GET | `/api/v1/plans/{id}/coverage` | Get plan coverage details |
| GET | `/api/v1/plans/{id}/hospitals` | Get in-network hospitals |
| POST | `/api/v1/plans/compare` | Compare multiple plans |
| POST | `/api/v1/plans` | Create plan (admin) |
| PUT | `/api/v1/plans/{id}` | Update plan (admin) |
| DELETE | `/api/v1/plans/{id}` | Delete plan (admin) |

## Query Parameters (GET /plans)

| Parameter | Type | Example |
|-----------|------|---------|
| `year` | Integer | `2025` |
| `state` | String | `TX` |
| `ageGroup` | String | `26-45` |
| `focusAreas` | List | `diabetes,preventive` |
| `maxCost` | Decimal | `500.00` |
| `page` | Integer | `0` |
| `size` | Integer | `20` |

## Getting Started
```bash
# Build
./mvnw clean package

# Run locally
./mvnw spring-boot:run -Dspring.profiles.active=local

# Run tests
./mvnw test
```

## Environment Variables

See `.env.example` for required variables.

## Project Structure
```
src/main/java/com/healthcare/plans/
├── config/           # App configurations
├── controller/       # REST controllers
├── service/          # Business logic
├── repository/       # Data access
├── entity/           # JPA entities
│   ├── Plan.java
│   ├── CostStructure.java
│   ├── Coverage.java
│   └── NetworkHospital.java
├── dto/              # Request/Response DTOs
└── mapper/           # Entity-DTO mappers
```

## Data Model
```
Plan
├── planId (UUID)
├── planCode (e.g., "GOLD-2025-TX-001")
├── year
├── state (nullable if national)
├── isNational
├── ageGroups[]
├── focusAreas[]
├── costStructure
│   ├── monthlyPremium
│   ├── annualDeductible
│   ├── outOfPocketMax
│   └── copays
├── coverage
│   ├── inclusions[]
│   └── exclusions[]
├── networkHospitals[]
└── status (active/deprecated)
```

## Events Published

| Event | Trigger | Consumed By |
|-------|---------|-------------|
| `PlanCreated` | New plan added | data-engineering (vector indexing) |
| `PlanUpdated` | Plan modified | data-engineering (re-index) |
| `PlanDeprecated` | Plan deactivated | data-engineering (remove from index) |

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Docker Compose, local DB setup |
| `devops/aws/` | ECS task definition, Terraform |
| `devops/azure/` | Container Apps config |
| `devops/gcp/` | Cloud Run config |