"use client";

import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { ShoppingBag, FileText, Users, CreditCard, ArrowRight, Plus } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuthStore } from "@/store";
import { ordersApi } from "@/lib/api";
import { formatCurrency, formatDate, getStatusColor, getInitials } from "@/lib/utils";

export default function DashboardPage() {
  const { user, profiles, getActiveProfile } = useAuthStore();
  const activeProfile = getActiveProfile();

  const { data: ordersData, isLoading: ordersLoading } = useQuery({
    queryKey: ["my-orders"],
    queryFn: () => ordersApi.getMyOrders(),
  });

  const recentOrders = ordersData?.data?.slice(0, 3) || [];

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Welcome Section */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-slate-900 dark:text-white">
          Welcome back, {user?.firstName}!
        </h1>
        <p className="text-slate-500 mt-1">
          Manage your healthcare plans and profiles from your dashboard.
        </p>
      </div>

      {/* Quick Stats */}
      <div className="grid gap-4 md:grid-cols-4 mb-8">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-blue-100">
                <Users className="h-6 w-6 text-blue-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{profiles.length}</p>
                <p className="text-sm text-slate-500">Profiles</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-green-100">
                <FileText className="h-6 w-6 text-green-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{recentOrders.length}</p>
                <p className="text-sm text-slate-500">Orders</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-purple-100">
                <ShoppingBag className="h-6 w-6 text-purple-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">0</p>
                <p className="text-sm text-slate-500">Active Plans</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-4">
              <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-orange-100">
                <CreditCard className="h-6 w-6 text-orange-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">$0</p>
                <p className="text-sm text-slate-500">Monthly Cost</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-8 lg:grid-cols-3">
        {/* Profiles Section */}
        <div className="lg:col-span-1">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>My Profiles</CardTitle>
                <Link href="/profiles/new">
                  <Button size="sm" variant="outline" className="gap-1">
                    <Plus className="h-4 w-4" />
                    Add
                  </Button>
                </Link>
              </div>
              <CardDescription>Manage profiles for yourself and family</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {profiles.slice(0, 5).map((profile) => (
                  <Link
                    key={profile.id}
                    href={`/profiles/${profile.id}`}
                    className="flex items-center gap-3 p-3 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors"
                  >
                    <Avatar>
                      <AvatarFallback>
                        {getInitials(profile.firstName, profile.lastName)}
                      </AvatarFallback>
                    </Avatar>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium truncate">
                        {profile.firstName} {profile.lastName}
                      </p>
                      <p className="text-sm text-slate-500">{profile.relationship}</p>
                    </div>
                    {profile.isPrimary && (
                      <Badge variant="secondary">Primary</Badge>
                    )}
                  </Link>
                ))}
              </div>
              {profiles.length > 5 && (
                <Link href="/profiles" className="block mt-4">
                  <Button variant="ghost" className="w-full gap-2">
                    View All Profiles
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Recent Orders */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Recent Orders</CardTitle>
                <Link href="/orders">
                  <Button size="sm" variant="outline" className="gap-1">
                    View All
                    <ArrowRight className="h-4 w-4" />
                  </Button>
                </Link>
              </div>
              <CardDescription>Your latest healthcare plan orders</CardDescription>
            </CardHeader>
            <CardContent>
              {ordersLoading ? (
                <div className="space-y-4">
                  {[...Array(3)].map((_, i) => (
                    <Skeleton key={i} className="h-20 w-full" />
                  ))}
                </div>
              ) : recentOrders.length > 0 ? (
                <div className="space-y-4">
                  {recentOrders.map((order: any) => (
                    <Link
                      key={order.id}
                      href={`/orders/${order.id}`}
                      className="flex items-center justify-between p-4 rounded-lg border border-slate-200 hover:border-slate-300 hover:shadow-sm transition-all dark:border-slate-800"
                    >
                      <div>
                        <p className="font-medium">{order.orderNumber}</p>
                        <p className="text-sm text-slate-500">{formatDate(order.createdAt)}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold">{formatCurrency(order.totalAmount)}</p>
                        <Badge className={getStatusColor(order.status)}>
                          {order.status.replace("_", " ")}
                        </Badge>
                      </div>
                    </Link>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8">
                  <ShoppingBag className="h-12 w-12 text-slate-300 mx-auto mb-4" />
                  <p className="text-slate-500 mb-4">No orders yet</p>
                  <Link href="/shop">
                    <Button>Browse Plans</Button>
                  </Link>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="mt-8">
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid gap-4 md:grid-cols-3">
          <Link href="/shop">
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-blue-600">
                    <ShoppingBag className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-medium">Browse Plans</p>
                    <p className="text-sm text-slate-500">Find the perfect coverage</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>

          <Link href="/profiles/new">
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-green-600">
                    <Plus className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-medium">Add Profile</p>
                    <p className="text-sm text-slate-500">Cover family members</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>

          <Link href="/quotes">
            <Card className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="pt-6">
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-purple-600">
                    <FileText className="h-5 w-5 text-white" />
                  </div>
                  <div>
                    <p className="font-medium">View Quotes</p>
                    <p className="text-sm text-slate-500">Check saved quotes</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </Link>
        </div>
      </div>
    </div>
  );
}
