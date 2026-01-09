#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[1/8] Initializing Customer Portal...${NC}"

npx create-next-app@latest customer-portal \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --no-git

# Fix: Use webpack instead of turbopack
cd customer-portal
sed -i '' 's/"dev": "next dev"/"dev": "next dev --webpack -p 3001"/' package.json

echo -e "${GREEN}✓ Customer Portal initialized on port 3001${NC}"