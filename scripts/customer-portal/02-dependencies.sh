#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[2/8] Installing dependencies...${NC}"

cd customer-portal

# Core dependencies
npm install \
  @tanstack/react-query \
  axios \
  zustand \
  react-hook-form \
  @hookform/resolvers \
  zod \
  framer-motion \
  date-fns \
  lucide-react \
  clsx \
  tailwind-merge \
  class-variance-authority \
  next-themes \
  sonner

# Radix UI components
npm install \
  @radix-ui/react-avatar \
  @radix-ui/react-dialog \
  @radix-ui/react-dropdown-menu \
  @radix-ui/react-label \
  @radix-ui/react-select \
  @radix-ui/react-separator \
  @radix-ui/react-slot \
  @radix-ui/react-tabs \
  @radix-ui/react-tooltip \
  @radix-ui/react-popover \
  @radix-ui/react-checkbox \
  @radix-ui/react-radio-group \
  @radix-ui/react-switch

# Dev dependencies
npm install -D prettier prettier-plugin-tailwindcss

echo -e "${GREEN}✓ Dependencies installed${NC}"