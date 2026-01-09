"use client";

import { useState, useEffect } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ArrowLeft, X, Check, Minus, Plus, ShoppingCart } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { plansApi } from "@/lib/api";
import { useAuthStore, useCartStore } from "@/store";
import { formatCurrency, getMetalTierColor, cn } from "@/lib/utils";
import { toast } from "sonner";
import type { Plan, Profile } from "@/types";

export default function ComparePage() {
  const searchParams = useSearchParams();
  const planIds = searchParams.get("ids")?.split(",") || [];
  
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [showProfileDialog, setShowProfileDialog] = useState(false);
  
  const { profiles } = useAuthStore();
  const { addItem, hasItem } = useCartStore();

  const { data, isLoading } = useQuery({
    queryKey: ["compare-plans", planIds],
    queryFn: async () => {
      if (planIds.length === 0) return { plans: [] };
      const response = await plansApi.compare(planIds);
      return response.data;
    },
    enabled: planIds.length > 0,
  });

  const plans: Plan[] = data?.plans || [];

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

  const comparisonRows = [
    { label: "Monthly Premium", key: "monthlyPremium", format: "currency" },
    { label: "Annual Deductible", key: "annualDeductible", format: "currency" },
    { label: "Out of Pocket Max", key: "outOfPocketMax", format: "currency" },
    { label: "Primary Care Copay", key: "copayPrimaryCare", format: "currency" },
    { label: "Specialist Copay", key: "copaySpecialist", format: "currency" },
    { label: "Generic Drugs", key: "copayGenericDrugs", format: "currency" },
    { label: "ER Visit", key: "copayER", format: "currency" },
    { label: "Coinsurance", key: "coinsurance", format: "percent" },
    { label: "HSA Eligible", key: "hsaEligible", format: "boolean" },
    { label: "HRA Eligible", key: "hraEligible", format: "boolean" },
  ];

  const formatValue = (value: any, format: string) => {
    if (value === null || value === undefined) return "—";
    switch (format) {
      case "currency":
        return formatCurrency(value);
      case "percent":
        return `${value}%`;
      case "boolean":
        return value ? <Check className="h-5 w-5 text-green-500 mx-auto" /> : <Minus className="h-5 w-5 text-slate-300 mx-auto" />;
      default:
        return value;
    }
  };

  if (planIds.length === 0) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h1 className="text-2xl font-bold mb-4">No Plans Selected</h1>
        <p className="text-slate-500 mb-6">Select plans from the shop to compare them.</p>
        <Link href="/shop">
          <Button>Browse Plans</Button>
        </Link>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <Link href="/shop" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-6">
        <ArrowLeft className="h-4 w-4" />
        Back to Shop
      </Link>

      <div className="mb-8">
        <h1 className="text-3xl font-bold">Compare Plans</h1>
        <p className="text-slate-500 mt-1">Side-by-side comparison of selected plans</p>
      </div>

      {isLoading ? (
        <div className="grid gap-4" style={{ gridTemplateColumns: `200px repeat(${planIds.length}, 1fr)` }}>
          {[...Array(10)].map((_, i) => (
            <Skeleton key={i} className="h-12 col-span-full" />
          ))}
        </div>
      ) : plans.length === 0 ? (
        <Card>
          <CardContent className="py-16 text-center">
            <p className="text-slate-500">No plans found for comparison.</p>
          </CardContent>
        </Card>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr>
                <th className="text-left p-4 bg-slate-50 font-medium text-slate-600 w-48 sticky left-0">
                  Feature
                </th>
                {plans.map((plan) => (
                  <th key={plan.id} className="p-4 bg-slate-50 min-w-64">
                    <div className="text-left">
                      <Badge className={cn("mb-2", getMetalTierColor(plan.metalTier))}>
                        {plan.metalTier}
                      </Badge>
                      <h3 className="font-semibold text-lg">{plan.planName}</h3>
                      <p className="text-sm text-slate-500 font-normal">{plan.issuerName}</p>
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {comparisonRows.map((row, idx) => (
                <tr key={row.key} className={idx % 2 === 0 ? "bg-white" : "bg-slate-50"}>
                  <td className="p-4 font-medium text-slate-600 sticky left-0 bg-inherit">
                    {row.label}
                  </td>
                  {plans.map((plan) => (
                    <td key={plan.id} className="p-4 text-center">
                      {formatValue((plan as any)[row.key], row.format)}
                    </td>
                  ))}
                </tr>
              ))}
              {/* Add to Cart Row */}
              <tr className="bg-white border-t-2">
                <td className="p-4 font-medium text-slate-600 sticky left-0 bg-white">
                  Actions
                </td>
                {plans.map((plan) => (
                  <td key={plan.id} className="p-4">
                    <Button
                      className="w-full gap-2"
                      onClick={() => handleAddToCart(plan)}
                    >
                      <ShoppingCart className="h-4 w-4" />
                      Add to Cart
                    </Button>
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>
      )}

      {/* Profile Selection Dialog */}
      <Dialog open={showProfileDialog} onOpenChange={setShowProfileDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Select Profile</DialogTitle>
            <DialogDescription>Choose who this plan is for</DialogDescription>
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
