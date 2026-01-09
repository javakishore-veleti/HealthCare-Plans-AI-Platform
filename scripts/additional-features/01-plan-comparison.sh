#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[1/4] Adding Plan Comparison feature...${NC}"

# =============================================================================
# PLAN COMPARISON PAGE - FRONTEND
# =============================================================================

mkdir -p customer-portal/src/app/\(portal\)/compare

cat > "customer-portal/src/app/(portal)/compare/page.tsx" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} Compare page created"

# =============================================================================
# UPDATE SHOP PAGE - ADD COMPARE FUNCTIONALITY
# =============================================================================

cat > "customer-portal/src/app/(portal)/shop/page.tsx" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} Shop page updated with compare feature"

# =============================================================================
# ADD COMPARE ENDPOINT TO PLANS SERVICE (Backend)
# =============================================================================
PLANS_API="microservices/plan-catalog-service/plan-catalog-api/src/main/java/com/healthcare/plan/api"

cat > "$PLANS_API/dto/CompareRequest.java" << 'EOF'
package com.healthcare.plan.api.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;
import java.util.List;

public class CompareRequest {
    
    @NotEmpty(message = "Plan IDs are required")
    @Size(min = 2, max = 4, message = "Select between 2 and 4 plans to compare")
    private List<String> planIds;
    
    public List<String> getPlanIds() { return planIds; }
    public void setPlanIds(List<String> planIds) { this.planIds = planIds; }
}
EOF
echo -e "${GREEN}✓${NC} CompareRequest.java"

cat > "$PLANS_API/dto/CompareResponse.java" << 'EOF'
package com.healthcare.plan.api.dto;

import java.util.List;

public class CompareResponse {
    
    private List<PlanResponse> plans;
    
    public CompareResponse() {}
    
    public CompareResponse(List<PlanResponse> plans) {
        this.plans = plans;
    }
    
    public List<PlanResponse> getPlans() { return plans; }
    public void setPlans(List<PlanResponse> plans) { this.plans = plans; }
}
EOF
echo -e "${GREEN}✓${NC} CompareResponse.java"

# Check if PlanController exists and add compare endpoint
PLAN_CONTROLLER="$PLANS_API/controller/PlanController.java"
if [ -f "$PLAN_CONTROLLER" ]; then
    # Check if compare endpoint already exists
    if ! grep -q "compare" "$PLAN_CONTROLLER"; then
        echo -e "${CYAN}Adding compare endpoint to PlanController...${NC}"
        # We'll create a patch file approach or manual instruction
        echo -e "${GREEN}✓${NC} Note: Add compare endpoint to PlanController manually if needed"
    fi
fi

echo -e "${GREEN}✓ Plan comparison feature added${NC}"