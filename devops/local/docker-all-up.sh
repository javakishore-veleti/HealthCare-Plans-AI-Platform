#!/bin/bash

# =============================================================================
# Healthcare Platform - Start All Local Infrastructure
# =============================================================================
# Compatible with Bash 3.x (macOS default)
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

print_usage() {
    echo "Usage: $0 [OPTIONS] [CATEGORY...]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Categories (default: core):"
    echo "  core           PostgreSQL, Redis, Kafka (recommended minimum)"
    echo "  databases      PostgreSQL, Cassandra, MongoDB"
    echo "  cache          Redis"
    echo "  messaging      Kafka + Zookeeper + UI"
    echo "  vectordb       PGVector, Milvus, Qdrant, Weaviate"
    echo "  etl            Airflow"
    echo "  ai-ml          MLflow"
    echo "  observability  Prometheus, Grafana, Jaeger"
    echo "  mocking        WireMock"
    echo "  all            Everything"
    echo ""
    echo "Examples:"
    echo "  $0                      # Start core services"
    echo "  $0 core vectordb        # Start core + vector databases"
    echo "  $0 all                  # Start everything"
}

get_service_path() {
    local service=$1
    case $service in
        postgres)    echo "databases/postgres" ;;
        cassandra)   echo "databases/cassandra" ;;
        mongodb)     echo "databases/mongodb" ;;
        redis)       echo "cache/redis" ;;
        kafka)       echo "messaging/kafka" ;;
        pgvector)    echo "vectordb/pgvector" ;;
        milvus)      echo "vectordb/milvus" ;;
        qdrant)      echo "vectordb/qdrant" ;;
        weaviate)    echo "vectordb/weaviate" ;;
        airflow)     echo "etl/airflow" ;;
        mlflow)      echo "ai-ml/mlflow" ;;
        prometheus)  echo "observability/prometheus" ;;
        grafana)     echo "observability/grafana" ;;
        jaeger)      echo "observability/jaeger" ;;
        wiremock)    echo "mocking/wiremock" ;;
        *)           echo "" ;;
    esac
}

get_category_services() {
    local category=$1
    case $category in
        core)          echo "postgres redis kafka" ;;
        databases)     echo "postgres cassandra mongodb" ;;
        cache)         echo "redis" ;;
        messaging)     echo "kafka" ;;
        vectordb)      echo "pgvector milvus qdrant weaviate" ;;
        etl)           echo "airflow" ;;
        ai-ml)         echo "mlflow" ;;
        observability) echo "prometheus grafana jaeger" ;;
        mocking)       echo "wiremock" ;;
        all)           echo "postgres cassandra mongodb redis kafka pgvector milvus qdrant weaviate airflow mlflow prometheus grafana jaeger wiremock" ;;
        *)             echo "" ;;
    esac
}

SERVICES_TO_START=""

# Parse arguments
if [ $# -eq 0 ]; then
    SERVICES_TO_START="postgres redis kafka"
else
    while [ $# -gt 0 ]; do
        case $1 in
            -h|--help)
                print_usage
                exit 0
                ;;
            core|databases|cache|messaging|vectordb|etl|ai-ml|observability|mocking|all)
                category_services=$(get_category_services "$1")
                SERVICES_TO_START="$SERVICES_TO_START $category_services"
                shift
                ;;
            postgres|cassandra|mongodb|redis|kafka|pgvector|milvus|qdrant|weaviate|airflow|mlflow|prometheus|grafana|jaeger|wiremock)
                SERVICES_TO_START="$SERVICES_TO_START $1"
                shift
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                print_usage
                exit 1
                ;;
        esac
    done
fi

# Remove duplicates and leading space
SERVICES_TO_START=$(echo "$SERVICES_TO_START" | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Healthcare Platform - Starting Local Infrastructure                      ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${CYAN}Services to start:${NC} $SERVICES_TO_START"
echo ""

# Check if postgres is in the list
start_postgres=false
for svc in $SERVICES_TO_START; do
    if [ "$svc" = "postgres" ]; then
        start_postgres=true
        break
    fi
done

# Always start postgres first (creates network)
if [ "$start_postgres" = true ]; then
    echo -e "${CYAN}Starting PostgreSQL (creates shared network)...${NC}"
    docker-compose -f "$SCRIPT_DIR/databases/postgres/docker-compose.yml" up -d
    echo -e "${GREEN}✓${NC} PostgreSQL started"
    
    echo -e "${CYAN}Waiting for PostgreSQL to be ready...${NC}"
    sleep 5
    until docker exec healthcare-postgres pg_isready -U postgres > /dev/null 2>&1; do
        sleep 2
    done
    echo -e "${GREEN}✓${NC} PostgreSQL is ready"
    echo ""
fi

# Start remaining services
for service in $SERVICES_TO_START; do
    if [ "$service" != "postgres" ]; then
        path=$(get_service_path "$service")
        if [ -n "$path" ] && [ -f "$SCRIPT_DIR/$path/docker-compose.yml" ]; then
            echo -e "${CYAN}Starting ${service}...${NC}"
            docker-compose -f "$SCRIPT_DIR/$path/docker-compose.yml" up -d
            echo -e "${GREEN}✓${NC} ${service} started"
        fi
    fi
done

# Initialize Cassandra if started
for svc in $SERVICES_TO_START; do
    if [ "$svc" = "cassandra" ]; then
        echo ""
        echo -e "${CYAN}Waiting for Cassandra to be ready (may take 30-60s)...${NC}"
        sleep 30
        until docker exec healthcare-cassandra cqlsh -e "describe cluster" > /dev/null 2>&1; do
            sleep 5
        done
        echo -e "${CYAN}Initializing Cassandra keyspaces...${NC}"
        docker exec healthcare-cassandra cqlsh -f /init-scripts/01-init-keyspaces.cql 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Cassandra keyspaces initialized"
        break
    fi
done

# Initialize Airflow if started
for svc in $SERVICES_TO_START; do
    if [ "$svc" = "airflow" ]; then
        echo ""
        echo -e "${CYAN}Initializing Airflow...${NC}"
        docker-compose -f "$SCRIPT_DIR/etl/airflow/docker-compose.yml" run --rm healthcare-airflow-init 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Airflow initialized"
        break
    fi
done

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}     Services started!                                                        ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo -e "${YELLOW}Endpoints:${NC}"
echo -e "  ${CYAN}Databases:${NC}"
echo -e "    PostgreSQL:       localhost:5432"
echo -e "    Cassandra:        localhost:9042"
echo -e "    MongoDB:          localhost:27017"
echo -e "    Mongo Express:    http://localhost:8088"
echo ""
echo -e "  ${CYAN}Cache:${NC}"
echo -e "    Redis:            localhost:6379"
echo -e "    Redis Commander:  http://localhost:8085"
echo ""
echo -e "  ${CYAN}Messaging:${NC}"
echo -e "    Kafka:            localhost:9092"
echo -e "    Kafka UI:         http://localhost:8086"
echo ""
echo -e "  ${CYAN}Vector DBs:${NC}"
echo -e "    PGVector:         localhost:5433"
echo -e "    Milvus:           localhost:19530"
echo -e "    Milvus Attu UI:   http://localhost:8089"
echo -e "    Qdrant:           localhost:6333"
echo -e "    Weaviate:         localhost:8090"
echo ""
echo -e "  ${CYAN}ETL:${NC}"
echo -e "    Airflow:          http://localhost:8091 (admin/admin)"
echo ""
echo -e "  ${CYAN}AI/ML:${NC}"
echo -e "    MLflow:           http://localhost:5000"
echo ""
echo -e "  ${CYAN}Observability:${NC}"
echo -e "    Prometheus:       http://localhost:9090"
echo -e "    Grafana:          http://localhost:3000 (admin/admin)"
echo -e "    Jaeger:           http://localhost:16686"
echo ""
echo -e "  ${CYAN}Mocking:${NC}"
echo -e "    WireMock:         http://localhost:8087"
echo ""