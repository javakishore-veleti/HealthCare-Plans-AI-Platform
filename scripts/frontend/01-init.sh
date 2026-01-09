#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[1/6] Initializing Next.js application...${NC}"

FRONTEND_DIR="frontend"

# Create Next.js app
npx create-next-app@latest $FRONTEND_DIR \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --no-git

echo -e "${GREEN}✓ Next.js app created${NC}"