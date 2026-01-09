#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[3/4] Adding Order History feature...${NC}"

# =============================================================================
# ORDER DETAIL PAGE
# =============================================================================

cat > "customer-portal/src/app/(portal)/orders/[id]/page.tsx" << 'EOF'
"use client";

import { useParams } from "next/navigation";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ArrowLeft, Package, Calendar, CreditCard, User, MapPin, Clock, CheckCircle, XCircle, AlertCircle } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor, getMetalTierColor } from "@/lib/utils";

const statusIcons: Record<string, any> = {
  PENDING: Clock,
  CONFIRMED: CheckCircle,
  PROCESSING: Clock,
  COMPLETED: CheckCircle,
  CANCELLED: XCircle,
  FAILED: AlertCircle,
};

export default function OrderDetailPage() {
  const params = useParams();
  const orderId = params.id as string;

  const { data, isLoading } = useQuery({
    queryKey: ["order", orderId],
    queryFn: () => ordersApi.getById(orderId),
    enabled: !!orderId,
  });

  const order = data?.data;

  if (isLoading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <Skeleton className="h-8 w-48 mb-6" />
        <div className="grid gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2 space-y-6">
            <Skeleton className="h-64" />
            <Skeleton className="h-48" />
          </div>
          <Skeleton className="h-96" />
        </div>
      </div>
    );
  }

  if (!order) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h1 className="text-2xl font-bold mb-4">Order Not Found</h1>
        <p className="text-slate-500 mb-6">The order you're looking for doesn't exist.</p>
        <Link href="/orders">
          <Button>View All Orders</Button>
        </Link>
      </div>
    );
  }

  const StatusIcon = statusIcons[order.status] || Clock;

  return (
    <div className="container mx-auto px-4 py-8">
      <Link href="/orders" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-6">
        <ArrowLeft className="h-4 w-4" />
        Back to Orders
      </Link>

      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
        <div>
          <div className="flex items-center gap-3 mb-2">
            <h1 className="text-3xl font-bold">Order {order.orderNumber}</h1>
            <Badge className={getStatusColor(order.status)}>
              <StatusIcon className="h-3 w-3 mr-1" />
              {order.status.replace("_", " ")}
            </Badge>
          </div>
          <p className="text-slate-500">
            Placed on {formatDate(order.createdAt)}
          </p>
        </div>
        {order.status === "PENDING" && (
          <Button variant="outline" className="mt-4 md:mt-0 text-red-500 hover:text-red-700">
            Cancel Order
          </Button>
        )}
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        {/* Order Items */}
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Package className="h-5 w-5" />
                Order Items
              </CardTitle>
              <CardDescription>
                {order.items?.length || 0} plan(s) in this order
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.items?.map((item: any, index: number) => (
                  <div
                    key={item.id || index}
                    className="flex items-center justify-between p-4 rounded-lg bg-slate-50"
                  >
                    <div className="flex items-center gap-4">
                      <Badge className={getMetalTierColor(item.plan?.metalTier || item.metalTier)}>
                        {item.plan?.metalTier || item.metalTier}
                      </Badge>
                      <div>
                        <p className="font-medium">{item.plan?.planName || item.planName}</p>
                        <p className="text-sm text-slate-500">
                          For: {item.profile?.firstName || "Member"} {item.profile?.lastName || ""}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold">{formatCurrency(item.monthlyPremium || item.premium)}/mo</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Timeline */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Clock className="h-5 w-5" />
                Order Timeline
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex gap-4">
                  <div className="flex flex-col items-center">
                    <div className="flex h-8 w-8 items-center justify-center rounded-full bg-green-100">
                      <CheckCircle className="h-4 w-4 text-green-600" />
                    </div>
                    <div className="flex-1 w-px bg-slate-200 my-2" />
                  </div>
                  <div className="pb-4">
                    <p className="font-medium">Order Placed</p>
                    <p className="text-sm text-slate-500">{formatDate(order.createdAt)}</p>
                  </div>
                </div>

                {order.status !== "PENDING" && (
                  <div className="flex gap-4">
                    <div className="flex flex-col items-center">
                      <div className="flex h-8 w-8 items-center justify-center rounded-full bg-green-100">
                        <CheckCircle className="h-4 w-4 text-green-600" />
                      </div>
                      <div className="flex-1 w-px bg-slate-200 my-2" />
                    </div>
                    <div className="pb-4">
                      <p className="font-medium">Payment Confirmed</p>
                      <p className="text-sm text-slate-500">{formatDate(order.updatedAt)}</p>
                    </div>
                  </div>
                )}

                {order.status === "COMPLETED" && (
                  <div className="flex gap-4">
                    <div className="flex flex-col items-center">
                      <div className="flex h-8 w-8 items-center justify-center rounded-full bg-green-100">
                        <CheckCircle className="h-4 w-4 text-green-600" />
                      </div>
                    </div>
                    <div>
                      <p className="font-medium">Enrollment Active</p>
                      <p className="text-sm text-slate-500">Effective {formatDate(order.effectiveDate)}</p>
                    </div>
                  </div>
                )}

                {order.status === "CANCELLED" && (
                  <div className="flex gap-4">
                    <div className="flex flex-col items-center">
                      <div className="flex h-8 w-8 items-center justify-center rounded-full bg-red-100">
                        <XCircle className="h-4 w-4 text-red-600" />
                      </div>
                    </div>
                    <div>
                      <p className="font-medium">Order Cancelled</p>
                      <p className="text-sm text-slate-500">{formatDate(order.updatedAt)}</p>
                    </div>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Order Summary Sidebar */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Order Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-500">Order Number</span>
                  <span className="font-mono text-sm">{order.orderNumber}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Order Type</span>
                  <span>{order.orderType?.replace("_", " ") || "Enrollment"}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Effective Date</span>
                  <span>{formatDate(order.effectiveDate)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Billing</span>
                  <span>{order.billingFrequency || "Monthly"}</span>
                </div>
              </div>

              <div className="border-t pt-4 space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-500">Monthly Premium</span>
                  <span className="font-semibold">{formatCurrency(order.totalMonthlyPremium || order.totalAmount)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Annual Premium</span>
                  <span>{formatCurrency((order.totalMonthlyPremium || order.totalAmount) * 12)}</span>
                </div>
              </div>

              <div className="border-t pt-4">
                <div className="flex justify-between text-lg font-semibold">
                  <span>Total Paid</span>
                  <span className="text-blue-600">{formatCurrency(order.totalMonthlyPremium || order.totalAmount)}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Payment Info */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <CreditCard className="h-5 w-5" />
                Payment
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-500">Method</span>
                  <span>{order.paymentMethod || "Credit Card"}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Status</span>
                  <Badge variant="secondary" className="bg-green-100 text-green-700">
                    Paid
                  </Badge>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Actions */}
          <Card>
            <CardContent className="pt-6">
              <div className="space-y-2">
                <Button variant="outline" className="w-full">
                  Download Invoice
                </Button>
                <Button variant="outline" className="w-full">
                  Contact Support
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} Order detail page created"

# =============================================================================
# UPDATE ORDERS LIST PAGE
# =============================================================================

cat > "customer-portal/src/app/(portal)/orders/page.tsx" << 'EOF'
"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { Package, Calendar, ArrowRight, Search, Filter } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor } from "@/lib/utils";

export default function OrdersPage() {
  const [statusFilter, setStatusFilter] = useState<string>("ALL");
  const [searchTerm, setSearchTerm] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["my-orders"],
    queryFn: () => ordersApi.getMyOrders(),
  });

  const allOrders = data?.data || [];
  
  // Filter orders
  const orders = allOrders.filter((order: any) => {
    const matchesStatus = statusFilter === "ALL" || order.status === statusFilter;
    const matchesSearch = !searchTerm || 
      order.orderNumber?.toLowerCase().includes(searchTerm.toLowerCase());
    return matchesStatus && matchesSearch;
  });

  const statuses = ["ALL", "PENDING", "CONFIRMED", "PROCESSING", "COMPLETED", "CANCELLED"];

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">My Orders</h1>
        <p className="text-slate-500 mt-1">View and manage your healthcare plan orders</p>
      </div>

      {/* Filters */}
      <Card className="mb-6">
        <CardContent className="pt-6">
          <div className="flex flex-col md:flex-row gap-4">
            <div className="relative flex-1 max-w-md">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
              <Input
                placeholder="Search by order number..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-full md:w-48">
                <Filter className="h-4 w-4 mr-2" />
                <SelectValue placeholder="Filter by status" />
              </SelectTrigger>
              <SelectContent>
                {statuses.map((status) => (
                  <SelectItem key={status} value={status}>
                    {status === "ALL" ? "All Statuses" : status.replace("_", " ")}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Order Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <Card>
          <CardContent className="pt-6">
            <p className="text-2xl font-bold">{allOrders.length}</p>
            <p className="text-sm text-slate-500">Total Orders</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-2xl font-bold text-green-600">
              {allOrders.filter((o: any) => o.status === "COMPLETED").length}
            </p>
            <p className="text-sm text-slate-500">Completed</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-2xl font-bold text-yellow-600">
              {allOrders.filter((o: any) => o.status === "PENDING" || o.status === "PROCESSING").length}
            </p>
            <p className="text-sm text-slate-500">In Progress</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <p className="text-2xl font-bold text-blue-600">
              {formatCurrency(allOrders.reduce((sum: number, o: any) => sum + (o.totalMonthlyPremium || o.totalAmount || 0), 0))}
            </p>
            <p className="text-sm text-slate-500">Monthly Total</p>
          </CardContent>
        </Card>
      </div>

      {/* Orders List */}
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
            <h2 className="text-xl font-semibold mb-2">
              {searchTerm || statusFilter !== "ALL" ? "No matching orders" : "No orders yet"}
            </h2>
            <p className="text-slate-500 mb-6">
              {searchTerm || statusFilter !== "ALL" 
                ? "Try adjusting your filters"
                : "Start shopping for healthcare plans to see your orders here."
              }
            </p>
            {!searchTerm && statusFilter === "ALL" && (
              <Link href="/shop">
                <Button>Browse Plans</Button>
              </Link>
            )}
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
                        <div className="flex items-center gap-4 text-sm text-slate-500 mt-1">
                          <span className="flex items-center gap-1">
                            <Calendar className="h-4 w-4" />
                            {formatDate(order.createdAt)}
                          </span>
                          <span>{order.items?.length || 0} plan(s)</span>
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-4">
                      <div className="text-right">
                        <p className="font-semibold">{formatCurrency(order.totalMonthlyPremium || order.totalAmount)}/mo</p>
                        <p className="text-sm text-slate-500">
                          Effective: {formatDate(order.effectiveDate)}
                        </p>
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
echo -e "${GREEN}✓${NC} Orders list page updated"

echo -e "${GREEN}✓ Order history feature added${NC}"