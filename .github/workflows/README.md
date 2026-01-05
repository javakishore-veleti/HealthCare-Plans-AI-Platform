# GitHub Workflows

All workflows in this project are **manually triggered** (`workflow_dispatch`) - no automatic triggers on push or pull request.

## Workflow Overview

### Infrastructure Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Terraform Plan | `infra-terraform-plan.yml` | Preview infrastructure changes |
| Terraform Apply | `infra-terraform-apply.yml` | Apply infrastructure changes |
| Terraform Destroy | `infra-terraform-destroy.yml` | Destroy infrastructure (with safeguards) |

### Build Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Build Microservice | `build-microservice.yml` | Build & push Docker image to ECR |
| Build UI | `build-ui.yml` | Build React app for deployment |
| Build Data Engineering | `build-data-engineering.yml` | Package Python Lambda/containers |

### Deploy Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Deploy Microservice | `deploy-microservice.yml` | Deploy to ECS/Container service |
| Deploy UI | `deploy-ui.yml` | Deploy to S3/CloudFront |
| Deploy Lambda | `deploy-lambda.yml` | Deploy Python Lambda functions |

### Data & AI Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| Full Reindex | `data-full-reindex.yml` | Reindex vector database collections |
| Seed Sample Data | `data-seed-sample.yml` | Populate sample data |
| Run AI Evaluation | `ai-run-evaluation.yml` | Run RAG evaluation metrics |

### Utility Workflows

| Workflow | File | Purpose |
|----------|------|---------|
| DB Migration | `db-migration.yml` | Run Flyway migrations |
| Rotate Secrets | `secrets-rotate.yml` | Rotate credentials |

## How to Run Workflows

1. Go to **Actions** tab in GitHub
2. Select the workflow from left sidebar
3. Click **Run workflow**
4. Fill in required inputs
5. Click **Run workflow** button

## Workflow Inputs

Most workflows accept these common inputs:

| Input | Description | Example |
|-------|-------------|---------|
| `environment` | Target environment | `dev`, `staging`, `prod` |
| `service_name` | Service to build/deploy | `customer-onboarding-service` |
| `image_tag` | Docker image tag | `latest`, `v1.0.0` |

## Required Secrets

Configure these in **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `ECR_REGISTRY` | ECR registry URL |

## Environment Protection

Production deployments require approval. Configure in **Settings → Environments → prod → Required reviewers**.