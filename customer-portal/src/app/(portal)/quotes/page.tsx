"use client";

import Link from "next/link";
import { FileText, ArrowRight } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

export default function QuotesPage() {
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold">My Quotes</h1>
        <p className="text-slate-500 mt-1">View and manage your saved quotes</p>
      </div>

      <Card>
        <CardContent className="py-16 text-center">
          <FileText className="h-12 w-12 text-slate-300 mx-auto mb-4" />
          <h2 className="text-xl font-semibold mb-2">No saved quotes</h2>
          <p className="text-slate-500 mb-6">
            Add plans to your cart and save them as quotes to view later.
          </p>
          <Link href="/shop">
            <Button>Browse Plans</Button>
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}
