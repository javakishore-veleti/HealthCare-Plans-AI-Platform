"use client";

import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Search, Mail, Phone } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { customersApi } from "@/lib/api";
import { formatDate, getStatusColor } from "@/lib/utils";
import type { Customer } from "@/types";

export default function CustomersPage() {
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");

  const { data, isLoading } = useQuery({
    queryKey: ["customers", page, search],
    queryFn: () => customersApi.search({ page, size: 10, firstName: search || undefined }),
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold">Customers</h1>
        <p className="text-muted-foreground">Manage customer accounts</p>
      </div>

      <Card>
        <CardContent className="pt-6">
          <div className="relative max-w-sm">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input placeholder="Search customers..." value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
          </div>
        </CardContent>
      </Card>

      {isLoading ? (
        <div className="space-y-4">{[...Array(5)].map((_, i) => <Skeleton key={i} className="h-24" />)}</div>
      ) : (
        <>
          <div className="space-y-4">
            {data?.data?.content?.map((customer: Customer) => (
              <Card key={customer.id} className="hover:shadow-md transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary font-semibold">
                      {customer.firstName?.[0]}{customer.lastName?.[0]}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <h3 className="font-semibold">{customer.fullName}</h3>
                        <Badge className={getStatusColor(customer.status)}>{customer.status}</Badge>
                      </div>
                      <p className="text-sm text-muted-foreground">{customer.customerNumber}</p>
                    </div>
                    <div className="hidden md:flex flex-col gap-1 text-sm text-muted-foreground">
                      <div className="flex items-center gap-2"><Mail className="h-4 w-4" />{customer.email}</div>
                      <div className="flex items-center gap-2"><Phone className="h-4 w-4" />{customer.phone}</div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm text-muted-foreground">Joined</p>
                      <p className="font-medium">{formatDate(customer.createdAt)}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {data?.data?.content?.length || 0} of {data?.data?.totalElements || 0} customers
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
