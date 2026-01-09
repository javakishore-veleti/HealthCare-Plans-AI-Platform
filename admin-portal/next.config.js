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
