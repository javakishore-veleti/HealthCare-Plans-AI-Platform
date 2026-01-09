"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { Search, ShoppingCart, Check, Info, GitCompare } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Checkbox } from "@/components/ui/checkbox";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { plansApi } from "@/lib/api";
import { useAuthStore, useCartStore } from "@/store";
import { formatCurrency, getMetalTierColor, cn } from "@/lib/utils";
import { toast } from "sonner";
import type { Plan, Profile } from "@/types";

export default function ShopPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [metalTier, setMetalTier] = useState<string>("ALL");
  const [page, setPage] = useState(0);
  const [selectedPlan, setSelectedPlan] = useState<Plan | null>(null);
  const [showProfileDialog, setShowProfileDialog] = useState(false);
  const [compareList, setCompareList] = useState<string[]>([]);

  const { profiles } = useAuthStore();
  const { addItem, hasItem } = useCartStore();

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

  const toggleCompare = (planId: string) => {
    setCompareList((prev) => {
      if (prev.includes(planId)) {
        return prev.filter((id) => id !== planId);
      }
      if (prev.length >= 4) {
        toast.error("You can compare up to 4 plans at a time");
        return prev;
      }
      return [...prev, planId];
    });
  };

  const goToCompare = () => {
    if (compareList.length < 2) {
      toast.error("Select at least 2 plans to compare");
      return;
    }
    router.push(`/compare?ids=${compareList.join(",")}`);
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

      {/* Compare Bar */}
      {compareList.length > 0 && (
        <Card className="mb-6 border-blue-200 bg-blue-50">
          <CardContent className="py-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <GitCompare className="h-5 w-5 text-blue-600" />
                <span className="font-medium">{compareList.length} plans selected</span>
                <span className="text-sm text-slate-500">(max 4)</span>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" size="sm" onClick={() => setCompareList([])}>
                  Clear
                </Button>
                <Button size="sm" onClick={goToCompare} disabled={compareList.length < 2}>
                  Compare Plans
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

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
              <Card 
                key={plan.id} 
                className={cn(
                  "flex flex-col hover:shadow-lg transition-shadow",
                  compareList.includes(plan.id) && "ring-2 ring-blue-500"
                )}
              >
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <Badge className={cn(getMetalTierColor(plan.metalTier))}>
                          {plan.metalTier}
                        </Badge>
                        <label className="flex items-center gap-1 text-sm cursor-pointer">
                          <Checkbox
                            checked={compareList.includes(plan.id)}
                            onCheckedChange={() => toggleCompare(plan.id)}
                          />
                          Compare
                        </label>
                      </div>
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
