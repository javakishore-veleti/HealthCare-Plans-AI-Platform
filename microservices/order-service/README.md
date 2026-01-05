# Order Service

Spring Boot microservice handling shopping cart, checkout, and order management for healthcare plans.

## Features

- Cart management (add, update, remove items)
- Cart checkout
- Order creation
- Order history
- Order status tracking
- Event publishing (OrderCreated, OrderCompleted)

## Tech Stack

- Java 17
- Spring Boot 3
- Spring Data JPA
- PostgreSQL
- Flyway (migrations)

## API Endpoints

### Cart APIs

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/cart` | Get current cart |
| POST | `/api/v1/cart/items` | Add plan to cart |
| PUT | `/api/v1/cart/items/{itemId}` | Update cart item |
| DELETE | `/api/v1/cart/items/{itemId}` | Remove from cart |
| DELETE | `/api/v1/cart` | Clear cart |
| POST | `/api/v1/cart/checkout` | Checkout cart |

### Order APIs

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/orders` | List customer orders |
| GET | `/api/v1/orders/{id}` | Get order details |
| POST | `/api/v1/orders` | Create order directly |
| PUT | `/api/v1/orders/{id}/cancel` | Cancel order |

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
src/main/java/com/healthcare/order/
├── config/           # App configurations
├── controller/
│   ├── CartController.java
│   └── OrderController.java
├── service/
│   ├── CartService.java
│   ├── CheckoutService.java
│   └── OrderService.java
├── repository/
│   ├── CartRepository.java
│   └── OrderRepository.java
├── entity/
│   ├── Cart.java
│   ├── CartItem.java
│   ├── Order.java
│   └── OrderItem.java
├── dto/
└── mapper/
```

## Data Model
```
Cart
├── cartId (UUID)
├── customerId (UUID)
├── items[]
│   ├── cartItemId
│   ├── planId
│   ├── beneficiaries[]
│   └── addedAt
└── status (active/checked_out/abandoned)

Order
├── orderId (UUID)
├── customerId (UUID)
├── items[]
│   ├── orderItemId
│   ├── planId
│   ├── planSnapshot (frozen plan details)
│   └── beneficiaries[]
├── totalMonthlyCost
├── status (pending/confirmed/active/cancelled)
├── effectiveDate
└── createdAt
```

## Events Published

| Event | Trigger | Consumed By |
|-------|---------|-------------|
| `CartUpdated` | Cart modified | analytics |
| `OrderCreated` | New order placed | data-engineering, notifications |
| `OrderCompleted` | Order confirmed | data-engineering (interaction history) |
| `OrderCancelled` | Order cancelled | notifications |

## DevOps

| Folder | Purpose |
|--------|---------|
| `devops/local/` | Docker Compose, local DB setup |
| `devops/aws/` | ECS task definition, Terraform |
| `devops/azure/` | Container Apps config |
| `devops/gcp/` | Cloud Run config |