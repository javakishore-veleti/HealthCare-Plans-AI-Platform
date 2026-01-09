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
