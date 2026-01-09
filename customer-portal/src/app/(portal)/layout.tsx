"use client";

import { useAuth } from "@/hooks";
import { Header } from "@/components/layout/header";
import { Footer } from "@/components/layout/footer";
import { Skeleton } from "@/components/ui/skeleton";

export default function PortalLayout({ children }: { children: React.ReactNode }) {
  const { isLoading, isAuthenticated } = useAuth(true);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="space-y-4 w-full max-w-md">
          <Skeleton className="h-12 w-full" />
          <Skeleton className="h-32 w-full" />
          <Skeleton className="h-8 w-3/4" />
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null; // useAuth will redirect to login
  }

  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-1">{children}</main>
      <Footer />
    </div>
  );
}
