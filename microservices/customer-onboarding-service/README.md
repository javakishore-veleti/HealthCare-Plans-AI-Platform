# Customer Onboarding Service

Spring Boot microservice handling customer registration, authentication, and profile management.

## Features

- Customer signup (registration)
- Login (JWT authentication)
- Profile management
- Health profile (conditions, medications)
- Preferences (budget, priorities)
- Event publishing (CustomerCreated, CustomerUpdated)

## Tech Stack

- Java 17
- Spring Boot 3
- Spring Security (JWT)
- Spring Data JPA
- PostgreSQL
- Flyway (migrations)

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/signup` | Register new customer |
| POST | `/api/v1/auth/login` | Authenticate customer |
| GET | `/api/v1/customers/me` | Get current customer profile |
| PUT | `/api/v1/customers/me` | Update profile |
| PUT | `/api/v1/customers/me/health-profile` | Update health profile |
| PUT | `/api/v1/customers/me/preferences` | Update preferences |

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
src/main/java/com/healthcare/customer/
├── config/           # Security, EventBridge configs
├── controller/       # REST controllers
├── service/          # Business logic
├── repository/       # Data access
├── entity/           # JPA entities
├── dto/              # Request/Response DTOs
└── mapper/           # Entity-DTO mappers
```

## Database Migrations

Located in `src/main/resources/db/migration/`

## Events Published

| Event | Trigger | Consumed By |
|-------|---------|-------------|
| `CustomerCreated` | New signup | data-engineering (vector indexing) |
| `CustomerUpdated` | Profile update | data-engineering (re-index) |
| `PreferencesUpdated` | Preferences change | ai-gateway-service |

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Docker Compose, local DB setup |
| `devops/aws/` | ECS task definition, Terraform |
| `devops/azure/` | Container Apps config |
| `devops/gcp/` | Cloud Run config |