#!/bin/bash

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Starting data generation...${NC}"

run_datagen() {
    local name=$1
    local pom=$2
    
    echo -e "${CYAN}Generating $name data...${NC}"
    
    timeout 90 mvn -f $pom spring-boot:run -Dspring-boot.run.profiles=local,datagen > /tmp/datagen-$name.log 2>&1 || true
    
    echo -e "${GREEN}✓ $name data generation completed${NC}"
}

echo "Invoking microservices/plans-service/plans-api/pom.xml"
run_datagen "plans" "microservices/plans-service/plans-api/pom.xml"

echo "Invoking microservices/customer-onboarding-service/customer-api/pom.xml"
run_datagen "customer" "microservices/customer-onboarding-service/customer-api/pom.xml"

echo "Invoking microservices/order-management-service/order-api/pom.xml"
run_datagen "order" "microservices/order-management-service/order-api/pom.xml"

echo ""
echo -e "${GREEN}All data generation completed!${NC}"
