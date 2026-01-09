#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping all services...${NC}"

# Stop by port
for port in 8081 8083 8084 8085; do
    pid=$(lsof -ti:$port 2>/dev/null)
    if [ -n "$pid" ]; then
        kill -9 $pid 2>/dev/null
        echo -e "${GREEN}✓${NC} Stopped service on port $port (PID: $pid)"
    else
        echo "  No service running on port $port"
    fi
done

echo ""
echo -e "${GREEN}All services stopped.${NC}"