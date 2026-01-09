"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search, Package, Calendar } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";
import type { Order } from "@/types";

export default function OrdersPage() {
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["orders", page, search],
    queryFn: () => ordersApi.search({ page, size: 10, orderNumber: search || undefined, sortBy: "createdAt", sortDirection: "desc" }),
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Orders</h1>
        <p className="text-muted-foreground">Manage orders and payments</p>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search by order number..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="space-y-4">{[...Array(5)].map((_, i) => <Skeleton key={i} className="h-28" />)}</div>
      ) : (
        <>
          <div className="space-y-4">
            {data?.data?.content?.map((order: Order) => (
              <Card key={order.id} className="hover:shadow-md transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-4">
                      <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-primary/10">
                        <Package className="h-6 w-6 text-primary" />
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="font-semibold">{order.orderNumber}</h3>
                          <Badge className={getStatusColor(order.status)}>{order.status.replace("_", " ")}</Badge>
                        </div>
                        <p className="text-sm text-muted-foreground">{order.customerName}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-6">
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Calendar className="h-4 w-4" />{formatDate(order.createdAt)}
                      </div>
                      <div className="text-lg font-semibold">{formatCurrency(order.totalAmount)}</div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} orders
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
