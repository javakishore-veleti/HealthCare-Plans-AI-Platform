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
