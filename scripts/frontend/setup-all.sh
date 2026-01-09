#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Frontend Setup - All Steps           ${NC}"
echo -e "${GREEN}========================================${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/01-init.sh"
"$SCRIPT_DIR/02-dependencies.sh"
"$SCRIPT_DIR/03-config.sh"
"$SCRIPT_DIR/04-lib.sh"
"$SCRIPT_DIR/05-components.sh"
"$SCRIPT_DIR/06-pages.sh"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Frontend Setup Complete!             ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "To start the frontend:"
echo "  cd frontend"
echo "  npm run dev"
echo ""
echo "Open: http://localhost:3000"