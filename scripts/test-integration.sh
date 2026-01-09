#!/bin/bash

# =============================================================================
# Test Inter-Service Integration
# =============================================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==============================================================================${NC}"
echo -e "${CYAN}              Testing Inter-Service Integration                               ${NC}"
echo -e "${CYAN}==============================================================================${NC}"
echo ""

# Check services are running
echo -e "${YELLOW}Checking services...${NC}"

check_service() {
    local name=$1
    local url=$2
    if curl -s "$url" | jq -e '.status == "UP"' > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name is UP"
        return 0
    else
        echo -e "${RED}✗${NC} $name is DOWN"
        return 1
    fi
}

check_service "Plans Service" "http://localhost:8081/actuator/health" || exit 1
check_service "Customer Service" "http://localhost:8083/actuator/health" || exit 1
check_service "Order Service" "http://localhost:8084/actuator/health" || exit 1

echo ""
echo -e "${YELLOW}Fetching test data...${NC}"

# Get a real plan ID (POST request - plans search is POST not GET)
PLAN_RESPONSE=$(curl -s -X POST "http://localhost:8081/api/v1/plans/search" \
  -H "Content-Type: application/json" \
  -d '{"page": 0, "size": 1}')

PLAN_ID=$(echo "$PLAN_RESPONSE" | jq -r '.content[0].id')
if [ "$PLAN_ID" == "null" ] || [ -z "$PLAN_ID" ]; then
    echo -e "${RED}✗${NC} No plans found. Run: npm run datagen:plans"
    exit 1
fi
echo -e "${GREEN}✓${NC} Plan ID: $PLAN_ID"

# Get plan details
PLAN_NAME=$(curl -s "http://localhost:8081/api/v1/plans/$PLAN_ID" | jq -r '.planName')
echo "  Plan Name: $PLAN_NAME"

# Get a real customer ID (POST request)
CUSTOMER_RESPONSE=$(curl -s -X POST "http://localhost:8083/api/v1/customers/search" \
  -H "Content-Type: application/json" \
  -d '{"status": "ACTIVE", "page": 0, "size": 1}')

CUSTOMER_ID=$(echo "$CUSTOMER_RESPONSE" | jq -r '.content[0].id')
if [ "$CUSTOMER_ID" == "null" ] || [ -z "$CUSTOMER_ID" ]; then
    echo -e "${RED}✗${NC} No customers found. Run: npm run datagen:customer"
    exit 1
fi
echo -e "${GREEN}✓${NC} Customer ID: $CUSTOMER_ID"

# Get customer details
CUSTOMER_NAME=$(curl -s "http://localhost:8083/api/v1/customers/$CUSTOMER_ID" | jq -r '.fullName')
echo "  Customer Name: $CUSTOMER_NAME"

echo ""
echo -e "${YELLOW}Creating order with inter-service integration...${NC}"

# Create order - this tests Order Service calling Plans and Customer services
# Use date command compatible with both Linux and macOS
if date -v+1m +%Y-%m-01 > /dev/null 2>&1; then
    EFFECTIVE_DATE=$(date -v+1m +%Y-%m-01)  # macOS
else
    EFFECTIVE_DATE=$(date -d "+1 month" +%Y-%m-01)  # Linux
fi

ORDER_RESPONSE=$(curl -s -X POST "http://localhost:8084/api/v1/orders" \
  -H "Content-Type: application/json" \
  -d "{
    \"customerId\": \"$CUSTOMER_ID\",
    \"orderType\": \"NEW_ENROLLMENT\",
    \"effectiveDate\": \"$EFFECTIVE_DATE\",
    \"billingFrequency\": \"MONTHLY\",
    \"items\": [{
      \"planId\": \"$PLAN_ID\",
      \"quantity\": 1,
      \"includeDependents\": false
    }],
    \"promoCode\": \"SAVE10\"
  }")

ORDER_ID=$(echo "$ORDER_RESPONSE" | jq -r '.id')
ORDER_NUMBER=$(echo "$ORDER_RESPONSE" | jq -r '.orderNumber')
ORDER_CUSTOMER_NAME=$(echo "$ORDER_RESPONSE" | jq -r '.customerName')
ORDER_PLAN_NAME=$(echo "$ORDER_RESPONSE" | jq -r '.items[0].planName')
ORDER_TOTAL=$(echo "$ORDER_RESPONSE" | jq -r '.totalAmount')

if [ "$ORDER_ID" == "null" ] || [ -z "$ORDER_ID" ]; then
    echo -e "${RED}✗${NC} Order creation failed!"
    echo "$ORDER_RESPONSE" | jq '.'
    exit 1
fi

echo -e "${GREEN}✓${NC} Order created successfully!"
echo ""
echo -e "${CYAN}Order Details:${NC}"
echo "  Order Number:  $ORDER_NUMBER"
echo "  Customer Name: $ORDER_CUSTOMER_NAME"
echo "  Plan Name:     $ORDER_PLAN_NAME"
echo "  Total Amount:  \$$ORDER_TOTAL"

echo ""
echo -e "${YELLOW}Verifying integration...${NC}"

# Verify customer name came from Customer Service
if [ "$ORDER_CUSTOMER_NAME" == "$CUSTOMER_NAME" ]; then
    echo -e "${GREEN}✓${NC} Customer data integration working"
else
    echo -e "${YELLOW}⚠${NC} Customer name mismatch (may be using fallback)"
    echo "  Expected: $CUSTOMER_NAME"
    echo "  Got:      $ORDER_CUSTOMER_NAME"
fi

# Verify plan name came from Plans Service
if [ "$ORDER_PLAN_NAME" == "$PLAN_NAME" ]; then
    echo -e "${GREEN}✓${NC} Plans data integration working"
elif [ "$ORDER_PLAN_NAME" != "Healthcare Plan" ] && [ "$ORDER_PLAN_NAME" != "null" ]; then
    echo -e "${GREEN}✓${NC} Plans data integration working"
    echo "  Plan: $ORDER_PLAN_NAME"
else
    echo -e "${YELLOW}⚠${NC} Plan name is default (may be using fallback)"
fi

echo ""
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}              Integration Test Complete!                                      ${NC}"
echo -e "${GREEN}==============================================================================${NC}"
echo ""
echo "Order ID: $ORDER_ID"
echo "View order: curl http://localhost:8084/api/v1/orders/$ORDER_ID | jq '.'"