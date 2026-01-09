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
