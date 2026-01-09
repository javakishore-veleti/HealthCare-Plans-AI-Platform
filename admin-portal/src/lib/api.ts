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
