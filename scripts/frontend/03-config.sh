#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[3/6] Creating configuration files...${NC}"

cd frontend

# Tailwind config
cat > tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    container: { center: true, padding: "2rem", screens: { "2xl": "1400px" } },
    extend: {
      colors: {
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: { DEFAULT: "hsl(var(--primary))", foreground: "hsl(var(--primary-foreground))" },
        secondary: { DEFAULT: "hsl(var(--secondary))", foreground: "hsl(var(--secondary-foreground))" },
        destructive: { DEFAULT: "hsl(var(--destructive))", foreground: "hsl(var(--destructive-foreground))" },
        muted: { DEFAULT: "hsl(var(--muted))", foreground: "hsl(var(--muted-foreground))" },
        accent: { DEFAULT: "hsl(var(--accent))", foreground: "hsl(var(--accent-foreground))" },
        card: { DEFAULT: "hsl(var(--card))", foreground: "hsl(var(--card-foreground))" },
      },
      borderRadius: { lg: "var(--radius)", md: "calc(var(--radius) - 2px)", sm: "calc(var(--radius) - 4px)" },
    },
  },
  plugins: [require("tailwindcss-animate")],
};

export default config;
EOF

# Next.js config with API proxy
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  async rewrites() {
    return [
      { source: '/api/plans/:path*', destination: 'http://localhost:8081/api/v1/plans/:path*' },
      { source: '/api/customers/:path*', destination: 'http://localhost:8083/api/v1/customers/:path*' },
      { source: '/api/orders/:path*', destination: 'http://localhost:8084/api/v1/orders/:path*' },
      { source: '/api/payments/:path*', destination: 'http://localhost:8084/api/v1/payments/:path*' },
      { source: '/api/invoices/:path*', destination: 'http://localhost:8084/api/v1/invoices/:path*' },
    ];
  },
};
module.exports = nextConfig;
EOF

# Environment file
cat > .env.local << 'EOF'
NEXT_PUBLIC_APP_NAME=HealthCare Plans
NEXT_PUBLIC_API_URL=
EOF

echo -e "${GREEN}✓ Config files created${NC}"