#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[7/8] Creating portal pages...${NC}"

cd customer-portal

# Create portal route group directories
mkdir -p "src/app/(portal)/dashboard"
mkdir -p "src/app/(portal)/shop"
mkdir -p "src/app/(portal)/cart"
mkdir -p "src/app/(portal)/profiles/new"
mkdir -p "src/app/(portal)/profiles/[id]"
mkdir -p "src/app/(portal)/orders/[id]"
mkdir -p "src/app/(portal)/quotes"

# =============================================================================
# PORTAL LAYOUT
# =============================================================================
cat > "src/app/(portal)/layout.tsx" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} portal layout"

# =============================================================================
# DASHBOARD PAGE
# =============================================================================
cat > "src/app/(portal)/dashboard/page.tsx" << 'EOF'
"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ShoppingBag, FileText, Users, CreditCard, ArrowRight, Plus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuthStore } from "@/store";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor, getInitials } from "@/lib/utils";

export default function DashboardPage() {
  const { user, profiles, getActiveProfile } = useAuthStore();
  const activeProfile = getActiveProfile();

  const { data: ordersData, isLoading: ordersLoading } = useQuery({
    queryKey: ["my-orders"],
    queryFn: () => ordersApi.getMyOrders(),
  });

  const recentOrders = ordersData?.data?.slice(0, 3) || [];

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Welcome Section */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900 dark:text-white">
          Welcome back, {user?.firstName}!
        </h1>
        <p className="text-slate-500 mt-1">
          Manage your healthcare plans and profiles from your dashboard.
        </p>
      </div>

      {/* Quick Stats */}
      <div className="grid gap-4 md:grid-cols-4 mb-8">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{profiles.length}</p>
                <p className="text-sm text-slate-500">Profiles</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-green-100">
                <FileText className="h-6 w-6 text-green-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{recentOrders.length}</p>
                <p className="text-sm text-slate-500">Orders</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100">
                <ShoppingBag className="h-6 w-6 text-purple-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">0</p>
                <p className="text-sm text-slate-500">Active Plans</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-orange-100">
                <CreditCard className="h-6 w-6 text-orange-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">$0</p>
                <p className="text-sm text-slate-500">Monthly Cost</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-8 lg:grid-cols-3">
        {/* Profiles Section */}
        <div className="lg:col-span-1">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>My Profiles</CardTitle>
                <Link href="/profiles/new">
                  <Button size="sm" variant="outline" className="gap-1">
                    <Plus className="h-4 w-4" />
                    Add
                  </Button>
                </Link>
              </div>
              <CardDescription>Manage profiles for yourself and family</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {profiles.slice(0, 5).map((profile) => (
                  <Link
                    key={profile.id}
                    href={`/profiles/${profile.id}`}
                    className="flex items-center gap-3 p-3 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"
                  >
                    <Avatar>
                      <AvatarFallback>
                        {getInitials(profile.firstName, profile.lastName)}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium truncate">
                        {profile.firstName} {profile.lastName}
                      </p>
                      <p className="text-sm text-slate-500">{profile.relationship}</p>
                    </div>
                    {profile.isPrimary && (
                      <Badge variant="secondary">Primary</Badge>
                    )}
                  </Link>
                ))}
              </div>
              {profiles.length > 5 && (
                <Link href="/profiles" className="block mt-4">
                  <Button variant="ghost" className="w-full gap-2">
                    View All Profiles
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Recent Orders */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Recent Orders</CardTitle>
                <Link href="/orders">
                  <Button size="sm" variant="outline" className="gap-1">
                    View All
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
              </div>
              <CardDescription>Your latest healthcare plan orders</CardDescription>
            </CardHeader>
            <CardContent>
              {ordersLoading ? (
                <div className="space-y-4">
                  {[...Array(3)].map((_, i) => (
                    <Skeleton key={i} className="h-20 w-full" />
                  ))}
                </div>
              ) : recentOrders.length > 0 ? (
                <div className="space-y-4">
                  {recentOrders.map((order: any) => (
                    <Link
                      key={order.id}
                      href={`/orders/${order.id}`}
                      className="flex items-center justify-between p-4 rounded-lg border border-slate-200 hover:border-slate-300 hover:shadow-sm transition-all dark:border-slate-800"
                    >
                      <div>
                        <p className="font-medium">{order.orderNumber}</p>
                        <p className="text-sm text-slate-500">{formatDate(order.createdAt)}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">{formatCurrency(order.totalAmount)}</p>
                        <Badge className={getStatusColor(order.status)}>
                          {order.status.replace("_", " ")}
                        </Badge>
                      </div>
                    </Link>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <ShoppingBag className="h-12 w-12 text-slate-300 mx-auto mb-4" />
                  <p className="text-slate-500 mb-4">No orders yet</p>
                  <Link href="/shop">
                    <Button>Browse Plans</Button>
                  </Link>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="mt-8">
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid gap-4 md:grid-cols-3">
          <Link href="/shop">
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-600">
                    <ShoppingBag className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-medium">Browse Plans</p>
                    <p className="text-sm text-slate-500">Find the perfect coverage</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>

          <Link href="/profiles/new">
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-600">
                    <Plus className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-medium">Add Profile</p>
                    <p className="text-sm text-slate-500">Cover family members</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>

          <Link href="/quotes">
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-purple-600">
                    <FileText className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-medium">View Quotes</p>
                    <p className="text-sm text-slate-500">Check saved quotes</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>
        </div>
      </div>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} dashboard page"

# =============================================================================
# SHOP PAGE
# =============================================================================
cat > "src/app/(portal)/shop/page.tsx" << 'EOF'
"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search, Filter, ShoppingCart, Check, Info } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { plansApi } from "@/lib/api";
import { useAuthStore, useCartStore } from "@/store";
import { formatCurrency, getMetalTierColor, cn } from "@/lib/utils";
import { toast } from "sonner";
import type { Plan, Profile } from "@/types";

export default function ShopPage() {
  const [search, setSearch] = useState("");
  const [metalTier, setMetalTier] = useState<string>("ALL");
  const [page, setPage] = useState(0);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [showProfileDialog, setShowProfileDialog] = useState(false);

  const { profiles, getActiveProfile } = useAuthStore();
  const { addItem, hasItem } = useCartStore();
  const activeProfile = getActiveProfile();

  const { data, isLoading } = useQuery({
    queryKey: ["plans", page, search, metalTier],
    queryFn: () => plansApi.search({
      page,
      size: 12,
      planName: search || undefined,
      metalTier: metalTier !== "ALL" ? metalTier : undefined,
    }),
  });

  const handleAddToCart = (plan: Plan) => {
    setSelectedPlan(plan);
    setShowProfileDialog(true);
  };

  const confirmAddToCart = (profile: Profile) => {
    if (selectedPlan) {
      if (hasItem(selectedPlan.id, profile.id)) {
        toast.error(`${profile.firstName} already has this plan in cart`);
      } else {
        addItem(selectedPlan, profile);
        toast.success(`Added ${selectedPlan.planName} for ${profile.firstName}`);
      }
    }
    setShowProfileDialog(false);
    setSelectedPlan(null);
  };

  const tiers = ["ALL", "BRONZE", "SILVER", "GOLD", "PLATINUM"];

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900 dark:text-white">Browse Healthcare Plans</h1>
        <p className="text-slate-500 mt-1">Find the perfect coverage for you and your family</p>
      </div>

      {/* Filters */}
      <Card className="mb-8">
        <CardContent className="pt-6">
          <div className="flex flex-col gap-4 md:flex-row md:items-center">
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
              <Input
                placeholder="Search plans..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-10"
              />
            </div>

            <div className="flex gap-2 flex-wrap">
              {tiers.map((tier) => (
                <Button
                  key={tier}
                  variant={metalTier === tier ? "default" : "outline"}
                  size="sm"
                  onClick={() => setMetalTier(tier)}
                  className={cn(
                    metalTier === tier && tier !== "ALL" && getMetalTierColor(tier)
                  )}
                >
                  {tier === "ALL" ? "All Tiers" : tier}
                </Button>
              ))}
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Plans Grid */}
      {isLoading ? (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(6)].map((_, i) => (
            <Skeleton key={i} className="h-80" />
          ))}
        </div>
      ) : (
        <>
          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {data?.data?.content?.map((plan: Plan) => (
              <Card key={plan.id} className="flex flex-col hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <Badge className={cn("mb-2", getMetalTierColor(plan.metalTier))}>
                        {plan.metalTier}
                      </Badge>
                      <CardTitle className="text-lg leading-tight">{plan.planName}</CardTitle>
                      <CardDescription className="mt-1">{plan.issuerName}</CardDescription>
                    </div>
                  </div>
                </CardHeader>
                <CardContent className="flex-1 flex flex-col">
                  <div className="mb-4">
                    <p className="text-3xl font-bold text-blue-600">
                      {formatCurrency(plan.monthlyPremium)}
                      <span className="text-sm font-normal text-slate-500">/mo</span>
                    </p>
                  </div>

                  <div className="space-y-2 text-sm flex-1">
                    <div className="flex justify-between">
                      <span className="text-slate-500">Deductible</span>
                      <span className="font-medium">{formatCurrency(plan.annualDeductible)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-500">Out of Pocket Max</span>
                      <span className="font-medium">{formatCurrency(plan.outOfPocketMax)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-slate-500">Primary Care</span>
                      <span className="font-medium">{formatCurrency(plan.copayPrimaryCare)}</span>
                    </div>
                  </div>

                  <div className="flex gap-2 mt-4 pt-4 border-t">
                    <Button variant="outline" className="flex-1 gap-1" size="sm">
                      <Info className="h-4 w-4" />
                      Details
                    </Button>
                    <Button className="flex-1 gap-1" size="sm" onClick={() => handleAddToCart(plan)}>
                      <ShoppingCart className="h-4 w-4" />
                      Add
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Pagination */}
          <div className="flex items-center justify-between mt-8">
            <p className="text-sm text-slate-500">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} plans
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => Math.max(0, p - 1))}
                disabled={page === 0}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setPage((p) => p + 1)}
                disabled={data?.data?.last}
              >
                Next
              </Button>
            </div>
          </div>
        </>
      )}

      {/* Profile Selection Dialog */}
      <Dialog open={showProfileDialog} onOpenChange={setShowProfileDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Select Profile</DialogTitle>
            <DialogDescription>
              Choose who this plan is for
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-2 py-4">
            {profiles.map((profile) => {
              const alreadyInCart = selectedPlan ? hasItem(selectedPlan.id, profile.id) : false;
              return (
                <button
                  key={profile.id}
                  onClick={() => !alreadyInCart && confirmAddToCart(profile)}
                  disabled={alreadyInCart}
                  className={cn(
                    "w-full flex items-center gap-3 p-3 rounded-lg border transition-colors text-left",
                    alreadyInCart
                      ? "bg-slate-50 border-slate-200 cursor-not-allowed opacity-60"
                      : "border-slate-200 hover:border-blue-500 hover:bg-blue-50"
                  )}
                >
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-blue-600 font-medium">
                    {profile.firstName[0]}{profile.lastName[0]}
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">{profile.firstName} {profile.lastName}</p>
                    <p className="text-sm text-slate-500">{profile.relationship}</p>
                  </div>
                  {alreadyInCart && (
                    <Badge variant="secondary">
                      <Check className="h-3 w-3 mr-1" />
                      In Cart
                    </Badge>
                  )}
                </button>
              );
            })}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowProfileDialog(false)}>
              Cancel
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} shop page"

# =============================================================================
# CART PAGE
# =============================================================================
cat > "src/app/(portal)/cart/page.tsx" << 'EOF'
"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Trash2, ShoppingBag, ArrowRight, CreditCard } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useCartStore, useAuthStore } from "@/store";
import { ordersApi } from "@/lib/api";
import { formatCurrency, getMetalTierColor } from "@/lib/utils";
import { toast } from "sonner";

export default function CartPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);
  const { items, removeItem, clearCart, getMonthlyTotal, getAnnualTotal } = useCartStore();
  const { profiles } = useAuthStore();

  const monthlyTotal = getMonthlyTotal();
  const annualTotal = getAnnualTotal();

  const handleCheckout = async () => {
    if (items.length === 0) {
      toast.error("Your cart is empty");
      return;
    }

    setIsLoading(true);
    try {
      const orderData = {
        orderType: "NEW_ENROLLMENT",
        effectiveDate: new Date(new Date().setMonth(new Date().getMonth() + 1)).toISOString().split("T")[0],
        billingFrequency: "MONTHLY",
        items: items.map((item) => ({
          planId: item.planId,
          profileId: item.profileId,
          quantity: 1,
        })),
      };

      const response = await ordersApi.create(orderData);
      clearCart();
      toast.success("Order created successfully!");
      router.push(`/orders/${response.data.id}`);
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to create order");
    } finally {
      setIsLoading(false);
    }
  };

  if (items.length === 0) {
    return (
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-md mx-auto text-center">
          <div className="flex justify-center mb-6">
            <div className="flex h-20 w-20 items-center justify-center rounded-full bg-slate-100">
              <ShoppingBag className="h-10 w-10 text-slate-400" />
            </div>
          </div>
          <h1 className="text-2xl font-bold mb-2">Your cart is empty</h1>
          <p className="text-slate-500 mb-6">
            Browse our healthcare plans and add coverage for you and your family.
          </p>
          <Link href="/shop">
            <Button size="lg" className="gap-2">
              Browse Plans
              <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
        </div>
      </div>
    );
  }

  // Group items by profile
  const itemsByProfile = items.reduce((acc, item) => {
    if (!acc[item.profileId]) {
      acc[item.profileId] = [];
    }
    acc[item.profileId].push(item);
    return acc;
  }, {} as Record<string, typeof items>);

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-8">Shopping Cart</h1>

      <div className="grid gap-8 lg:grid-cols-3">
        {/* Cart Items */}
        <div className="lg:col-span-2 space-y-6">
          {Object.entries(itemsByProfile).map(([profileId, profileItems]) => {
            const profile = profiles.find((p) => p.id === profileId);
            const profileTotal = profileItems.reduce((sum, item) => sum + item.monthlyPremium, 0);

            return (
              <Card key={profileId}>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div>
                      <CardTitle className="text-lg">
                        {profile?.firstName} {profile?.lastName}
                      </CardTitle>
                      <CardDescription>{profile?.relationship}</CardDescription>
                    </div>
                    <p className="font-semibold">{formatCurrency(profileTotal)}/mo</p>
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {profileItems.map((item) => (
                      <div
                        key={item.id}
                        className="flex items-center justify-between p-4 rounded-lg bg-slate-50 dark:bg-slate-800"
                      >
                        <div className="flex items-center gap-4">
                          <Badge className={getMetalTierColor(item.metalTier)}>
                            {item.metalTier}
                          </Badge>
                          <div>
                            <p className="font-medium">{item.planName}</p>
                            <p className="text-sm text-slate-500">{item.planCode}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-4">
                          <p className="font-semibold">{formatCurrency(item.monthlyPremium)}/mo</p>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="text-red-500 hover:text-red-700 hover:bg-red-50"
                            onClick={() => removeItem(item.id)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            );
          })}

          <div className="flex justify-between items-center pt-4">
            <Link href="/shop">
              <Button variant="outline">Continue Shopping</Button>
            </Link>
            <Button variant="ghost" className="text-red-500" onClick={clearCart}>
              Clear Cart
            </Button>
          </div>
        </div>

        {/* Order Summary */}
        <div className="lg:col-span-1">
          <Card className="sticky top-24">
            <CardHeader>
              <CardTitle>Order Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-500">Plans ({items.length})</span>
                  <span>{formatCurrency(monthlyTotal)}/mo</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Annual Cost</span>
                  <span>{formatCurrency(annualTotal)}/yr</span>
                </div>
              </div>

              <div className="border-t pt-4">
                <div className="flex justify-between text-lg font-semibold">
                  <span>Monthly Total</span>
                  <span className="text-blue-600">{formatCurrency(monthlyTotal)}</span>
                </div>
              </div>

              <Button
                className="w-full gap-2"
                size="lg"
                onClick={handleCheckout}
                loading={isLoading}
              >
                <CreditCard className="h-4 w-4" />
                Proceed to Checkout
              </Button>

              <p className="text-xs text-slate-500 text-center">
                By proceeding, you agree to our Terms of Service
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} cart page"

# =============================================================================
# PROFILES LIST PAGE
# =============================================================================
cat > "src/app/(portal)/profiles/page.tsx" << 'EOF'
"use client";

import Link from "next/link";
import { Plus, User, Edit, Trash2, Star } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuthStore, MAX_PROFILES } from "@/store";
import { formatDate, getInitials, calculateAge } from "@/lib/utils";

export default function ProfilesPage() {
  const { profiles, canAddProfile } = useAuthStore();

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 dark:text-white">My Profiles</h1>
          <p className="text-slate-500 mt-1">
            Manage profiles for yourself and family members ({profiles.length}/{MAX_PROFILES})
          </p>
        </div>
        {canAddProfile() && (
          <Link href="/profiles/new">
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Add Profile
            </Button>
          </Link>
        )}
      </div>

      {/* Profiles Grid */}
      {profiles.length === 0 ? (
        <Card>
          <CardContent className="py-16 text-center">
            <div className="flex justify-center mb-6">
              <div className="flex h-20 w-20 items-center justify-center rounded-full bg-slate-100">
                <User className="h-10 w-10 text-slate-400" />
              </div>
            </div>
            <h2 className="text-xl font-semibold mb-2">No profiles yet</h2>
            <p className="text-slate-500 mb-6">
              Create your first profile to start shopping for healthcare plans.
            </p>
            <Link href="/profiles/new">
              <Button>Create Profile</Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {profiles.map((profile) => (
            <Card key={profile.id} className="hover:shadow-md transition-shadow">
              <CardContent className="pt-6">
                <div className="flex items-start gap-4">
                  <Avatar className="h-14 w-14">
                    <AvatarFallback className="text-lg">
                      {getInitials(profile.firstName, profile.lastName)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold truncate">
                        {profile.firstName} {profile.lastName}
                      </h3>
                      {profile.isPrimary && (
                        <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
                      )}
                    </div>
                    <p className="text-sm text-slate-500">{profile.relationship}</p>
                    <div className="flex gap-2 mt-2">
                      <Badge variant="secondary">
                        {calculateAge(profile.dateOfBirth)} years old
                      </Badge>
                      <Badge variant="outline">{profile.gender}</Badge>
                    </div>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t flex gap-2">
                  <Link href={`/profiles/${profile.id}`} className="flex-1">
                    <Button variant="outline" className="w-full gap-1" size="sm">
                      <Edit className="h-4 w-4" />
                      Edit
                    </Button>
                  </Link>
                  {!profile.isPrimary && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-red-500 hover:text-red-700 hover:bg-red-50"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} profiles list page"

# =============================================================================
# NEW PROFILE PAGE
# =============================================================================
cat > "src/app/(portal)/profiles/new/page.tsx" << 'EOF'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ArrowLeft } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useAuthStore, MAX_PROFILES } from "@/store";
import { profilesApi } from "@/lib/api";
import { toast } from "sonner";

const profileSchema = z.object({
  firstName: z.string().min(2, "First name must be at least 2 characters"),
  lastName: z.string().min(2, "Last name must be at least 2 characters"),
  dateOfBirth: z.string().min(1, "Date of birth is required"),
  gender: z.enum(["MALE", "FEMALE", "OTHER"], { required_error: "Gender is required" }),
  relationship: z.enum(["SELF", "SPOUSE", "CHILD", "PARENT", "SIBLING", "OTHER"], { required_error: "Relationship is required" }),
  email: z.string().email().optional().or(z.literal("")),
  phone: z.string().optional(),
  street1: z.string().optional(),
  street2: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  zipCode: z.string().optional(),
});

type ProfileForm = z.infer<typeof profileSchema>;

export default function NewProfilePage() {
  const router = useRouter();
  const { profiles, addProfile, canAddProfile } = useAuthStore();
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, formState: { errors }, setValue, watch } = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
  });

  if (!canAddProfile()) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h1 className="text-2xl font-bold mb-4">Maximum Profiles Reached</h1>
        <p className="text-slate-500 mb-6">
          You have reached the maximum of {MAX_PROFILES} profiles.
        </p>
        <Link href="/profiles">
          <Button>Back to Profiles</Button>
        </Link>
      </div>
    );
  }

  const onSubmit = async (data: ProfileForm) => {
    setIsLoading(true);
    try {
      const profileData = {
        ...data,
        isPrimary: profiles.length === 0,
        address: data.street1 ? {
          street1: data.street1,
          street2: data.street2,
          city: data.city,
          state: data.state,
          zipCode: data.zipCode,
        } : undefined,
      };

      const response = await profilesApi.create(profileData);
      addProfile(response.data);
      toast.success("Profile created successfully!");
      router.push("/profiles");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to create profile");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl">
      <Link href="/profiles" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-6">
        <ArrowLeft className="h-4 w-4" />
        Back to Profiles
      </Link>

      <Card>
        <CardHeader>
          <CardTitle>Create New Profile</CardTitle>
          <CardDescription>
            Add a family member or dependent to shop for healthcare plans.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            {/* Basic Info */}
            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="firstName" error={!!errors.firstName}>First Name *</Label>
                <Input id="firstName" error={!!errors.firstName} {...register("firstName")} />
                {errors.firstName && <p className="text-xs text-red-500">{errors.firstName.message}</p>}
              </div>
              <div className="space-y-2">
                <Label htmlFor="lastName" error={!!errors.lastName}>Last Name *</Label>
                <Input id="lastName" error={!!errors.lastName} {...register("lastName")} />
                {errors.lastName && <p className="text-xs text-red-500">{errors.lastName.message}</p>}
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-3">
              <div className="space-y-2">
                <Label htmlFor="dateOfBirth" error={!!errors.dateOfBirth}>Date of Birth *</Label>
                <Input id="dateOfBirth" type="date" error={!!errors.dateOfBirth} {...register("dateOfBirth")} />
                {errors.dateOfBirth && <p className="text-xs text-red-500">{errors.dateOfBirth.message}</p>}
              </div>
              <div className="space-y-2">
                <Label error={!!errors.gender}>Gender *</Label>
                <Select onValueChange={(value) => setValue("gender", value as any)}>
                  <SelectTrigger error={!!errors.gender}>
                    <SelectValue placeholder="Select gender" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="MALE">Male</SelectItem>
                    <SelectItem value="FEMALE">Female</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
                {errors.gender && <p className="text-xs text-red-500">{errors.gender.message}</p>}
              </div>
              <div className="space-y-2">
                <Label error={!!errors.relationship}>Relationship *</Label>
                <Select onValueChange={(value) => setValue("relationship", value as any)}>
                  <SelectTrigger error={!!errors.relationship}>
                    <SelectValue placeholder="Select relationship" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="SELF">Self</SelectItem>
                    <SelectItem value="SPOUSE">Spouse</SelectItem>
                    <SelectItem value="CHILD">Child</SelectItem>
                    <SelectItem value="PARENT">Parent</SelectItem>
                    <SelectItem value="SIBLING">Sibling</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
                {errors.relationship && <p className="text-xs text-red-500">{errors.relationship.message}</p>}
              </div>
            </div>

            {/* Contact Info */}
            <div className="border-t pt-6">
              <h3 className="font-medium mb-4">Contact Information (Optional)</h3>
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" type="email" {...register("email")} />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone</Label>
                  <Input id="phone" type="tel" {...register("phone")} />
                </div>
              </div>
            </div>

            {/* Address */}
            <div className="border-t pt-6">
              <h3 className="font-medium mb-4">Address (Optional)</h3>
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="street1">Street Address</Label>
                  <Input id="street1" {...register("street1")} />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="street2">Apt, Suite, etc.</Label>
                  <Input id="street2" {...register("street2")} />
                </div>
                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2">
                    <Label htmlFor="city">City</Label>
                    <Input id="city" {...register("city")} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="state">State</Label>
                    <Input id="state" {...register("state")} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="zipCode">ZIP Code</Label>
                    <Input id="zipCode" {...register("zipCode")} />
                  </div>
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-4 pt-4">
              <Button type="submit" loading={isLoading}>
                Create Profile
              </Button>
              <Link href="/profiles">
                <Button type="button" variant="outline">Cancel</Button>
              </Link>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} new profile page"

# =============================================================================
# ORDERS LIST PAGE
# =============================================================================
cat > "src/app/(portal)/orders/page.tsx" << 'EOF'
"use client";

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { Package, Calendar, ArrowRight } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";

export default function OrdersPage() {
  const { data, isLoading } = useQuery({
    queryKey: ["my-orders"],
    queryFn: () => ordersApi.getMyOrders(),
  });

  const orders = data?.data || [];

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">My Orders</h1>
        <p className="text-slate-500 mt-1">View and manage your healthcare plan orders</p>
      </div>

      {isLoading ? (
        <div className="space-y-4">
          {[...Array(3)].map((_, i) => (
            <Skeleton key={i} className="h-32" />
          ))}
        </div>
      ) : orders.length === 0 ? (
        <Card>
          <CardContent className="py-16 text-center">
            <Package className="h-12 w-12 text-slate-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold mb-2">No orders yet</h2>
            <p className="text-slate-500 mb-6">
              Start shopping for healthcare plans to see your orders here.
            </p>
            <Link href="/shop">
              <Button>Browse Plans</Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {orders.map((order: any) => (
            <Link key={order.id} href={`/orders/${order.id}`}>
              <Card className="hover:shadow-md transition-shadow cursor-pointer">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                        <Package className="h-6 w-6 text-blue-600" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="font-semibold">{order.orderNumber}</h3>
                          <Badge className={getStatusColor(order.status)}>
                            {order.status.replace("_", " ")}
                          </Badge>
                        </div>
                        <div className="flex items-center gap-2 text-sm text-slate-500 mt-1">
                          <Calendar className="h-4 w-4" />
                          {formatDate(order.createdAt)}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <div className="text-right">
                        <p className="font-semibold">{formatCurrency(order.totalAmount)}</p>
                        <p className="text-sm text-slate-500">{order.items?.length || 0} items</p>
                      </div>
                      <ArrowRight className="h-5 w-5 text-slate-400" />
                    </div>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} orders page"

# =============================================================================
# QUOTES PAGE
# =============================================================================
cat > "src/app/(portal)/quotes/page.tsx" << 'EOF'
"use client";

import Link from "next/link";
import { FileText, ArrowRight } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function QuotesPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">My Quotes</h1>
        <p className="text-slate-500 mt-1">View and manage your saved quotes</p>
      </div>

      <Card>
        <CardContent className="py-16 text-center">
          <FileText className="h-12 w-12 text-slate-300 mx-auto mb-4" />
          <h2 className="text-xl font-semibold mb-2">No saved quotes</h2>
          <p className="text-slate-500 mb-6">
            Add plans to your cart and save them as quotes to view later.
          </p>
          <Link href="/shop">
            <Button>Browse Plans</Button>
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} quotes page"

echo -e "${GREEN}✓ Portal pages created${NC}"