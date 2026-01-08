#!/bin/bash

# =============================================================================
# Healthcare Platform - Check Status of All Local Infrastructure
# =============================================================================
# Compatible with Bash 3.x (macOS default)
# =============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Healthcare Platform - Infrastructure Status                              ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""

check_service() {
    local name=$1
    local container=$2
    local port=$3
    local url=$4
    
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${container}$"; then
        if [ -n "$url" ]; then
            echo -e "${GREEN}✓${NC} $name: ${GREEN}RUNNING${NC} (port $port) - $url"
        else
            echo -e "${GREEN}✓${NC} $name: ${GREEN}RUNNING${NC} (port $port)"
        fi
    else
        echo -e "${RED}✗${NC} $name: ${RED}STOPPED${NC}"
    fi
}

echo -e "${CYAN}Databases:${NC}"
check_service "PostgreSQL" "healthcare-postgres" "5432" ""
check_service "Cassandra" "healthcare-cassandra" "9042" ""
check_service "MongoDB" "healthcare-mongodb" "27017" ""
check_service "Mongo Express" "healthcare-mongo-express" "8088" "http://localhost:8088"

echo ""
echo -e "${CYAN}Cache:${NC}"
check_service "Redis" "healthcare-redis" "6379" ""
check_service "Redis Commander" "healthcare-redis-commander" "8085" "http://localhost:8085"

echo ""
echo -e "${CYAN}Messaging:${NC}"
check_service "Zookeeper" "healthcare-zookeeper" "2181" ""
check_service "Kafka" "healthcare-kafka" "9092" ""
check_service "Kafka UI" "healthcare-kafka-ui" "8086" "http://localhost:8086"

echo ""
echo -e "${CYAN}Vector DBs:${NC}"
check_service "PGVector" "healthcare-pgvector" "5433" ""
check_service "Milvus" "healthcare-milvus" "19530" ""
check_service "Milvus Attu" "healthcare-milvus-attu" "8089" "http://localhost:8089"
check_service "Qdrant" "healthcare-qdrant" "6333" ""
check_service "Weaviate" "healthcare-weaviate" "8090" ""

echo ""
echo -e "${CYAN}ETL:${NC}"
check_service "Airflow Webserver" "healthcare-airflow-webserver" "8091" "http://localhost:8091"
check_service "Airflow Scheduler" "healthcare-airflow-scheduler" "-" ""

echo ""
echo -e "${CYAN}AI/ML:${NC}"
check_service "MLflow" "healthcare-mlflow" "5000" "http://localhost:5000"

echo ""
echo -e "${CYAN}Observability:${NC}"
check_service "Prometheus" "healthcare-prometheus" "9090" "http://localhost:9090"
check_service "Grafana" "healthcare-grafana" "3000" "http://localhost:3000"
check_service "Jaeger" "healthcare-jaeger" "16686" "http://localhost:16686"

echo ""
echo -e "${CYAN}Mocking:${NC}"
check_service "WireMock" "healthcare-wiremock" "8087" "http://localhost:8087/__admin"

echo ""
echo -e "${CYAN}Docker Containers:${NC}"
docker ps --filter "name=healthcare-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | head -20 || echo "No containers running"
echo ""