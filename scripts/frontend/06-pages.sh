#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[6/6] Creating app pages...${NC}"

cd frontend
mkdir -p src/app/plans src/app/customers src/app/orders

# Global styles
cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --primary: 210 100% 40%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 210 100% 40%;
    --radius: 0.5rem;
  }
  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --primary: 210 100% 50%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 210 100% 50%;
  }
  * { @apply border-border; }
  body { @apply bg-background text-foreground; }
}
EOF

# Root layout
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Providers } from "@/lib/providers";
import { Sidebar } from "@/components/layout/sidebar";
import { Header } from "@/components/layout/header";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: { default: "HealthCare Plans", template: "%s | HealthCare" },
  description: "Healthcare plan management platform",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>
          <div className="flex min-h-screen">
            <Sidebar />
            <div className="flex-1 pl-64">
              <Header />
              <main className="p-6">{children}</main>
            </div>
          </div>
        </Providers>
      </body>
    </html>
  );
}
EOF

# Dashboard page
cat > src/app/page.tsx << 'EOF'
"use client";

import { useQuery } from "@tanstack/react-query";
import { FileText, Users, ShoppingCart, DollarSign } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { plansApi, customersApi, ordersApi } from "@/lib/api";
import Link from "next/link";

export default function Dashboard() {
  const { data: plans, isLoading: plansLoading } = useQuery({
    queryKey: ["plans-count"],
    queryFn: () => plansApi.search({ page: 0, size: 1 }),
  });

  const { data: customers, isLoading: customersLoading } = useQuery({
    queryKey: ["customers-count"],
    queryFn: () => customersApi.search({ page: 0, size: 1 }),
  });

  const { data: orders, isLoading: ordersLoading } = useQuery({
    queryKey: ["orders-count"],
    queryFn: () => ordersApi.search({ page: 0, size: 1 }),
  });

  const stats = [
    { name: "Total Plans", value: plans?.data?.totalElements || 0, icon: FileText, href: "/plans" },
    { name: "Total Customers", value: customers?.data?.totalElements || 0, icon: Users, href: "/customers" },
    { name: "Total Orders", value: orders?.data?.totalElements || 0, icon: ShoppingCart, href: "/orders" },
    { name: "Revenue", value: "$125,000", icon: DollarSign, href: "/analytics" },
  ];

  const isLoading = plansLoading || customersLoading || ordersLoading;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Welcome to HealthCare Plans Platform</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Link key={stat.name} href={stat.href}>
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">{stat.name}</CardTitle>
                <stat.icon className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <Skeleton className="h-8 w-20" />
                ) : (
                  <div className="text-2xl font-bold">{typeof stat.value === "number" ? stat.value.toLocaleString() : stat.value}</div>
                )}
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
EOF

# Plans page
cat > src/app/plans/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { plansApi } from "@/lib/api";
import { formatCurrency, getMetalTierColor } from "@/lib/utils";
import type { Plan } from "@/types";

export default function PlansPage() {
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["plans", page, search],
    queryFn: () => plansApi.search({ page, size: 12, planName: search || undefined }),
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Healthcare Plans</h1>
          <p className="text-muted-foreground">Browse and compare plans</p>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search plans..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(6)].map((_, i) => <Skeleton key={i} className="h-64" />)}
        </div>
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {data?.data?.content?.map((plan: Plan) => (
              <Card key={plan.id} className="hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div>
                      <CardTitle className="text-lg">{plan.planName}</CardTitle>
                      <CardDescription>{plan.issuerName}</CardDescription>
                    </div>
                    <Badge className={getMetalTierColor(plan.metalTier)}>{plan.metalTier}</Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Monthly Premium</span>
                      <span className="font-semibold">{formatCurrency(plan.monthlyPremium)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Deductible</span>
                      <span>{formatCurrency(plan.annualDeductible)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Out of Pocket Max</span>
                      <span>{formatCurrency(plan.outOfPocketMax)}</span>
                    </div>
                  </div>
                  <Button className="w-full">View Details</Button>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} plans
            </p>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0}>Previous</Button>
              <Button variant="outline" size="sm" onClick={() => setPage((p) => p + 1)} disabled={data?.data?.last}>Next</Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
EOF

# Customers page
cat > src/app/customers/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search, Mail, Phone } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { customersApi } from "@/lib/api";
import { formatDate, getStatusColor } from "@/lib/utils";
import type { Customer } from "@/types";

export default function CustomersPage() {
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["customers", page, search],
    queryFn: () => customersApi.search({ page, size: 10, firstName: search || undefined }),
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Customers</h1>
        <p className="text-muted-foreground">Manage customer accounts</p>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search customers..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="space-y-4">{[...Array(5)].map((_, i) => <Skeleton key={i} className="h-24" />)}</div>
      ) : (
        <>
          <div className="space-y-4">
            {data?.data?.content?.map((customer: Customer) => (
              <Card key={customer.id} className="hover:shadow-md transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary font-semibold">
                      {customer.firstName?.[0]}{customer.lastName?.[0]}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <h3 className="font-semibold">{customer.fullName}</h3>
                        <Badge className={getStatusColor(customer.status)}>{customer.status}</Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">{customer.customerNumber}</p>
                    </div>
                    <div className="hidden md:flex flex-col gap-1 text-sm text-muted-foreground">
                      <div className="flex items-center gap-2"><Mail className="h-4 w-4" />{customer.email}</div>
                      <div className="flex items-center gap-2"><Phone className="h-4 w-4" />{customer.phone}</div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm text-muted-foreground">Joined</p>
                      <p className="font-medium">{formatDate(customer.createdAt)}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} customers
            </p>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0}>Previous</Button>
              <Button variant="outline" size="sm" onClick={() => setPage((p) => p + 1)} disabled={data?.data?.last}>Next</Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
EOF

# Orders page
cat > src/app/orders/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search, Package, Calendar } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import type { Order } from "@/types";

export default function OrdersPage() {
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["orders", page, search],
    queryFn: () => ordersApi.search({ page, size: 10, orderNumber: search || undefined, sortBy: "createdAt", sortDirection: "desc" }),
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Orders</h1>
        <p className="text-muted-foreground">Manage orders and payments</p>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search by order number..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="space-y-4">{[...Array(5)].map((_, i) => <Skeleton key={i} className="h-28" />)}</div>
      ) : (
        <>
          <div className="space-y-4">
            {data?.data?.content?.map((order: Order) => (
              <Card key={order.id} className="hover:shadow-md transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                        <Package className="h-6 w-6 text-primary" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="font-semibold">{order.orderNumber}</h3>
                          <Badge className={getStatusColor(order.status)}>{order.status.replace("_", " ")}</Badge>
                        </div>
                        <p className="text-sm text-muted-foreground">{order.customerName}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-6">
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Calendar className="h-4 w-4" />{formatDate(order.createdAt)}
                      </div>
                      <div className="text-lg font-semibold">{formatCurrency(order.totalAmount)}</div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} orders
            </p>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0}>Previous</Button>
              <Button variant="outline" size="sm" onClick={() => setPage((p) => p + 1)} disabled={data?.data?.last}>Next</Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
EOF

echo -e "${GREEN}✓ Pages created${NC}"