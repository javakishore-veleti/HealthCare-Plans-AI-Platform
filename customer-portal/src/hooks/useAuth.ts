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
