# Healthcare Plans AI Platform

An AI-powered healthcare plans platform featuring intelligent plan recommendations, semantic search, and conversational assistance. Built using **Retrieval-Augmented Generation (RAG)** principles inspired by the [ReGAIN research framework](https://arxiv.org/abs/2512.22223), deployed on AWS with Spring Boot microservices, PySpark for Vector Databases indexing and integrationg with AWS native vector databases for customer and advisor/admin support features especially searcihing.

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

### ReGAIN-Inspired AI Pipeline
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
│   │   ├── summarization/       # ReGAIN fsum implementation
│   │   ├── embeddings/          # ReGAIN fembed implementation
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

## 🤖 AI Features (ReGAIN-Based)

| Feature | Description | ReGAIN Mapping |
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
- [ReGAIN Mapping](docs/ai/regain-mapping.md)

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
- [ ] RAG implementation (ReGAIN-based)
- [ ] AWS infrastructure (Terraform)
- [ ] UI development
- [ ] CI/CD workflows
- [ ] Production deployment

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

---

## 🙏 Acknowledgments

- [ReGAIN: Retrieval-Grounded AI Framework for Network Traffic Analysis](https://arxiv.org/abs/2512.22223) - Research paper inspiring the RAG architecture
- AWS Bedrock team for LLM capabilities
- Spring Boot and React communities
