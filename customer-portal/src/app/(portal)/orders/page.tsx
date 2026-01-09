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
