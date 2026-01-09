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
