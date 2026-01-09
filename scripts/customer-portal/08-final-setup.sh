#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[8/8] Final setup - styles, layout, landing page...${NC}"

cd customer-portal

# =============================================================================
# GLOBAL STYLES
# =============================================================================
cat > src/app/globals.css << 'EOF'
@import "tailwindcss";

@theme {
  --color-border: hsl(214.3 31.8% 91.4%);
  --color-input: hsl(214.3 31.8% 91.4%);
  --color-ring: hsl(210 100% 40%);
  --color-background: hsl(0 0% 100%);
  --color-foreground: hsl(222.2 84% 4.9%);
  --color-primary: hsl(210 100% 40%);
  --color-primary-foreground: hsl(210 40% 98%);
  --color-secondary: hsl(210 40% 96.1%);
  --color-secondary-foreground: hsl(222.2 47.4% 11.2%);
  --color-muted: hsl(210 40% 96.1%);
  --color-muted-foreground: hsl(215.4 16.3% 46.9%);
  --color-accent: hsl(210 40% 96.1%);
  --color-accent-foreground: hsl(222.2 47.4% 11.2%);
  --color-destructive: hsl(0 84.2% 60.2%);
  --color-destructive-foreground: hsl(210 40% 98%);
  --color-card: hsl(0 0% 100%);
  --color-card-foreground: hsl(222.2 84% 4.9%);
  --radius: 0.5rem;
}

@layer base {
  * {
    border-color: var(--color-border);
  }
  body {
    background-color: var(--color-background);
    color: var(--color-foreground);
  }
}

.dark {
  --color-border: hsl(217.2 32.6% 17.5%);
  --color-input: hsl(217.2 32.6% 17.5%);
  --color-ring: hsl(210 100% 50%);
  --color-background: hsl(222.2 84% 4.9%);
  --color-foreground: hsl(210 40% 98%);
  --color-primary: hsl(210 100% 50%);
  --color-primary-foreground: hsl(222.2 47.4% 11.2%);
  --color-secondary: hsl(217.2 32.6% 17.5%);
  --color-secondary-foreground: hsl(210 40% 98%);
  --color-muted: hsl(217.2 32.6% 17.5%);
  --color-muted-foreground: hsl(215 20.2% 65.1%);
  --color-accent: hsl(217.2 32.6% 17.5%);
  --color-accent-foreground: hsl(210 40% 98%);
  --color-destructive: hsl(0 62.8% 30.6%);
  --color-destructive-foreground: hsl(210 40% 98%);
  --color-card: hsl(222.2 84% 4.9%);
  --color-card-foreground: hsl(210 40% 98%);
}
EOF
echo -e "${GREEN}✓${NC} globals.css"

# =============================================================================
# ROOT LAYOUT
# =============================================================================
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Providers } from "@/lib/providers";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: {
    default: "HealthCare Plans - Find Your Perfect Coverage",
    template: "%s | HealthCare Plans",
  },
  description: "Find and compare healthcare plans for you and your family. Get quotes, enroll online, and manage your coverage all in one place.",
  keywords: ["healthcare", "insurance", "health plans", "medical coverage", "enrollment"],
  authors: [{ name: "HealthCare Plans" }],
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://healthcare-plans.com",
    siteName: "HealthCare Plans",
    title: "HealthCare Plans - Find Your Perfect Coverage",
    description: "Find and compare healthcare plans for you and your family.",
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
EOF
echo -e "${GREEN}✓${NC} root layout"

# =============================================================================
# LANDING PAGE
# =============================================================================
cat > src/app/page.tsx << 'EOF'
import Link from "next/link";
import { Heart, Shield, Users, Clock, CheckCircle, ArrowRight, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

export default function HomePage() {
  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="border-b border-slate-200 bg-white">
        <div className="container mx-auto flex h-16 items-center justify-between px-4">
          <Link href="/" className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
              <Heart className="h-5 w-5 text-white" />
            </div>
            <span className="text-xl font-bold">Your Care</span>
          </Link>
          <nav className="hidden md:flex items-center gap-6">
            <Link href="/shop" className="text-sm font-medium text-slate-600 hover:text-slate-900">
              Browse Plans
            </Link>
            <Link href="#features" className="text-sm font-medium text-slate-600 hover:text-slate-900">
              Features
            </Link>
            <Link href="#pricing" className="text-sm font-medium text-slate-600 hover:text-slate-900">
              Pricing
            </Link>
          </nav>
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

      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-br from-blue-600 via-blue-700 to-blue-800 py-24">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-10" />
        <div className="container mx-auto px-4 relative">
          <div className="max-w-3xl mx-auto text-center">
            <Badge className="mb-6 bg-white/20 text-white border-white/30 hover:bg-white/30">
              Trusted by 50,000+ families
            </Badge>
            <h1 className="text-4xl md:text-6xl font-bold text-white mb-6 leading-tight">
              Find the Perfect Your Care Plan for Your Family
            </h1>
            <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
              Compare plans from top insurers, get instant quotes, and enroll online. 
              Coverage for you and up to 500 family members.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <Link href="/signup">
                <Button size="lg" className="bg-white text-blue-600 hover:bg-blue-50 gap-2 w-full sm:w-auto">
                  Start Free Quote
                  <ArrowRight className="h-4 w-4" />
                </Button>
              </Link>
              <Link href="/shop">
                <Button size="lg" variant="outline" className="border-white text-white hover:bg-white/10 w-full sm:w-auto">
                  Browse Plans
                </Button>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-12 bg-slate-50 border-b">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <div className="text-center">
              <p className="text-3xl md:text-4xl font-bold text-blue-600">10,000+</p>
              <p className="text-slate-600 mt-1">Plans Available</p>
            </div>
            <div className="text-center">
              <p className="text-3xl md:text-4xl font-bold text-blue-600">50,000+</p>
              <p className="text-slate-600 mt-1">Happy Customers</p>
            </div>
            <div className="text-center">
              <p className="text-3xl md:text-4xl font-bold text-blue-600">500+</p>
              <p className="text-slate-600 mt-1">Insurance Partners</p>
            </div>
            <div className="text-center">
              <p className="text-3xl md:text-4xl font-bold text-blue-600">24/7</p>
              <p className="text-slate-600 mt-1">Customer Support</p>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Why Choose HealthCare Plans?</h2>
            <p className="text-xl text-slate-600 max-w-2xl mx-auto">
              We make finding and managing healthcare coverage simple for your entire family.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            <Card className="text-center border-0 shadow-lg">
              <CardContent className="pt-8 pb-6">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-blue-100 mx-auto mb-4">
                  <Users className="h-7 w-7 text-blue-600" />
                </div>
                <h3 className="font-semibold text-lg mb-2">Family Profiles</h3>
                <p className="text-slate-600 text-sm">
                  Manage up to 500 profiles for family members, dependents, and loved ones.
                </p>
              </CardContent>
            </Card>
            <Card className="text-center border-0 shadow-lg">
              <CardContent className="pt-8 pb-6">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-green-100 mx-auto mb-4">
                  <Shield className="h-7 w-7 text-green-600" />
                </div>
                <h3 className="font-semibold text-lg mb-2">Compare Plans</h3>
                <p className="text-slate-600 text-sm">
                  Side-by-side comparison of coverage options from top insurance providers.
                </p>
              </CardContent>
            </Card>
            <Card className="text-center border-0 shadow-lg">
              <CardContent className="pt-8 pb-6">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-purple-100 mx-auto mb-4">
                  <Clock className="h-7 w-7 text-purple-600" />
                </div>
                <h3 className="font-semibold text-lg mb-2">Instant Quotes</h3>
                <p className="text-slate-600 text-sm">
                  Get personalized quotes in seconds based on your specific needs.
                </p>
              </CardContent>
            </Card>
            <Card className="text-center border-0 shadow-lg">
              <CardContent className="pt-8 pb-6">
                <div className="flex h-14 w-14 items-center justify-center rounded-xl bg-orange-100 mx-auto mb-4">
                  <CheckCircle className="h-7 w-7 text-orange-600" />
                </div>
                <h3 className="font-semibold text-lg mb-2">Easy Enrollment</h3>
                <p className="text-slate-600 text-sm">
                  Simple online enrollment process with no paperwork required.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Plan Tiers Section */}
      <section id="pricing" className="py-20 bg-slate-50">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Plans for Every Budget</h2>
            <p className="text-xl text-slate-600 max-w-2xl mx-auto">
              Choose from Bronze, Silver, Gold, or Platinum tiers based on your coverage needs.
            </p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 max-w-5xl mx-auto">
            {[
              { tier: "Bronze", color: "bg-amber-700", price: "$150", desc: "Lower premiums, higher deductibles" },
              { tier: "Silver", color: "bg-slate-400", price: "$250", desc: "Balanced coverage and cost" },
              { tier: "Gold", color: "bg-yellow-500", price: "$350", desc: "Higher premiums, lower deductibles", popular: true },
              { tier: "Platinum", color: "bg-slate-300", price: "$450", desc: "Comprehensive coverage" },
            ].map((plan) => (
              <Card key={plan.tier} className={`relative ${plan.popular ? "border-blue-500 border-2 shadow-xl" : ""}`}>
                {plan.popular && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                    <Badge className="bg-blue-600">Most Popular</Badge>
                  </div>
                )}
                <CardContent className="pt-8 pb-6 text-center">
                  <div className={`h-4 w-16 rounded-full mx-auto mb-4 ${plan.color}`} />
                  <h3 className="font-bold text-xl mb-1">{plan.tier}</h3>
                  <p className="text-sm text-slate-500 mb-4">{plan.desc}</p>
                  <p className="text-3xl font-bold mb-1">{plan.price}</p>
                  <p className="text-sm text-slate-500 mb-6">starting/month</p>
                  <Link href="/shop">
                    <Button variant={plan.popular ? "default" : "outline"} className="w-full">
                      View Plans
                    </Button>
                  </Link>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-20">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">What Our Customers Say</h2>
          </div>
          <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
            {[
              { name: "Sarah M.", text: "Found the perfect plan for my family of 5 in minutes. The comparison tool made it so easy!" },
              { name: "James K.", text: "Managing profiles for my elderly parents was seamless. Great customer support too!" },
              { name: "Lisa T.", text: "Saved over $200/month by comparing plans here. Highly recommend to everyone!" },
            ].map((testimonial, i) => (
              <Card key={i}>
                <CardContent className="pt-6">
                  <div className="flex gap-1 mb-4">
                    {[...Array(5)].map((_, j) => (
                      <Star key={j} className="h-5 w-5 fill-yellow-400 text-yellow-400" />
                    ))}
                  </div>
                  <p className="text-slate-600 mb-4">&ldquo;{testimonial.text}&rdquo;</p>
                  <p className="font-semibold">{testimonial.name}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-blue-600">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl md:text-4xl font-bold text-white mb-4">
            Ready to Find Your Plan?
          </h2>
          <p className="text-xl text-blue-100 mb-8 max-w-2xl mx-auto">
            Join thousands of families who have found the perfect healthcare coverage.
          </p>
          <Link href="/signup">
            <Button size="lg" className="bg-white text-blue-600 hover:bg-blue-50 gap-2">
              Get Started Free
              <ArrowRight className="h-4 w-4" />
            </Button>
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-slate-900 text-slate-400 py-12">
        <div className="container mx-auto px-4">
          <div className="grid md:grid-cols-4 gap-8 mb-8">
            <div>
              <Link href="/" className="flex items-center gap-2 mb-4">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600">
                  <Heart className="h-4 w-4 text-white" />
                </div>
                <span className="font-bold text-white">Your Care</span>
              </Link>
              <p className="text-sm">
                Making healthcare coverage simple and accessible for everyone.
              </p>
            </div>
            <div>
              <h4 className="font-semibold text-white mb-4">Plans</h4>
              <ul className="space-y-2 text-sm">
                <li><Link href="/shop?tier=BRONZE" className="hover:text-white">Bronze Plans</Link></li>
                <li><Link href="/shop?tier=SILVER" className="hover:text-white">Silver Plans</Link></li>
                <li><Link href="/shop?tier=GOLD" className="hover:text-white">Gold Plans</Link></li>
                <li><Link href="/shop?tier=PLATINUM" className="hover:text-white">Platinum Plans</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-white mb-4">Company</h4>
              <ul className="space-y-2 text-sm">
                <li><Link href="/about" className="hover:text-white">About Us</Link></li>
                <li><Link href="/contact" className="hover:text-white">Contact</Link></li>
                <li><Link href="/careers" className="hover:text-white">Careers</Link></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold text-white mb-4">Legal</h4>
              <ul className="space-y-2 text-sm">
                <li><Link href="/privacy" className="hover:text-white">Privacy Policy</Link></li>
                <li><Link href="/terms" className="hover:text-white">Terms of Service</Link></li>
              </ul>
            </div>
          </div>
          <div className="border-t border-slate-800 pt-8 text-center text-sm">
            © {new Date().getFullYear()} HealthCare Plans. All rights reserved.
          </div>
        </div>
      </footer>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} landing page"

# =============================================================================
# PUBLIC SHOP PAGE (Non-authenticated)
# =============================================================================
mkdir -p src/app/shop

cat > src/app/shop/page.tsx << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} public shop page"

# =============================================================================
# UPDATE PACKAGE.JSON FOR PORT 3001
# =============================================================================
# Already done in 01-init.sh, but let's verify
sed -i '' 's/"dev": "next dev"/"dev": "next dev --webpack -p 3001"/' package.json 2>/dev/null || true
sed -i '' 's/"start": "next start"/"start": "next start -p 3001"/' package.json 2>/dev/null || true

echo -e "${GREEN}✓${NC} package.json updated for port 3001"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Customer Portal Setup Complete!      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "To start the customer portal:"
echo "  cd customer-portal"
echo "  npm run dev"
echo ""
echo "Open: http://localhost:3001"
echo ""
echo "Pages available:"
echo "  / - Landing page (public)"
echo "  /shop - Browse plans (public)"
echo "  /login - Sign in"
echo "  /signup - Create account"
echo "  /forgot-password - Reset password"
echo "  /dashboard - User dashboard (auth required)"
echo "  /profiles - Manage profiles (auth required)"
echo "  /cart - Shopping cart (auth required)"
echo "  /orders - Order history (auth required)"
EOF
echo -e "${GREEN}✓${NC} final setup complete"