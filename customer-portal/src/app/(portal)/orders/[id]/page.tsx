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
