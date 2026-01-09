"use client";

import { useQuery } from "@tanstack/react-query";
import { FileText, Users, ShoppingCart, DollarSign } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { plansApi, customersApi, ordersApi } from "@/lib/api";
import Link from "next/link";

export default function Dashboard() {
  const { data: plans, isLoading: plansLoading } = useQuery({
    queryKey: ["plans-count"],
    queryFn: () => plansApi.search({ page: 0, size: 1 }),
  });

  const { data: customers, isLoading: customersLoading } = useQuery({
    queryKey: ["customers-count"],
    queryFn: () => customersApi.search({ page: 0, size: 1 }),
  });

  const { data: orders, isLoading: ordersLoading } = useQuery({
    queryKey: ["orders-count"],
    queryFn: () => ordersApi.search({ page: 0, size: 1 }),
  });

  const stats = [
    { name: "Total Plans", value: plans?.data?.totalElements || 0, icon: FileText, href: "/plans" },
    { name: "Total Customers", value: customers?.data?.totalElements || 0, icon: Users, href: "/customers" },
    { name: "Total Orders", value: orders?.data?.totalElements || 0, icon: ShoppingCart, href: "/orders" },
    { name: "Revenue", value: "$125,000", icon: DollarSign, href: "/analytics" },
  ];

  const isLoading = plansLoading || customersLoading || ordersLoading;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="text-muted-foreground">Welcome to HealthCare Plans Platform</p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Link key={stat.name} href={stat.href}>
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">{stat.name}</CardTitle>
                <stat.icon className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <Skeleton className="h-8 w-20" />
                ) : (
                  <div className="text-2xl font-bold">{typeof stat.value === "number" ? stat.value.toLocaleString() : stat.value}</div>
                )}
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
