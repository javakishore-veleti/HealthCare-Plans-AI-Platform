#!/bin/bash

# =============================================================================
# Stop all running services
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping all services...${NC}"

# Find and kill Spring Boot processes
pkill -f "spring-boot:run.*plans-api" && echo -e "${GREEN}✓${NC} Stopped Plans Service" || echo "  Plans Service not running"
pkill -f "spring-boot:run.*customer-api" && echo -e "${GREEN}✓${NC} Stopped Customer Service" || echo "  Customer Service not running"
pkill -f "spring-boot:run.*order-api" && echo -e "${GREEN}✓${NC} Stopped Order Service" || echo "  Order Service not running"

# Alternative: kill by port
# lsof -ti:8081 | xargs kill -9 2>/dev/null
# lsof -ti:8083 | xargs kill -9 2>/dev/null
# lsof -ti:8084 | xargs kill -9 2>/dev/null

echo ""
echo -e "${GREEN}All services stopped.${NC}"