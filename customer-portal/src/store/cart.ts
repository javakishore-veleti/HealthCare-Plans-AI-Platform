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
