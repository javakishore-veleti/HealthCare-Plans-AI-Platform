# UI
mkdir -p ui/customer-portal/{src,devops/local,devops/aws,devops/azure,devops/gcp}
mkdir -p ui/admin-portal/{src,devops/local,devops/aws,devops/azure,devops/gcp}

# Microservices
mkdir -p microservices/customer-onboarding-service/{src,devops/local,devops/aws,devops/azure,devops/gcp}
mkdir -p microservices/plans-service/{src,devops/local,devops/aws,devops/azure,devops/gcp}
mkdir -p microservices/order-service/{src,devops/local,devops/aws,devops/azure,devops/gcp}
mkdir -p microservices/ai-gateway-service/{src,devops/local,devops/aws,devops/azure,devops/gcp}

# Data Engineering
mkdir -p data-engineering/{src,devops/local,devops/aws,devops/azure,devops/gcp}

# Docs & Workflows
mkdir -p docs
mkdir -p .github/workflows

# Add .gitkeep to track empty folders
find . -type d -empty -exec touch {}/.gitkeep \;
