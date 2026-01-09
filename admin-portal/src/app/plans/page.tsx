"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { plansApi } from "@/lib/api";
import { formatCurrency, getMetalTierColor } from "@/lib/utils";
import type { Plan } from "@/types";

export default function PlansPage() {
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["plans", page, search],
    queryFn: () => plansApi.search({ page, size: 12, planName: search || undefined }),
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold">Healthcare Plans</h1>
          <p className="text-muted-foreground">Browse and compare plans</p>
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search plans..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {[...Array(6)].map((_, i) => <Skeleton key={i} className="h-64" />)}
        </div>
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {data?.data?.content?.map((plan: Plan) => (
              <Card key={plan.id} className="hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div>
                      <CardTitle className="text-lg">{plan.planName}</CardTitle>
                      <CardDescription>{plan.issuerName}</CardDescription>
                    </div>
                    <Badge className={getMetalTierColor(plan.metalTier)}>{plan.metalTier}</Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Monthly Premium</span>
                      <span className="font-semibold">{formatCurrency(plan.monthlyPremium)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Deductible</span>
                      <span>{formatCurrency(plan.annualDeductible)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Out of Pocket Max</span>
                      <span>{formatCurrency(plan.outOfPocketMax)}</span>
                    </div>
                  </div>
                  <Button className="w-full">View Details</Button>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} plans
            </p>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={() => setPage((p) => Math.max(0, p - 1))} disabled={page === 0}>Previous</Button>
              <Button variant="outline" size="sm" onClick={() => setPage((p) => p + 1)} disabled={data?.data?.last}>Next</Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
