# Healthcare Plans AI Platform

An AI-powered healthcare plans platform featuring intelligent plan recommendations, semantic search, and conversational assistance. Built using **Retrieval-Augmented Generation (RAG)** principles inspired by a research framework, deployed on AWS with Spring Boot microservices, PySpark for Vector Databases indexing and integrationg with AWS native vector databases for customer and advisor/admin support features especially searcihing.

![Architecture](docs/diagrams/architecture-overview.png)

---

## 🎯 Project Overview

This platform enables customers to discover, compare, and enroll in healthcare plans through AI-driven recommendations grounded in verifiable evidence. The system combines:

- **Microservices Architecture**: Spring Boot services for customer onboarding, plan management, and order processing
- **RAG-Based AI**: Retrieval-augmented generation for transparent, citation-backed recommendations
- **Vector Search**: Semantic search across plans using embeddings stored in OpenSearch
- **AWS Native**: Fully deployed on AWS using ECS, Bedrock, OpenSearch Serverless, and more

---

## 🏗️ Architecture

### High-Level Components
```
┌─────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION                              │
│              Customer Portal  │  Admin Portal                       │
└─────────────────────────────────────────────────────────────────────┘
                                    │
┌─────────────────────────────────────────────────────────────────────┐
│                          API GATEWAY                                │
└─────────────────────────────────────────────────────────────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        ▼                           ▼                           ▼
┌───────────────┐         ┌─────────────────┐         ┌───────────────┐
│   Customer    │         │     Plans       │         │    Order      │
│  Onboarding   │         │    Service      │         │   Service     │
│   Service     │         │                 │         │               │
└───────────────┘         └─────────────────┘         └───────────────┘
                                    │
                          ┌─────────┴─────────┐
                          ▼                   ▼
                 ┌─────────────────┐  ┌──────────────────┐
                 │   AI Gateway    │  │  Data Engineering │
                 │    Service      │  │     Pipeline      │
                 │  (RAG Engine)   │  │  (Vector Indexing)│
                 └─────────────────┘  └──────────────────┘
                          │                   │
                          ▼                   ▼
                 ┌─────────────────────────────────────────┐
                 │           AWS BEDROCK & OPENSEARCH      │
                 │    (LLM Reasoning)   (Vector Database)  │
                 └─────────────────────────────────────────┘
```

### Research Work Inspired AI Pipeline
```
User Query → Entity Extraction → Metadata Filtering → Semantic Search
    → MMR Diversity Sampling → Cross-Encoder Reranking → Abstention Check
    → LLM Reasoning (Bedrock Claude) → Citation-Backed Response
```

---

## 📁 Repository Structure
```
healthcare-plans-ai-platform/
│
├── ui/                          # Frontend applications
│   ├── customer-portal/         # React app for customers
│   └── admin-portal/            # React app for administrators
│
├── microservices/               # Spring Boot backend services
│   ├── common/                  # Shared libraries (DTOs, security)
│   ├── customer-onboarding-service/
│   ├── plans-service/
│   ├── order-service/
│   └── ai-gateway-service/      # RAG orchestration
│
├── data-engineering/            # Python ETL & vector indexing
│   ├── src/
│   │   ├── extractors/          # Data extraction from sources
│   │   ├── transformers/        # Data transformation
│   │   ├── summarization/       # Research work fsum implementation
│   │   ├── embeddings/          # Research work fembed implementation
│   │   └── loaders/             # Vector DB loading
│   ├── jobs/                    # Batch & Lambda handlers
│   └── notebooks/               # Jupyter notebooks for analysis
│
├── devops/
│   ├── local/                   # Local development (Docker Compose)
│   └── aws/                     # AWS infrastructure (Terraform)
│
├── .github/workflows/           # Manual CI/CD workflows
│
└── docs/                        # Documentation
```

---

## 🚀 Getting Started

### Prerequisites

- Java 17+
- Node.js 18+
- Python 3.11+
- Docker & Docker Compose
- AWS CLI (configured)

### Local Development Setup
```bash
# Clone the repository
git clone https://github.com/<your-org>/healthcare-plans-ai-platform.git
cd healthcare-plans-ai-platform

# Start infrastructure (PostgreSQL, OpenSearch, LocalStack)
cd devops/local
docker-compose -f docker-compose.infra.yml up -d

# Start microservices
cd ../../microservices
./mvnw spring-boot:run -pl customer-onboarding-service

# Start UI
cd ../ui/customer-portal
npm install && npm run dev
```

See [Local Setup Guide](docs/development/local-setup.md) for detailed instructions.

---

## 🤖 AI Features (Research work-Based)

| Feature | Description | Research work Mapping |
|---------|-------------|----------------|
| **Semantic Plan Search** | Natural language search across plans | Hierarchical Retrieval (§III-C) |
| **Intelligent Recommendations** | Personalized plan suggestions with citations | LLM Reasoning with Evidence (§III-C) |
| **AI Chat Assistant** | Conversational Q&A about plans | Human-in-the-Loop (§III-D) |
| **Abstention Mechanism** | Graceful handling of uncertain queries | Quality Gate (§III-C) |

### Example AI Interaction
```
User: "I need affordable coverage for my diabetic mother in Texas, she's 62"

AI Response:
{
  "verdict": "RECOMMENDED",
  "recommendation": "Texas Diabetes Care Gold (GOLD-2025-TX-042)",
  "reasoning": "This plan specifically covers diabetes management [Citation: focus_areas] 
                including insulin pumps and CGMs [Citation: inclusions.medical_devices]. 
                The $380/month premium fits typical budgets for this age group.",
  "citations": [
    {"ref": "GOLD-2025-TX-042.focus_areas", "value": "diabetes_management"},
    {"ref": "GOLD-2025-TX-042.inclusions", "value": "insulin pumps, CGM devices"}
  ],
  "alternatives": ["SILVER-2025-TX-018", "BRONZE-2025-NAT-003"]
}
```

---

## 🛠️ Technology Stack

| Layer | Technologies |
|-------|--------------|
| **Frontend** | React, TypeScript, Tailwind CSS, Vite |
| **Backend** | Spring Boot 3, Java 17, Spring Security, Spring Data JPA |
| **AI/ML** | AWS Bedrock (Claude, Titan Embeddings), LangChain |
| **Data Engineering** | Python, PySpark, Pandas |
| **Vector Database** | Amazon OpenSearch Serverless |
| **Databases** | PostgreSQL (RDS), ElastiCache (Redis) |
| **Infrastructure** | AWS (ECS, API Gateway, EventBridge, S3), Terraform |
| **CI/CD** | GitHub Actions (manual workflows) |

---

## 📊 AWS Architecture
```
┌─────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                              │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  VPC                                                           │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │ │
│  │  │ ECS Fargate │  │ ECS Fargate │  │ ECS Fargate │            │ │
│  │  │ (Customer)  │  │  (Plans)    │  │  (Orders)   │            │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │ │
│  │         │                │                │                    │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │ │
│  │  │     RDS     │  │ OpenSearch  │  │   Bedrock   │            │ │
│  │  │ (PostgreSQL)│  │ (Vectors)   │  │  (Claude)   │            │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘            │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Documentation

- [Architecture Overview](docs/architecture/overview.md)
- [AI/RAG Architecture](docs/architecture/ai-rag-architecture.md)
- [API Documentation](docs/api/)
- [Local Development Setup](docs/development/local-setup.md)
- [Deployment Guide](docs/operations/deployment-guide.md)
- [Research work Mapping](docs/ai/regain-mapping.md)

---

## 🔄 GitHub Workflows

All workflows are **manually triggered** (`workflow_dispatch`):

| Workflow | Purpose |
|----------|---------|
| `infra-terraform-plan.yml` | Plan infrastructure changes |
| `infra-terraform-apply.yml` | Apply infrastructure changes |
| `build-microservice.yml` | Build & push Docker images |
| `deploy-microservice.yml` | Deploy to ECS |
| `data-full-reindex.yml` | Reindex vector database |
| `ai-run-evaluation.yml` | Run RAG evaluation metrics |

---

## 🧪 Testing
```bash
# Microservices unit tests
cd microservices
./mvnw test

# Data engineering tests
cd data-engineering
pytest tests/

# UI tests
cd ui/customer-portal
npm run test
```

---

## 📈 Roadmap

- [x] Architecture design
- [ ] Microservices implementation
- [ ] Data engineering pipelines
- [ ] RAG implementation (Research work-based)
- [ ] AWS infrastructure (Terraform)
- [ ] UI development
- [ ] CI/CD workflows
- [ ] Production deployment

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---


---

## 🙏 Acknowledgments

- AWS Bedrock team for LLM capabilities
- Spring Boot and React communities


## 📋 NPM Commands Reference

### Infrastructure

| Command | Description |
|---------|-------------|
| `npm run infra:up` | Start core infrastructure (Postgres, Redis, Kafka) |
| `npm run infra:up:all` | Start all infrastructure including UIs |
| `npm run infra:down` | Stop all infrastructure |
| `npm run infra:status` | Check infrastructure status |
| `npm run infra:clean` | Remove all containers and volumes |

### Build

| Command | Description |
|---------|-------------|
| `npm run build` | Build all backend services |
| `npm run build:services` | Build all backend services |
| `npm run build:plans` | Build Plans Service |
| `npm run build:customer` | Build Customer Service |
| `npm run build:order` | Build Order Service |
| `npm run build:admin` | Build Admin Portal |
| `npm run build:portal` | Build Customer Portal |
| `npm run build:frontends` | Build both frontend apps |

### Backend Services

| Command | Description | Port |
|---------|-------------|------|
| `npm run start:plans` | Start Plans Service | 8081 |
| `npm run start:customer` | Start Customer Service (Auth + Profiles) | 8083 |
| `npm run start:order` | Start Order Service | 8084 |
| `npm run start:all:bg` | Start all services in background | — |

### Frontend Apps

| Command | Description | Port |
|---------|-------------|------|
| `npm run start:admin` | Start Admin Portal (Your Care Plans) | 3000 |
| `npm run start:portal` | Start Customer Portal (Your Care) | 3001 |

### WireMock (Mock Payment Service)

| Command | Description | Port |
|---------|-------------|------|
| `npm run start:wiremock` | Start WireMock payment mock | 8090 |
| `npm run stop:wiremock` | Stop WireMock | — |
| `npm run health:wiremock` | Check WireMock health | — |

### Stop Services

| Command | Description |
|---------|-------------|
| `npm run stop:all` | Stop all services (backend, frontend, WireMock) |
| `npm run stop:backend` | Stop all backend services |
| `npm run stop:frontend` | Stop all frontend apps |

### Health Checks

| Command | Description |
|---------|-------------|
| `npm run health` | Check all services health |
| `npm run health:backend` | Check all backend services |
| `npm run health:frontend` | Check all frontend apps |
| `npm run health:plans` | Check Plans Service |
| `npm run health:customer` | Check Customer Service |
| `npm run health:order` | Check Order Service |
| `npm run health:admin` | Check Admin Portal |
| `npm run health:portal` | Check Customer Portal |
| `npm run health:wiremock` | Check WireMock |

### Data Generation

| Command | Description |
|---------|-------------|
| `npm run datagen:plans` | Generate synthetic plans data |
| `npm run datagen:customer` | Generate synthetic customer data |
| `npm run datagen:order` | Generate synthetic order data |

### Swagger / API Docs

| Command | Description |
|---------|-------------|
| `npm run swagger:plans` | Open Plans API docs |
| `npm run swagger:customer` | Open Customer API docs |
| `npm run swagger:order` | Open Order API docs |
| `npm run swagger:all` | Open all API docs |

### Open Apps

| Command | Description |
|---------|-------------|
| `npm run open:admin` | Open Admin Portal in browser |
| `npm run open:portal` | Open Customer Portal in browser |
| `npm run open:all` | Open both portals |

### Logs

| Command | Description |
|---------|-------------|
| `npm run logs:plans` | Tail Plans Service logs |
| `npm run logs:customer` | Tail Customer Service logs |
| `npm run logs:order` | Tail Order Service logs |
| `npm run logs:all` | Tail all service logs |

### Database

| Command | Description |
|---------|-------------|
| `npm run db:plans` | Connect to Plans DB (psql) |
| `npm run db:customer` | Connect to Customer DB (psql) |
| `npm run db:order` | Connect to Order DB (psql) |
| `npm run db:truncate:plans` | Truncate Plans DB tables |
| `npm run db:truncate:customer` | Truncate Customer DB tables |
| `npm run db:truncate:order` | Truncate Order DB tables |

### Docker Logs

| Command | Description |
|---------|-------------|
| `npm run docker:logs:postgres` | View PostgreSQL logs |
| `npm run docker:logs:redis` | View Redis logs |
| `npm run docker:logs:kafka` | View Kafka logs |

## 🌐 Service URLs

| Service | URL |
|---------|-----|
| Admin Portal (Your Care Plans) | http://localhost:3000 |
| Customer Portal (Your Care) | http://localhost:3001 |
| Plans Service API | http://localhost:8081 |
| Customer Service API | http://localhost:8083 |
| Order Service API | http://localhost:8084 |
| WireMock Payments | http://localhost:8090 |
| Kafka UI | http://localhost:8086 |
| pgAdmin | http://localhost:5050 |

## 🧪 Test Card Numbers (WireMock)

| Card Number | Result |
|-------------|--------|
| `4242424242424242` | ✅ Success |
| `4000000000000002` | ❌ Declined |
| `4000000000009995` | ❌ Insufficient Funds |

## 👨‍💻 Daily Developer Workflow

### 1. Start Infrastructure
```bash
npm run infra:down
npm run infra:up
npm run infra:status
```

### 2. Generate Test Data (first time or after DB reset)
```bash
npm run datagen:all
```

### 3. Start All Services
```bash
npm run start:all
```

### 4. Verify All Services
```bash
npm run health
```

### 5. Open Apps
```bash
npm run open:all
```

### 6. View Logs (optional)
```bash
npm run logs:all
```

### 7. End of Day Shutdown
```bash
npm run stop:all
npm run infra:down
```