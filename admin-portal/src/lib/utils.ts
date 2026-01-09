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