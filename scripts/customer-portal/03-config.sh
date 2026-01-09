#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[3/8] Creating configuration files...${NC}"

cd customer-portal

# Next.js config with API proxy
cat > next.config.ts << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      { source: '/api/auth/:path*', destination: 'http://localhost:8085/api/v1/auth/:path*' },
      { source: '/api/plans/:path*', destination: 'http://localhost:8081/api/v1/plans/:path*' },
      { source: '/api/customers/:path*', destination: 'http://localhost:8083/api/v1/customers/:path*' },
      { source: '/api/orders/:path*', destination: 'http://localhost:8084/api/v1/orders/:path*' },
      { source: '/api/payments/:path*', destination: 'http://localhost:8084/api/v1/payments/:path*' },
      { source: '/api/quotes/:path*', destination: 'http://localhost:8084/api/v1/quotes/:path*' },
      { source: '/api/profiles/:path*', destination: 'http://localhost:8083/api/v1/profiles/:path*' },
    ];
  },
};

export default nextConfig;
EOF

# Environment file
cat > .env.local << 'EOF'
NEXT_PUBLIC_APP_NAME=HealthCare Plans
NEXT_PUBLIC_API_URL=
NEXT_PUBLIC_MAX_PROFILES=500
EOF

# Prettier config
cat > .prettierrc << 'EOF'
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "trailingComma": "es5",
  "plugins": ["prettier-plugin-tailwindcss"]
}
EOF

echo -e "${GREEN}✓ Config files created${NC}"