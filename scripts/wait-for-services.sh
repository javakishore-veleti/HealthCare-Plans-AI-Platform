#!/bin/bash

# =============================================================================
# Wait for all services to be healthy
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Waiting for services to start...${NC}"

MAX_WAIT=120
INTERVAL=5

wait_for_service() {
    local name=$1
    local url=$2
    local elapsed=0
    
    while [ $elapsed -lt $MAX_WAIT ]; do
        if curl -s "$url" | jq -e '.status == "UP"' > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $name is UP"
            return 0
        fi
        sleep $INTERVAL
        elapsed=$((elapsed + INTERVAL))
        echo -e "  Waiting for $name... (${elapsed}s)"
    done
    
    echo -e "${RED}✗${NC} $name failed to start within ${MAX_WAIT}s"
    return 1
}

echo ""
wait_for_service "Plans Service (8081)" "http://localhost:8081/actuator/health"
wait_for_service "Customer Service (8083)" "http://localhost:8083/actuator/health"
wait_for_service "Order Service (8084)" "http://localhost:8084/actuator/health"

echo ""
echo -e "${GREEN}All services are running!${NC}"
echo ""
echo "Swagger UIs:"
echo "  Plans:    http://localhost:8081/swagger-ui.html"
echo "  Customer: http://localhost:8083/swagger-ui.html"
echo "  Order:    http://localhost:8084/swagger-ui.html"