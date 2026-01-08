#!/bin/bash

# =============================================================================
# Healthcare Platform - Stop All Local Infrastructure
# =============================================================================
# Compatible with Bash 3.x (macOS default)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Healthcare Platform - Stopping Local Infrastructure                      ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

# Stop in reverse dependency order
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
        echo -e "${CYAN}Stopping ${name}...${NC}"
        docker-compose -f "$SCRIPT_DIR/$service/docker-compose.yml" down 2>/dev/null || true
        echo -e "${GREEN}✓${NC} ${name} stopped"
    fi
done

echo ""
echo -e "${GREEN}All services stopped!${NC}"