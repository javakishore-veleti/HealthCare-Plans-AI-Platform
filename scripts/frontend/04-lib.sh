#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[4/6] Creating lib files...${NC}"

cd frontend
mkdir -p src/lib src/types src/store src/hooks

# Utils
cat > src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatCurrency(amount: number): string {
  return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(amount);
}

export function formatDate(date: string | Date): string {
  return new Date(date).toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" });
}

export function getStatusColor(status: string): string {
  const colors: Record<string, string> = {
    ACTIVE: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
    PENDING: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
    COMPLETED: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
    CANCELLED: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
    DRAFT: "bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-300",
  };
  return colors[status?.toUpperCase()] || "bg-gray-100 text-gray-800";
}

export function getMetalTierColor(tier: string): string {
  const colors: Record<string, string> = {
    BRONZE: "bg-amber-700 text-white",
    SILVER: "bg-gray-400 text-gray-900",
    GOLD: "bg-yellow-500 text-yellow-900",
    PLATINUM: "bg-slate-300 text-slate-900",
  };
  return colors[tier?.toUpperCase()] || "bg-gray-500 text-white";
}
EOF

# API client
cat > src/lib/api.ts << 'EOF'
import axios from "axios";

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "",
  headers: { "Content-Type": "application/json" },
});

export const plansApi = {
  search: (params: any) => api.post("/api/plans/search", params),
  getById: (id: string) => api.get(`/api/plans/${id}`),
};

export const customersApi = {
  search: (params: any) => api.post("/api/customers/search", params),
  getById: (id: string) => api.get(`/api/customers/${id}`),
};

export const ordersApi = {
  search: (params: any) => api.post("/api/orders/search", params),
  getById: (id: string) => api.get(`/api/orders/${id}`),
  create: (data: any) => api.post("/api/orders", data),
};

export default api;
EOF

# Query provider
cat > src/lib/providers.tsx << 'EOF'
"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ThemeProvider } from "next-themes";
import { useState } from "react";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient({
    defaultOptions: { queries: { staleTime: 60 * 1000, refetchOnWindowFocus: false } },
  }));

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
}
EOF

# Types
cat > src/types/index.ts << 'EOF'
export interface PagedResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}

export interface Plan {
  id: string;
  planCode: string;
  planName: string;
  metalTier: "BRONZE" | "SILVER" | "GOLD" | "PLATINUM";
  issuerName: string;
  monthlyPremium: number;
  annualDeductible: number;
  outOfPocketMax: number;
  status: string;
}

export interface Customer {
  id: string;
  customerNumber: string;
  firstName: string;
  lastName: string;
  fullName: string;
  email: string;
  phone: string;
  status: string;
  createdAt: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customerName: string;
  status: string;
  totalAmount: number;
  createdAt: string;
}
EOF

# Store
cat > src/store/index.ts << 'EOF'
import { create } from "zustand";
import { persist } from "zustand/middleware";

interface AppState {
  sidebarOpen: boolean;
  toggleSidebar: () => void;
}

export const useAppStore = create<AppState>()(
  persist(
    (set) => ({
      sidebarOpen: true,
      toggleSidebar: () => set((state) => ({ sidebarOpen: !state.sidebarOpen })),
    }),
    { name: "app-storage" }
  )
);
EOF

echo -e "${GREEN}✓ Lib files created${NC}"