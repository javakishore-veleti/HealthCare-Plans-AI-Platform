#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[4/4] Setting up WireMock Payment Service...${NC}"

# =============================================================================
# CREATE WIREMOCK DIRECTORY STRUCTURE
# =============================================================================

mkdir -p wiremock/mappings
mkdir -p wiremock/__files

# =============================================================================
# WIREMOCK CONFIGURATION
# =============================================================================

cat > wiremock/docker-compose.yml << 'EOF'
version: '3.8'

services:
  wiremock:
    image: wiremock/wiremock:3.3.1
    container_name: healthcare-wiremock
    ports:
      - "8086:8080"
    volumes:
      - ./mappings:/home/wiremock/mappings
      - ./__files:/home/wiremock/__files
    command: --global-response-templating --verbose
EOF
echo -e "${GREEN}✓${NC} docker-compose.yml created"

# =============================================================================
# PAYMENT PROCESSING ENDPOINT
# =============================================================================

cat > wiremock/mappings/process-payment.json << 'EOF'
{
  "request": {
    "method": "POST",
    "urlPath": "/api/v1/payments/process"
  },
  "response": {
    "status": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "id": "{{randomValue type='UUID'}}",
      "transactionId": "TXN-{{randomValue length=12 type='ALPHANUMERIC'}}",
      "orderId": "{{jsonPath request.body '$.orderId'}}",
      "amount": "{{jsonPath request.body '$.amount'}}",
      "currency": "{{jsonPath request.body '$.currency'}}",
      "status": "COMPLETED",
      "paymentMethod": "{{jsonPath request.body '$.paymentMethod'}}",
      "processedAt": "{{now format='yyyy-MM-dd\\'T\\'HH:mm:ss.SSS\\'Z\\''}}",
      "message": "Payment processed successfully"
    },
    "transformers": ["response-template"]
  }
}
EOF
echo -e "${GREEN}✓${NC} process-payment.json created"

# =============================================================================
# PAYMENT FAILURE SIMULATION (for testing)
# =============================================================================

cat > wiremock/mappings/process-payment-declined.json << 'EOF'
{
  "request": {
    "method": "POST",
    "urlPath": "/api/v1/payments/process",
    "bodyPatterns": [
      {
        "contains": "4000000000000002"
      }
    ]
  },
  "response": {
    "status": 400,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "error": "CARD_DECLINED",
      "message": "Your card was declined. Please try a different payment method.",
      "code": "PAYMENT_FAILED"
    }
  },
  "priority": 1
}
EOF
echo -e "${GREEN}✓${NC} process-payment-declined.json created"

# =============================================================================
# INSUFFICIENT FUNDS SIMULATION
# =============================================================================

cat > wiremock/mappings/process-payment-insufficient.json << 'EOF'
{
  "request": {
    "method": "POST",
    "urlPath": "/api/v1/payments/process",
    "bodyPatterns": [
      {
        "contains": "4000000000009995"
      }
    ]
  },
  "response": {
    "status": 400,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "error": "INSUFFICIENT_FUNDS",
      "message": "Insufficient funds. Please try a different payment method.",
      "code": "PAYMENT_FAILED"
    }
  },
  "priority": 1
}
EOF
echo -e "${GREEN}✓${NC} process-payment-insufficient.json created"

# =============================================================================
# GET PAYMENT BY ID
# =============================================================================

cat > wiremock/mappings/get-payment.json << 'EOF'
{
  "request": {
    "method": "GET",
    "urlPathPattern": "/api/v1/payments/[a-f0-9-]+"
  },
  "response": {
    "status": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "id": "{{request.pathSegments.[3]}}",
      "transactionId": "TXN-ABC123456789",
      "status": "COMPLETED",
      "amount": 350.00,
      "currency": "USD",
      "paymentMethod": "CREDIT_CARD",
      "cardLast4": "4242",
      "processedAt": "{{now format='yyyy-MM-dd\\'T\\'HH:mm:ss.SSS\\'Z\\''}}"
    },
    "transformers": ["response-template"]
  }
}
EOF
echo -e "${GREEN}✓${NC} get-payment.json created"

# =============================================================================
# SAVED PAYMENT METHODS
# =============================================================================

cat > wiremock/mappings/get-payment-methods.json << 'EOF'
{
  "request": {
    "method": "GET",
    "urlPath": "/api/v1/payments/methods"
  },
  "response": {
    "status": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": [
      {
        "id": "pm_visa_4242",
        "type": "CREDIT_CARD",
        "brand": "Visa",
        "last4": "4242",
        "expiryMonth": 12,
        "expiryYear": 2028,
        "isDefault": true,
        "createdAt": "2024-01-01T00:00:00.000Z"
      },
      {
        "id": "pm_mc_5555",
        "type": "CREDIT_CARD",
        "brand": "Mastercard",
        "last4": "5555",
        "expiryMonth": 6,
        "expiryYear": 2027,
        "isDefault": false,
        "createdAt": "2024-06-15T00:00:00.000Z"
      }
    ]
  }
}
EOF
echo -e "${GREEN}✓${NC} get-payment-methods.json created"

# =============================================================================
# SAVE PAYMENT METHOD
# =============================================================================

cat > wiremock/mappings/save-payment-method.json << 'EOF'
{
  "request": {
    "method": "POST",
    "urlPath": "/api/v1/payments/methods"
  },
  "response": {
    "status": 201,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "id": "pm_{{randomValue length=16 type='ALPHANUMERIC'}}",
      "type": "{{jsonPath request.body '$.type'}}",
      "brand": "Visa",
      "last4": "{{jsonPath request.body '$.cardNumber' default='0000'}}",
      "expiryMonth": 12,
      "expiryYear": 2028,
      "isDefault": false,
      "createdAt": "{{now format='yyyy-MM-dd\\'T\\'HH:mm:ss.SSS\\'Z\\''}}"
    },
    "transformers": ["response-template"]
  }
}
EOF
echo -e "${GREEN}✓${NC} save-payment-method.json created"

# =============================================================================
# DELETE PAYMENT METHOD
# =============================================================================

cat > wiremock/mappings/delete-payment-method.json << 'EOF'
{
  "request": {
    "method": "DELETE",
    "urlPathPattern": "/api/v1/payments/methods/.*"
  },
  "response": {
    "status": 204
  }
}
EOF
echo -e "${GREEN}✓${NC} delete-payment-method.json created"

# =============================================================================
# REFUND ENDPOINT
# =============================================================================

cat > wiremock/mappings/refund-payment.json << 'EOF'
{
  "request": {
    "method": "POST",
    "urlPathPattern": "/api/v1/payments/[a-f0-9-]+/refund"
  },
  "response": {
    "status": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "id": "{{randomValue type='UUID'}}",
      "originalPaymentId": "{{request.pathSegments.[3]}}",
      "refundTransactionId": "REF-{{randomValue length=12 type='ALPHANUMERIC'}}",
      "amount": "{{jsonPath request.body '$.amount'}}",
      "status": "REFUNDED",
      "reason": "{{jsonPath request.body '$.reason'}}",
      "processedAt": "{{now format='yyyy-MM-dd\\'T\\'HH:mm:ss.SSS\\'Z\\''}}"
    },
    "transformers": ["response-template"]
  }
}
EOF
echo -e "${GREEN}✓${NC} refund-payment.json created"

# =============================================================================
# HEALTH CHECK
# =============================================================================

cat > wiremock/mappings/health.json << 'EOF'
{
  "request": {
    "method": "GET",
    "urlPath": "/health"
  },
  "response": {
    "status": 200,
    "headers": {
      "Content-Type": "application/json"
    },
    "jsonBody": {
      "status": "UP",
      "service": "payment-service-mock",
      "timestamp": "{{now format='yyyy-MM-dd\\'T\\'HH:mm:ss.SSS\\'Z\\''}}"
    },
    "transformers": ["response-template"]
  }
}
EOF
echo -e "${GREEN}✓${NC} health.json created"

# =============================================================================
# UPDATE NEXT.JS CONFIG TO PROXY TO WIREMOCK
# =============================================================================

cat > customer-portal/next.config.ts << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      // Auth & Profiles on Customer Service (8083)
      { source: '/api/auth/:path*', destination: 'http://localhost:8083/api/v1/auth/:path*' },
      { source: '/api/profiles/:path*', destination: 'http://localhost:8083/api/v1/profiles/:path*' },
      { source: '/api/customers/:path*', destination: 'http://localhost:8083/api/v1/customers/:path*' },
      // Plans Service (8081)
      { source: '/api/plans/:path*', destination: 'http://localhost:8081/api/v1/plans/:path*' },
      // Order Service (8084)
      { source: '/api/orders/:path*', destination: 'http://localhost:8084/api/v1/orders/:path*' },
      { source: '/api/quotes/:path*', destination: 'http://localhost:8084/api/v1/quotes/:path*' },
      // Payment Service - WireMock (8086)
      { source: '/api/payments/:path*', destination: 'http://localhost:8086/api/v1/payments/:path*' },
    ];
  },
};

export default nextConfig;
EOF
echo -e "${GREEN}✓${NC} next.config.ts updated"

# =============================================================================
# CREATE START SCRIPT
# =============================================================================

cat > wiremock/start.sh << 'EOF'
#!/bin/bash
echo "Starting WireMock Payment Service..."
docker-compose up -d
echo ""
echo "WireMock Payment Service running at http://localhost:8086"
echo ""
echo "Test endpoints:"
echo "  POST http://localhost:8086/api/v1/payments/process"
echo "  GET  http://localhost:8086/api/v1/payments/{id}"
echo "  GET  http://localhost:8086/api/v1/payments/methods"
echo "  POST http://localhost:8086/api/v1/payments/methods"
echo "  GET  http://localhost:8086/health"
echo ""
echo "Test card numbers:"
echo "  4242424242424242 - Success"
echo "  4000000000000002 - Declined"
echo "  4000000000009995 - Insufficient funds"
EOF
chmod +x wiremock/start.sh
echo -e "${GREEN}✓${NC} start.sh created"

cat > wiremock/stop.sh << 'EOF'
#!/bin/bash
echo "Stopping WireMock Payment Service..."
docker-compose down
echo "WireMock stopped."
EOF
chmod +x wiremock/stop.sh
echo -e "${GREEN}✓${NC} stop.sh created"

# =============================================================================
# ADD TO ROOT PACKAGE.JSON
# =============================================================================

echo -e "${CYAN}Adding WireMock scripts to root package.json...${NC}"

# Check if jq is available, otherwise provide manual instructions
if command -v jq &> /dev/null; then
    jq '.scripts["start:wiremock"] = "cd wiremock && ./start.sh" | .scripts["stop:wiremock"] = "cd wiremock && ./stop.sh"' package.json > package.json.tmp && mv package.json.tmp package.json
    echo -e "${GREEN}✓${NC} package.json updated"
else
    echo -e "${CYAN}Add these scripts to package.json manually:${NC}"
    echo '  "start:wiremock": "cd wiremock && ./start.sh",'
    echo '  "stop:wiremock": "cd wiremock && ./stop.sh"'
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  WireMock Payment Service Ready!      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "To start WireMock:"
echo "  cd wiremock && ./start.sh"
echo "  OR"
echo "  docker-compose -f wiremock/docker-compose.yml up -d"
echo ""
echo "Test card numbers:"
echo "  4242424242424242 - Success"
echo "  4000000000000002 - Card Declined"
echo "  4000000000009995 - Insufficient Funds"
echo ""
echo "Endpoints:"
echo "  POST /api/v1/payments/process    - Process payment"
echo "  GET  /api/v1/payments/{id}       - Get payment"
echo "  GET  /api/v1/payments/methods    - List saved methods"
echo "  POST /api/v1/payments/methods    - Save payment method"
echo "  DELETE /api/v1/payments/methods/{id} - Delete method"
echo ""