#!/bin/bash

# =============================================================================
# Healthcare Plans AI Platform - Microservices Structure Generator
# =============================================================================
# Compatible with older bash versions (macOS default bash 3.x)
# =============================================================================

set -e

# Base directory - adjust if needed
BASE_DIR="microservices"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}       Healthcare Plans AI Platform - Microservices Structure Generator       ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# Create base directory if not exists
if [ ! -d "$BASE_DIR" ]; then
    mkdir -p "$BASE_DIR"
    echo -e "${GREEN}✓${NC} Created base directory: $BASE_DIR"
fi

# Function to create blank pom.xml
create_blank_pom() {
    local pom_path=$1
    
    if [ -f "$pom_path" ]; then
        echo -e "${YELLOW}⊘${NC} Skipped (exists): $pom_path"
    else
        cat > "$pom_path" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <!-- TODO: Configure this POM -->

</project>
EOF
        echo -e "${GREEN}✓${NC} Created: $pom_path"
    fi
}

# Function to create source directories and .gitkeep
create_module_structure() {
    local module_path=$1
    
    # Create source directories
    mkdir -p "$module_path/src/main/java"
    mkdir -p "$module_path/src/main/resources"
    mkdir -p "$module_path/src/test/java"
    mkdir -p "$module_path/src/test/resources"
    
    # Add .gitkeep to empty directories
    touch "$module_path/src/main/java/.gitkeep"
    touch "$module_path/src/main/resources/.gitkeep"
    touch "$module_path/src/test/java/.gitkeep"
    touch "$module_path/src/test/resources/.gitkeep"
}

# Function to create devops directories
create_devops_dirs() {
    local service_path=$1
    
    mkdir -p "$service_path/devops/local"
    mkdir -p "$service_path/devops/aws"
    mkdir -p "$service_path/devops/azure"
    mkdir -p "$service_path/devops/gcp"
    
    touch "$service_path/devops/local/.gitkeep"
    touch "$service_path/devops/aws/.gitkeep"
    touch "$service_path/devops/azure/.gitkeep"
    touch "$service_path/devops/gcp/.gitkeep"
    
    echo -e "${GREEN}✓${NC} Created devops directories"
}

# Function to create a microservice with its modules
create_service() {
    local service_name=$1
    shift
    local modules="$@"
    
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  Processing: $service_name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    local service_path="$BASE_DIR/$service_name"
    
    # Create service directory
    mkdir -p "$service_path"
    echo -e "${GREEN}✓${NC} Created directory: $service_path"
    
    # Create service parent pom.xml
    create_blank_pom "$service_path/pom.xml"
    
    # Create devops directories
    create_devops_dirs "$service_path"
    
    # Create each sub-module
    for module in $modules; do
        local module_path="$service_path/$module"
        
        # Create module directory
        mkdir -p "$module_path"
        
        # Create pom.xml
        create_blank_pom "$module_path/pom.xml"
        
        # Create source directories
        create_module_structure "$module_path"
    done
}

# =============================================================================
# CREATE ALL MICROSERVICES
# =============================================================================

# Plans Service (6 modules)
create_service "plans-service" \
    "plans-common" \
    "plans-dao" \
    "plans-service-core" \
    "plans-api-client" \
    "plans-api-stub" \
    "plans-api"

# Customer Onboarding Service (6 modules)
create_service "customer-onboarding-service" \
    "customer-common" \
    "customer-dao" \
    "customer-service-core" \
    "customer-api-client" \
    "customer-api-stub" \
    "customer-api"

# Order Service (6 modules)
create_service "order-service" \
    "order-common" \
    "order-dao" \
    "order-service-core" \
    "order-api-client" \
    "order-api-stub" \
    "order-api"

# AI Gateway Service (7 modules - includes rag module)
create_service "ai-gateway-service" \
    "ai-gateway-common" \
    "ai-gateway-dao" \
    "ai-gateway-service-core" \
    "ai-gateway-rag" \
    "ai-gateway-api-client" \
    "ai-gateway-api-stub" \
    "ai-gateway-api"

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}                         Structure Generation Complete!                       ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "Directory structure created under: ${YELLOW}$BASE_DIR/${NC}"
echo ""
echo -e "${YELLOW}Summary:${NC}"
echo -e "  • plans-service (6 modules)"
echo -e "  • customer-onboarding-service (6 modules)"
echo -e "  • order-service (6 modules)"
echo -e "  • ai-gateway-service (7 modules - includes rag module)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Update each blank pom.xml with proper configuration"
echo -e "  2. Add Java source files to src/main/java directories"
echo -e "  3. Add resources to src/main/resources directories"
echo ""
echo -e "${YELLOW}Files that were preserved (not overwritten):${NC}"
echo -e "  • microservices/plans-service/pom.xml (if existed)"
echo -e "  • microservices/plans-service/plans-common/pom.xml (if existed)"
echo ""