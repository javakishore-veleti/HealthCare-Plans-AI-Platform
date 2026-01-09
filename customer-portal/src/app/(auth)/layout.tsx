import Link from "next/link";
import { Heart } from "lucide-react";

export default function AuthLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex">
      {/* Left Panel - Branding */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-blue-600 to-blue-800 p-12 flex-col justify-between">
        <Link href="/" className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-white/20">
            <Heart className="h-6 w-6 text-white" />
          </div>
          <span className="text-2xl font-bold text-white">Your Care</span>
        </Link>
        
        <div>
          <h1 className="text-4xl font-bold text-white mb-4">
            Find the Perfect Your Care Plan
          </h1>
          <p className="text-blue-100 text-lg">
            Compare plans, get quotes, and enroll in coverage for you and your family.
          </p>
        </div>

        <div className="flex gap-8">
          <div>
            <p className="text-3xl font-bold text-white">10K+</p>
            <p className="text-blue-200">Plans Available</p>
          </div>
          <div>
            <p className="text-3xl font-bold text-white">50K+</p>
            <p className="text-blue-200">Happy Customers</p>
          </div>
          <div>
            <p className="text-3xl font-bold text-white">24/7</p>
            <p className="text-blue-200">Support</p>
          </div>
        </div>
      </div>

      {/* Right Panel - Form */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="w-full max-w-md">
          {children}
        </div>
      </div>
    </div>
  );
}
