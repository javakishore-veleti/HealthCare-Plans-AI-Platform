#!/bin/bash

GREEN="\033[0;32m"
CYAN="\033[0;36m"
NC="\033[0m"

ROOT_DIR=$(pwd)
mkdir -p logs

echo "${CYAN}Starting all services...${NC}"

# Start WireMock
echo "${CYAN}Starting WireMock (port 8090)...${NC}"
cd "$ROOT_DIR/devops/local/wiremock" && docker-compose up -d
cd "$ROOT_DIR"
echo "${GREEN}✓ WireMock started${NC}"

# Start Plans Service
echo "${CYAN}Starting Plans Service (port 8081)...${NC}"
mvn -f microservices/plans-service/plans-api/pom.xml spring-boot:run -Dspring-boot.run.profiles=local > logs/plans.log 2>&1 &
echo $! > logs/plans.pid
echo "${GREEN}✓ Plans Service started${NC}"

# Start Customer Service
echo "${CYAN}Starting Customer Service (port 8083)...${NC}"
mvn -f microservices/customer-onboarding-service/customer-api/pom.xml spring-boot:run -Dspring-boot.run.profiles=local > logs/customer.log 2>&1 &
echo $! > logs/customer.pid
echo "${GREEN}✓ Customer Service started${NC}"

# Start Order Service
echo "${CYAN}Starting Order Service (port 8084)...${NC}"
mvn -f microservices/order-management-service/order-api/pom.xml spring-boot:run -Dspring-boot.run.profiles=local > logs/order.log 2>&1 &
echo $! > logs/order.pid
echo "${GREEN}✓ Order Service started${NC}"

# Wait for backend
echo "${CYAN}Waiting for backend services (30s)...${NC}"
sleep 30

# Start Admin Portal
echo "${CYAN}Starting Admin Portal (port 3000)...${NC}"
cd "$ROOT_DIR/admin-portal" && npm run dev > "$ROOT_DIR/logs/admin.log" 2>&1 &
echo $! > "$ROOT_DIR/logs/admin.pid"
cd "$ROOT_DIR"
echo "${GREEN}✓ Admin Portal started${NC}"

# Start Customer Portal
echo "${CYAN}Starting Customer Portal (port 3001)...${NC}"
cd "$ROOT_DIR/customer-portal" && npm run dev > "$ROOT_DIR/logs/portal.log" 2>&1 &
echo $! > "$ROOT_DIR/logs/portal.pid"
cd "$ROOT_DIR"
echo "${GREEN}✓ Customer Portal started${NC}"

echo ""
echo "${GREEN}All services started!${NC}"
echo ""
echo "Services:"
echo "  Plans:    http://localhost:8081"
echo "  Customer: http://localhost:8083"
echo "  Order:    http://localhost:8084"
echo "  WireMock: http://localhost:8090"
echo "  Admin:    http://localhost:3000"
echo "  Portal:   http://localhost:3001"
echo ""
echo "Logs: logs/*.log"
echo "Stop: npm run stop:all"
