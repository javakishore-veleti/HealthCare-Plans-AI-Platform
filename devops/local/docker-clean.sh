#!/bin/bash

# =============================================================================
# Healthcare Platform - Clean All Local Infrastructure (including volumes)
# =============================================================================
# Compatible with Bash 3.x (macOS default)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}==============================================================================${NC}"
echo -e "${YELLOW}     Healthcare Platform - Clean Local Infrastructure                         ${NC}"
echo -e "${YELLOW}     WARNING: This will delete ALL data!                                      ${NC}"
echo -e "${YELLOW}==============================================================================${NC}"
echo ""

read -p "Are you sure you want to delete all containers and volumes? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    SERVICES="
    mocking/wiremock
    observability/jaeger
    observability/grafana
    observability/prometheus
    ai-ml/mlflow
    etl/airflow
    vectordb/weaviate
    vectordb/qdrant
    vectordb/milvus
    vectordb/pgvector
    messaging/kafka
    cache/redis
    databases/mongodb
    databases/cassandra
    databases/postgres
    "
    
    for service in $SERVICES; do
        if [ -f "$SCRIPT_DIR/$service/docker-compose.yml" ]; then
            name=$(basename "$service")
            echo -e "${RED}Cleaning ${name} (including volumes)...${NC}"
            docker-compose -f "$SCRIPT_DIR/$service/docker-compose.yml" down -v 2>/dev/null || true
        fi
    done
    
    # Remove network
    echo -e "${RED}Removing healthcare-network...${NC}"
    docker network rm healthcare-network 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}All services and volumes cleaned!${NC}"
else
    echo "Cancelled."
fi