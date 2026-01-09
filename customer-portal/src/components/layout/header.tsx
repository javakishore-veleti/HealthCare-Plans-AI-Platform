"use client";

import Link from "next/link";
import { ShoppingCart, Heart, User, LogOut, Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { ProfileSelector } from "./profile-selector";
import { useAuthStore, useCartStore } from "@/store";
import { useAuth } from "@/hooks";
import { getInitials } from "@/lib/utils";
import { useState } from "react";

export function Header() {
  const [menuOpen, setMenuOpen] = useState(false);
  const { user, isAuthenticated } = useAuthStore();
  const { getItemCount } = useCartStore();
  const { logout } = useAuth(false);
  const cartCount = getItemCount();

  return (
    <header className="sticky top-0 z-50 border-b border-slate-200 bg-white/95 backdrop-blur dark:border-slate-800 dark:bg-slate-900/95">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
            <Heart className="h-5 w-5 text-white" />
          </div>
          <span className="text-xl font-bold text-slate-900 dark:text-white">Your Care</span>
        </Link>

        {/* Navigation - Desktop */}
        <nav className="hidden md:flex items-center gap-6">
          <Link href="/shop" className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white">
            Browse Plans
          </Link>
          {isAuthenticated && (
            <>
              <Link href="/orders" className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white">
                My Orders
              </Link>
              <Link href="/quotes" className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white">
                My Quotes
              </Link>
            </>
          )}
        </nav>

        {/* Actions */}
        <div className="flex items-center gap-3">
          {isAuthenticated ? (
            <>
              {/* Profile Selector */}
              <div className="hidden md:block">
                <ProfileSelector />
              </div>

              {/* Cart */}
              <Link href="/cart">
                <Button variant="ghost" size="icon" className="relative">
                  <ShoppingCart className="h-5 w-5" />
                  {cartCount > 0 && (
                    <Badge className="absolute -right-1 -top-1 h-5 w-5 rounded-full p-0 flex items-center justify-center text-xs">
                      {cartCount}
                    </Badge>
                  )}
                </Button>
              </Link>

              {/* User Menu */}
              <div className="relative">
                <button
                  onClick={() => setMenuOpen(!menuOpen)}
                  className="flex items-center gap-2"
                >
                  <Avatar className="h-9 w-9">
                    <AvatarFallback>
                      {user ? getInitials(user.firstName, user.lastName) : "U"}
                    </AvatarFallback>
                  </Avatar>
                </button>

                {menuOpen && (
                  <>
                    <div className="fixed inset-0 z-40" onClick={() => setMenuOpen(false)} />
                    <div className="absolute right-0 top-full z-50 mt-2 w-56 rounded-xl border border-slate-200 bg-white py-2 shadow-lg dark:border-slate-800 dark:bg-slate-900">
                      <div className="px-4 py-2 border-b border-slate-200 dark:border-slate-800">
                        <p className="font-medium">{user?.firstName} {user?.lastName}</p>
                        <p className="text-sm text-slate-500">{user?.email}</p>
                      </div>
                      <Link href="/dashboard" className="flex items-center gap-2 px-4 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-800" onClick={() => setMenuOpen(false)}>
                        <User className="h-4 w-4" />
                        Dashboard
                      </Link>
                      <Link href="/profiles" className="flex items-center gap-2 px-4 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-800" onClick={() => setMenuOpen(false)}>
                        <User className="h-4 w-4" />
                        Manage Profiles
                      </Link>
                      <button onClick={() => { logout(); setMenuOpen(false); }} className="flex w-full items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-slate-100 dark:hover:bg-slate-800">
                        <LogOut className="h-4 w-4" />
                        Sign Out
                      </button>
                    </div>
                  </>
                )}
              </div>
            </>
          ) : (
            <>
              <Link href="/login">
                <Button variant="ghost">Sign In</Button>
              </Link>
              <Link href="/signup">
                <Button>Get Started</Button>
              </Link>
            </>
          )}

          {/* Mobile Menu */}
          <Button variant="ghost" size="icon" className="md:hidden">
            <Menu className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
