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
  compare: (ids: string[]) => api.post("/api/plans/bulk", ids).then(res => ({ data: { plans: res.data } })),
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
