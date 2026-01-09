"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { Search, Heart, Info, ArrowRight } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { plansApi } from "@/lib/api";
import { formatCurrency, getMetalTierColor, cn } from "@/lib/utils";
import type { Plan } from "@/types";

export default function PublicShopPage() {
  const [search, setSearch] = useState("");
  const [metalTier, setMetalTier] = useState<string>("ALL");
  const [page, setPage] = useState(0);

  const { data, isLoading } = useQuery({
    queryKey: ["plans", page, search, metalTier],
    queryFn: () => plansApi.search({
      page,
      size: 12,
      planName: search || undefined,
      metalTier: metalTier !== "ALL" ? metalTier : undefined,
    }),
  });

  const tiers = ["ALL", "BRONZE", "SILVER", "GOLD", "PLATINUM"];

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <header className="border-b border-slate-200 bg-white sticky top-0 z-50">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Link href="/" className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
              <Heart className="h-5 w-5 text-white" />
            </div>
            <span className="text-xl font-bold">Your Care</span>
          </Link>
          <div className="flex items-center gap-3">
            <Link href="/login">
              <Button variant="ghost">Sign In</Button>
            </Link>
            <Link href="/signup">
              <Button>Get Started</Button>
            </Link>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-slate-900">Browse Healthcare Plans</h1>
          <p className="text-slate-500 mt-1">
            Compare plans and find the perfect coverage. <Link href="/signup" className="text-blue-600 hover:underline">Sign up</Link> to get personalized quotes.
          </p>
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
                    className={cn(metalTier === tier && tier !== "ALL" && getMetalTierColor(tier))}
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
                <Card key={plan.id} className="flex flex-col hover:shadow-lg transition-shadow bg-white">
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
                    <div className="mt-4 pt-4 border-t">
                      <Link href="/signup">
                        <Button className="w-full gap-2">
                          Get Quote
                          <ArrowRight className="h-4 w-4" />
                        </Button>
                      </Link>
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

        {/* CTA */}
        <Card className="mt-12 bg-blue-600 border-0">
          <CardContent className="py-12 text-center">
            <h2 className="text-2xl font-bold text-white mb-2">Ready to enroll?</h2>
            <p className="text-blue-100 mb-6">Create an account to get personalized quotes and manage coverage for your family.</p>
            <Link href="/signup">
              <Button size="lg" className="bg-white text-blue-600 hover:bg-blue-50">
                Create Free Account
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
