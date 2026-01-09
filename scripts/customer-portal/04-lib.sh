#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[4/8] Creating lib files...${NC}"

cd customer-portal
mkdir -p src/lib src/types src/store src/hooks

# =============================================================================
# UTILS
# =============================================================================
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

export function formatPhone(phone: string): string {
  const cleaned = phone.replace(/\D/g, "");
  const match = cleaned.match(/^(\d{3})(\d{3})(\d{4})$/);
  if (match) return `(${match[1]}) ${match[2]}-${match[3]}`;
  return phone;
}

export function getStatusColor(status: string): string {
  const colors: Record<string, string> = {
    ACTIVE: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
    PENDING: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
    COMPLETED: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
    CANCELLED: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
    DRAFT: "bg-slate-100 text-slate-800 dark:bg-slate-800 dark:text-slate-300",
  };
  return colors[status?.toUpperCase()] || "bg-slate-100 text-slate-800";
}

export function getMetalTierColor(tier: string): string {
  const colors: Record<string, string> = {
    BRONZE: "bg-amber-700 text-white",
    SILVER: "bg-slate-400 text-slate-900",
    GOLD: "bg-yellow-500 text-yellow-900",
    PLATINUM: "bg-slate-300 text-slate-900",
  };
  return colors[tier?.toUpperCase()] || "bg-slate-500 text-white";
}

export function getInitials(firstName: string, lastName: string): string {
  return `${firstName?.[0] || ""}${lastName?.[0] || ""}`.toUpperCase();
}

export function calculateAge(dateOfBirth: string): number {
  const today = new Date();
  const birth = new Date(dateOfBirth);
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  return age;
}
EOF
echo -e "${GREEN}✓${NC} utils.ts"

# =============================================================================
# API CLIENT
# =============================================================================
cat > src/lib/api.ts << 'EOF'
import axios from "axios";

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "",
  headers: { "Content-Type": "application/json" },
});

// Request interceptor - add auth token
api.interceptors.request.use((config) => {
  if (typeof window !== "undefined") {
    const token = localStorage.getItem("auth-token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
  }
  return config;
});

// Response interceptor - handle 401
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      if (typeof window !== "undefined") {
        localStorage.removeItem("auth-token");
        window.location.href = "/login";
      }
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authApi = {
  login: (data: { email: string; password: string }) => 
    api.post("/api/auth/login", data),
  signup: (data: any) => 
    api.post("/api/auth/signup", data),
  logout: () => 
    api.post("/api/auth/logout"),
  forgotPassword: (email: string) => 
    api.post("/api/auth/forgot-password", { email }),
  resetPassword: (data: { token: string; password: string }) => 
    api.post("/api/auth/reset-password", data),
  me: () => 
    api.get("/api/auth/me"),
};

// Plans API
export const plansApi = {
  search: (params: any) => api.post("/api/plans/search", params),
  getById: (id: string) => api.get(`/api/plans/${id}`),
  getByCode: (code: string) => api.get(`/api/plans/code/${code}`),
  compare: (ids: string[]) => api.post("/api/plans/compare", { planIds: ids }),
};

// Profiles API
export const profilesApi = {
  getAll: () => api.get("/api/profiles"),
  getById: (id: string) => api.get(`/api/profiles/${id}`),
  create: (data: any) => api.post("/api/profiles", data),
  update: (id: string, data: any) => api.put(`/api/profiles/${id}`, data),
  delete: (id: string) => api.delete(`/api/profiles/${id}`),
  setPrimary: (id: string) => api.post(`/api/profiles/${id}/set-primary`),
};

// Cart/Quotes API
export const quotesApi = {
  create: (data: any) => api.post("/api/quotes", data),
  getAll: () => api.get("/api/quotes"),
  getById: (id: string) => api.get(`/api/quotes/${id}`),
  addItem: (quoteId: string, item: any) => api.post(`/api/quotes/${quoteId}/items`, item),
  removeItem: (quoteId: string, itemId: string) => api.delete(`/api/quotes/${quoteId}/items/${itemId}`),
  convertToOrder: (quoteId: string) => api.post(`/api/quotes/${quoteId}/convert`),
};

// Orders API
export const ordersApi = {
  search: (params: any) => api.post("/api/orders/search", params),
  getById: (id: string) => api.get(`/api/orders/${id}`),
  create: (data: any) => api.post("/api/orders", data),
  cancel: (id: string, reason?: string) => api.post(`/api/orders/${id}/cancel`, { reason }),
  getMyOrders: () => api.get("/api/orders/my"),
};

// Payments API
export const paymentsApi = {
  process: (data: any) => api.post("/api/payments", data),
  getById: (id: string) => api.get(`/api/payments/${id}`),
  getSavedMethods: () => api.get("/api/payments/methods"),
  saveMethod: (data: any) => api.post("/api/payments/methods", data),
  deleteMethod: (id: string) => api.delete(`/api/payments/methods/${id}`),
};

export default api;
EOF
echo -e "${GREEN}✓${NC} api.ts"

# =============================================================================
# TYPES
# =============================================================================
cat > src/types/index.ts << 'EOF'
// Auth types
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
  createdAt: string;
}

export interface Profile {
  id: string;
  userId: string;
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: "MALE" | "FEMALE" | "OTHER";
  relationship: "SELF" | "SPOUSE" | "CHILD" | "PARENT" | "SIBLING" | "OTHER";
  ssn?: string;
  email?: string;
  phone?: string;
  address?: Address;
  isPrimary: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Address {
  street1: string;
  street2?: string;
  city: string;
  state: string;
  zipCode: string;
}

// Plan types
export interface Plan {
  id: string;
  planCode: string;
  planName: string;
  planType: string;
  metalTier: "BRONZE" | "SILVER" | "GOLD" | "PLATINUM";
  issuerName: string;
  state: string;
  monthlyPremium: number;
  annualDeductible: number;
  outOfPocketMax: number;
  copayPrimaryCare: number;
  copaySpecialist: number;
  copayEmergency: number;
  coinsurance: number;
  hsaEligible: boolean;
  hraEligible: boolean;
  networkType: string;
  description?: string;
  status: string;
  year: number;
}

// Cart types
export interface CartItem {
  id: string;
  planId: string;
  planCode: string;
  planName: string;
  metalTier: string;
  monthlyPremium: number;
  profileId: string;
  profileName: string;
  relationship: string;
}

export interface Quote {
  id: string;
  quoteNumber: string;
  status: "DRAFT" | "ACTIVE" | "EXPIRED" | "CONVERTED";
  items: CartItem[];
  subtotal: number;
  totalMonthly: number;
  totalAnnual: number;
  validUntil: string;
  createdAt: string;
}

// Order types
export interface Order {
  id: string;
  orderNumber: string;
  status: "DRAFT" | "PENDING_PAYMENT" | "CONFIRMED" | "PROCESSING" | "COMPLETED" | "CANCELLED";
  items: OrderItem[];
  subtotal: number;
  taxAmount: number;
  discountAmount: number;
  totalAmount: number;
  effectiveDate: string;
  createdAt: string;
}

export interface OrderItem {
  id: string;
  planId: string;
  planCode: string;
  planName: string;
  metalTier: string;
  profileId: string;
  profileName: string;
  unitPrice: number;
  totalPrice: number;
}

// Payment types
export interface PaymentMethod {
  id: string;
  type: "CREDIT_CARD" | "DEBIT_CARD" | "ACH" | "BANK_TRANSFER";
  cardBrand?: string;
  cardLast4?: string;
  bankName?: string;
  accountLast4?: string;
  isDefault: boolean;
  expiryMonth?: number;
  expiryYear?: number;
}

// Common types
export interface PagedResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}
EOF
echo -e "${GREEN}✓${NC} types/index.ts"

# =============================================================================
# AUTH STORE
# =============================================================================
cat > src/store/auth.ts << 'EOF'
import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { User, Profile } from "@/types";

export const MAX_PROFILES = parseInt(process.env.NEXT_PUBLIC_MAX_PROFILES || "500");

interface AuthState {
  user: User | null;
  token: string | null;
  profiles: Profile[];
  activeProfileId: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  
  // Actions
  setUser: (user: User | null) => void;
  setToken: (token: string | null) => void;
  setProfiles: (profiles: Profile[]) => void;
  addProfile: (profile: Profile) => void;
  updateProfile: (id: string, updates: Partial<Profile>) => void;
  removeProfile: (id: string) => void;
  setActiveProfile: (id: string | null) => void;
  getActiveProfile: () => Profile | null;
  getPrimaryProfile: () => Profile | null;
  canAddProfile: () => boolean;
  setLoading: (loading: boolean) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      profiles: [],
      activeProfileId: null,
      isAuthenticated: false,
      isLoading: true,

      setUser: (user) => set({ user, isAuthenticated: !!user }),
      
      setToken: (token) => {
        if (typeof window !== "undefined") {
          if (token) {
            localStorage.setItem("auth-token", token);
          } else {
            localStorage.removeItem("auth-token");
          }
        }
        set({ token });
      },
      
      setProfiles: (profiles) => set({ profiles }),
      
      addProfile: (profile) => {
        const { profiles } = get();
        if (profiles.length >= MAX_PROFILES) {
          throw new Error(`Maximum ${MAX_PROFILES} profiles allowed`);
        }
        set({ profiles: [...profiles, profile] });
      },
      
      updateProfile: (id, updates) => {
        set((state) => ({
          profiles: state.profiles.map((p) =>
            p.id === id ? { ...p, ...updates } : p
          ),
        }));
      },
      
      removeProfile: (id) => {
        const { profiles, activeProfileId } = get();
        const profile = profiles.find((p) => p.id === id);
        if (profile?.isPrimary) {
          throw new Error("Cannot delete primary profile");
        }
        set({
          profiles: profiles.filter((p) => p.id !== id),
          activeProfileId: activeProfileId === id ? null : activeProfileId,
        });
      },
      
      setActiveProfile: (id) => set({ activeProfileId: id }),
      
      getActiveProfile: () => {
        const { profiles, activeProfileId } = get();
        return profiles.find((p) => p.id === activeProfileId) || 
               profiles.find((p) => p.isPrimary) || 
               profiles[0] || 
               null;
      },
      
      getPrimaryProfile: () => {
        const { profiles } = get();
        return profiles.find((p) => p.isPrimary) || null;
      },
      
      canAddProfile: () => {
        const { profiles } = get();
        return profiles.length < MAX_PROFILES;
      },
      
      setLoading: (isLoading) => set({ isLoading }),
      
      logout: () => {
        if (typeof window !== "undefined") {
          localStorage.removeItem("auth-token");
        }
        set({
          user: null,
          token: null,
          profiles: [],
          activeProfileId: null,
          isAuthenticated: false,
        });
      },
    }),
    {
      name: "auth-storage",
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        profiles: state.profiles,
        activeProfileId: state.activeProfileId,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);
EOF
echo -e "${GREEN}✓${NC} store/auth.ts"

# =============================================================================
# CART STORE
# =============================================================================
cat > src/store/cart.ts << 'EOF'
import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { CartItem, Plan, Profile } from "@/types";

interface CartState {
  items: CartItem[];
  
  // Actions
  addItem: (plan: Plan, profile: Profile) => void;
  removeItem: (itemId: string) => void;
  updateItem: (itemId: string, updates: Partial<CartItem>) => void;
  clearCart: () => void;
  hasItem: (planId: string, profileId: string) => boolean;
  getItemsForProfile: (profileId: string) => CartItem[];
  getMonthlyTotal: () => number;
  getAnnualTotal: () => number;
  getItemCount: () => number;
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],

      addItem: (plan, profile) => {
        const { items, hasItem } = get();
        
        // Check if already in cart for this profile
        if (hasItem(plan.id, profile.id)) {
          return;
        }
        
        const newItem: CartItem = {
          id: `${plan.id}-${profile.id}`,
          planId: plan.id,
          planCode: plan.planCode,
          planName: plan.planName,
          metalTier: plan.metalTier,
          monthlyPremium: plan.monthlyPremium,
          profileId: profile.id,
          profileName: `${profile.firstName} ${profile.lastName}`,
          relationship: profile.relationship,
        };
        
        set({ items: [...items, newItem] });
      },

      removeItem: (itemId) => {
        set((state) => ({
          items: state.items.filter((item) => item.id !== itemId),
        }));
      },

      updateItem: (itemId, updates) => {
        set((state) => ({
          items: state.items.map((item) =>
            item.id === itemId ? { ...item, ...updates } : item
          ),
        }));
      },

      clearCart: () => set({ items: [] }),

      hasItem: (planId, profileId) => {
        const { items } = get();
        return items.some((item) => item.planId === planId && item.profileId === profileId);
      },

      getItemsForProfile: (profileId) => {
        const { items } = get();
        return items.filter((item) => item.profileId === profileId);
      },

      getMonthlyTotal: () => {
        const { items } = get();
        return items.reduce((sum, item) => sum + item.monthlyPremium, 0);
      },

      getAnnualTotal: () => {
        const { items } = get();
        return items.reduce((sum, item) => sum + item.monthlyPremium * 12, 0);
      },

      getItemCount: () => get().items.length,
    }),
    { name: "cart-storage" }
  )
);
EOF
echo -e "${GREEN}✓${NC} store/cart.ts"

# =============================================================================
# STORE INDEX
# =============================================================================
cat > src/store/index.ts << 'EOF'
export { useAuthStore, MAX_PROFILES } from "./auth";
export { useCartStore } from "./cart";
EOF
echo -e "${GREEN}✓${NC} store/index.ts"

# =============================================================================
# PROVIDERS
# =============================================================================
cat > src/lib/providers.tsx << 'EOF'
"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ThemeProvider } from "next-themes";
import { useState } from "react";
import { Toaster } from "sonner";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            refetchOnWindowFocus: false,
          },
        },
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class" defaultTheme="light" enableSystem>
        {children}
        <Toaster position="top-right" richColors />
      </ThemeProvider>
    </QueryClientProvider>
  );
}
EOF
echo -e "${GREEN}✓${NC} providers.tsx"

# =============================================================================
# AUTH HOOK
# =============================================================================
cat > src/hooks/useAuth.ts << 'EOF'
"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store";
import { authApi, profilesApi } from "@/lib/api";

export function useAuth(requireAuth = true) {
  const router = useRouter();
  const { user, token, isAuthenticated, isLoading, setUser, setToken, setProfiles, setLoading, logout } = useAuthStore();

  useEffect(() => {
    const initAuth = async () => {
      if (token && !user) {
        try {
          const [userRes, profilesRes] = await Promise.all([
            authApi.me(),
            profilesApi.getAll(),
          ]);
          setUser(userRes.data);
          setProfiles(profilesRes.data);
        } catch (error) {
          logout();
        }
      }
      setLoading(false);
    };

    initAuth();
  }, [token, user, setUser, setProfiles, setLoading, logout]);

  useEffect(() => {
    if (!isLoading && requireAuth && !isAuthenticated) {
      router.push("/login");
    }
  }, [isLoading, requireAuth, isAuthenticated, router]);

  const login = async (email: string, password: string) => {
    const response = await authApi.login({ email, password });
    const { token, user } = response.data;
    setToken(token);
    setUser(user);
    
    const profilesRes = await profilesApi.getAll();
    setProfiles(profilesRes.data);
    
    return response.data;
  };

  const signup = async (data: any) => {
    const response = await authApi.signup(data);
    const { token, user } = response.data;
    setToken(token);
    setUser(user);
    
    const profilesRes = await profilesApi.getAll();
    setProfiles(profilesRes.data);
    
    return response.data;
  };

  const handleLogout = async () => {
    try {
      await authApi.logout();
    } catch (error) {
      // Ignore logout errors
    }
    logout();
    router.push("/login");
  };

  return {
    user,
    isAuthenticated,
    isLoading,
    login,
    signup,
    logout: handleLogout,
  };
}
EOF
echo -e "${GREEN}✓${NC} hooks/useAuth.ts"

# =============================================================================
# HOOKS INDEX
# =============================================================================
cat > src/hooks/index.ts << 'EOF'
export { useAuth } from "./useAuth";
EOF
echo -e "${GREEN}✓${NC} hooks/index.ts"

echo -e "${GREEN}✓ Lib files created${NC}"