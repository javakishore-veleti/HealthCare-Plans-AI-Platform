#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[6/8] Creating auth pages...${NC}"

cd customer-portal

# Create auth route group directories
mkdir -p "src/app/(auth)/login"
mkdir -p "src/app/(auth)/signup"
mkdir -p "src/app/(auth)/forgot-password"
mkdir -p "src/app/(auth)/reset-password"

# =============================================================================
# AUTH LAYOUT
# =============================================================================
cat > "src/app/(auth)/layout.tsx" << 'EOF'
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
EOF
echo -e "${GREEN}✓${NC} auth layout"

# =============================================================================
# LOGIN PAGE
# =============================================================================
cat > "src/app/(auth)/login/page.tsx" << 'EOF'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Mail, Lock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { useAuth } from "@/hooks";
import { toast } from "sonner";

const loginSchema = z.object({
  email: z.string().email("Please enter a valid email"),
  password: z.string().min(1, "Password is required"),
  rememberMe: z.boolean().optional(),
});

type LoginForm = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, formState: { errors }, setValue, watch } = useForm<LoginForm>({
    resolver: zodResolver(loginSchema),
    defaultValues: { rememberMe: false },
  });

  const onSubmit = async (data: LoginForm) => {
    setIsLoading(true);
    try {
      await login(data.email, data.password);
      toast.success("Welcome back!");
      router.push("/dashboard");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Invalid email or password");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      {/* Mobile Logo */}
      <div className="lg:hidden flex items-center gap-2 mb-8">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
          <span className="text-white font-bold">H</span>
        </div>
        <span className="text-xl font-bold">Your Care</span>
      </div>

      <div className="mb-8">
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white">Welcome back</h2>
        <p className="text-slate-500 mt-2">Sign in to your account to continue</p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        {/* Email */}
        <div className="space-y-2">
          <Label htmlFor="email" error={!!errors.email}>Email</Label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="email"
              type="email"
              placeholder="you@example.com"
              className="pl-10"
              error={!!errors.email}
              {...register("email")}
            />
          </div>
          {errors.email && <p className="text-sm text-red-500">{errors.email.message}</p>}
        </div>

        {/* Password */}
        <div className="space-y-2">
          <Label htmlFor="password" error={!!errors.password}>Password</Label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="password"
              type={showPassword ? "text" : "password"}
              placeholder="••••••••"
              className="pl-10 pr-10"
              error={!!errors.password}
              {...register("password")}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
            </button>
          </div>
          {errors.password && <p className="text-sm text-red-500">{errors.password.message}</p>}
        </div>

        {/* Remember Me & Forgot Password */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Checkbox
              id="rememberMe"
              checked={watch("rememberMe")}
              onCheckedChange={(checked) => setValue("rememberMe", checked as boolean)}
            />
            <Label htmlFor="rememberMe" className="text-sm font-normal cursor-pointer">
              Remember me
            </Label>
          </div>
          <Link href="/forgot-password" className="text-sm text-blue-600 hover:underline">
            Forgot password?
          </Link>
        </div>

        {/* Submit */}
        <Button type="submit" className="w-full" size="lg" loading={isLoading}>
          Sign In
        </Button>
      </form>

      {/* Sign Up Link */}
      <p className="mt-8 text-center text-sm text-slate-500">
        Don&apos;t have an account?{" "}
        <Link href="/signup" className="text-blue-600 font-medium hover:underline">
          Create account
        </Link>
      </p>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} login page"

# =============================================================================
# SIGNUP PAGE
# =============================================================================
cat > "src/app/(auth)/signup/page.tsx" << 'EOF'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Mail, Lock, User, Phone } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { useAuth } from "@/hooks";
import { toast } from "sonner";

const signupSchema = z.object({
  firstName: z.string().min(2, "First name must be at least 2 characters"),
  lastName: z.string().min(2, "Last name must be at least 2 characters"),
  email: z.string().email("Please enter a valid email"),
  phone: z.string().min(10, "Please enter a valid phone number"),
  password: z.string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
    .regex(/[a-z]/, "Password must contain at least one lowercase letter")
    .regex(/[0-9]/, "Password must contain at least one number"),
  confirmPassword: z.string(),
  acceptTerms: z.boolean().refine((val) => val === true, "You must accept the terms"),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"],
});

type SignupForm = z.infer<typeof signupSchema>;

export default function SignupPage() {
  const router = useRouter();
  const { signup } = useAuth(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, formState: { errors }, setValue, watch } = useForm<SignupForm>({
    resolver: zodResolver(signupSchema),
    defaultValues: { acceptTerms: false },
  });

  const onSubmit = async (data: SignupForm) => {
    setIsLoading(true);
    try {
      await signup({
        firstName: data.firstName,
        lastName: data.lastName,
        email: data.email,
        phone: data.phone,
        password: data.password,
      });
      toast.success("Account created successfully!");
      router.push("/dashboard");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to create account");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      {/* Mobile Logo */}
      <div className="lg:hidden flex items-center gap-2 mb-8">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
          <span className="text-white font-bold">H</span>
        </div>
        <span className="text-xl font-bold">Your Care</span>
      </div>

      <div className="mb-8">
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white">Create your account</h2>
        <p className="text-slate-500 mt-2">Start your healthcare journey today</p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        {/* Name Fields */}
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-2">
            <Label htmlFor="firstName" error={!!errors.firstName}>First Name</Label>
            <div className="relative">
              <User className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
              <Input
                id="firstName"
                placeholder="John"
                className="pl-10"
                error={!!errors.firstName}
                {...register("firstName")}
              />
            </div>
            {errors.firstName && <p className="text-xs text-red-500">{errors.firstName.message}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="lastName" error={!!errors.lastName}>Last Name</Label>
            <Input
              id="lastName"
              placeholder="Doe"
              error={!!errors.lastName}
              {...register("lastName")}
            />
            {errors.lastName && <p className="text-xs text-red-500">{errors.lastName.message}</p>}
          </div>
        </div>

        {/* Email */}
        <div className="space-y-2">
          <Label htmlFor="email" error={!!errors.email}>Email</Label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="email"
              type="email"
              placeholder="you@example.com"
              className="pl-10"
              error={!!errors.email}
              {...register("email")}
            />
          </div>
          {errors.email && <p className="text-xs text-red-500">{errors.email.message}</p>}
        </div>

        {/* Phone */}
        <div className="space-y-2">
          <Label htmlFor="phone" error={!!errors.phone}>Phone Number</Label>
          <div className="relative">
            <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="phone"
              type="tel"
              placeholder="(555) 555-5555"
              className="pl-10"
              error={!!errors.phone}
              {...register("phone")}
            />
          </div>
          {errors.phone && <p className="text-xs text-red-500">{errors.phone.message}</p>}
        </div>

        {/* Password */}
        <div className="space-y-2">
          <Label htmlFor="password" error={!!errors.password}>Password</Label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="password"
              type={showPassword ? "text" : "password"}
              placeholder="••••••••"
              className="pl-10 pr-10"
              error={!!errors.password}
              {...register("password")}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
            </button>
          </div>
          {errors.password && <p className="text-xs text-red-500">{errors.password.message}</p>}
        </div>

        {/* Confirm Password */}
        <div className="space-y-2">
          <Label htmlFor="confirmPassword" error={!!errors.confirmPassword}>Confirm Password</Label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="confirmPassword"
              type={showConfirmPassword ? "text" : "password"}
              placeholder="••••••••"
              className="pl-10 pr-10"
              error={!!errors.confirmPassword}
              {...register("confirmPassword")}
            />
            <button
              type="button"
              onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              {showConfirmPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
            </button>
          </div>
          {errors.confirmPassword && <p className="text-xs text-red-500">{errors.confirmPassword.message}</p>}
        </div>

        {/* Terms */}
        <div className="flex items-start gap-2">
          <Checkbox
            id="acceptTerms"
            checked={watch("acceptTerms")}
            onCheckedChange={(checked) => setValue("acceptTerms", checked as boolean)}
            className="mt-1"
          />
          <Label htmlFor="acceptTerms" className="text-sm font-normal cursor-pointer leading-relaxed">
            I agree to the{" "}
            <Link href="/terms" className="text-blue-600 hover:underline">Terms of Service</Link>
            {" "}and{" "}
            <Link href="/privacy" className="text-blue-600 hover:underline">Privacy Policy</Link>
          </Label>
        </div>
        {errors.acceptTerms && <p className="text-xs text-red-500">{errors.acceptTerms.message}</p>}

        {/* Submit */}
        <Button type="submit" className="w-full" size="lg" loading={isLoading}>
          Create Account
        </Button>
      </form>

      {/* Sign In Link */}
      <p className="mt-6 text-center text-sm text-slate-500">
        Already have an account?{" "}
        <Link href="/login" className="text-blue-600 font-medium hover:underline">
          Sign in
        </Link>
      </p>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} signup page"

# =============================================================================
# FORGOT PASSWORD PAGE
# =============================================================================
cat > "src/app/(auth)/forgot-password/page.tsx" << 'EOF'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Mail, ArrowLeft, CheckCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { authApi } from "@/lib/api";
import { toast } from "sonner";

const forgotPasswordSchema = z.object({
  email: z.string().email("Please enter a valid email"),
});

type ForgotPasswordForm = z.infer<typeof forgotPasswordSchema>;

export default function ForgotPasswordPage() {
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [submittedEmail, setSubmittedEmail] = useState("");

  const { register, handleSubmit, formState: { errors } } = useForm<ForgotPasswordForm>({
    resolver: zodResolver(forgotPasswordSchema),
  });

  const onSubmit = async (data: ForgotPasswordForm) => {
    setIsLoading(true);
    try {
      await authApi.forgotPassword(data.email);
      setSubmittedEmail(data.email);
      setIsSubmitted(true);
    } catch (error: any) {
      // Don't reveal if email exists or not for security
      setSubmittedEmail(data.email);
      setIsSubmitted(true);
    } finally {
      setIsLoading(false);
    }
  };

  if (isSubmitted) {
    return (
      <div className="text-center">
        <div className="flex justify-center mb-6">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
            <CheckCircle className="h-8 w-8 text-green-600" />
          </div>
        </div>
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white mb-2">Check your email</h2>
        <p className="text-slate-500 mb-6">
          We&apos;ve sent a password reset link to<br />
          <span className="font-medium text-slate-900">{submittedEmail}</span>
        </p>
        <p className="text-sm text-slate-500 mb-8">
          Didn&apos;t receive the email? Check your spam folder or{" "}
          <button 
            onClick={() => setIsSubmitted(false)} 
            className="text-blue-600 hover:underline"
          >
            try again
          </button>
        </p>
        <Link href="/login">
          <Button variant="outline" className="gap-2">
            <ArrowLeft className="h-4 w-4" />
            Back to Sign In
          </Button>
        </Link>
      </div>
    );
  }

  return (
    <div>
      <Link href="/login" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-8">
        <ArrowLeft className="h-4 w-4" />
        Back to Sign In
      </Link>

      <div className="mb-8">
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white">Forgot your password?</h2>
        <p className="text-slate-500 mt-2">
          No worries! Enter your email and we&apos;ll send you a reset link.
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        {/* Email */}
        <div className="space-y-2">
          <Label htmlFor="email" error={!!errors.email}>Email</Label>
          <div className="relative">
            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="email"
              type="email"
              placeholder="you@example.com"
              className="pl-10"
              error={!!errors.email}
              {...register("email")}
            />
          </div>
          {errors.email && <p className="text-sm text-red-500">{errors.email.message}</p>}
        </div>

        {/* Submit */}
        <Button type="submit" className="w-full" size="lg" loading={isLoading}>
          Send Reset Link
        </Button>
      </form>
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} forgot-password page"

# =============================================================================
# RESET PASSWORD PAGE
# =============================================================================
cat > "src/app/(auth)/reset-password/page.tsx" << 'EOF'
"use client";

import { useState, Suspense } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Eye, EyeOff, Lock, CheckCircle, ArrowLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { authApi } from "@/lib/api";
import { toast } from "sonner";

const resetPasswordSchema = z.object({
  password: z.string()
    .min(8, "Password must be at least 8 characters")
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
    .regex(/[a-z]/, "Password must contain at least one lowercase letter")
    .regex(/[0-9]/, "Password must contain at least one number"),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ["confirmPassword"],
});

type ResetPasswordForm = z.infer<typeof resetPasswordSchema>;

function ResetPasswordContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const token = searchParams.get("token");
  
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  const { register, handleSubmit, formState: { errors } } = useForm<ResetPasswordForm>({
    resolver: zodResolver(resetPasswordSchema),
  });

  const onSubmit = async (data: ResetPasswordForm) => {
    if (!token) {
      toast.error("Invalid reset link");
      return;
    }

    setIsLoading(true);
    try {
      await authApi.resetPassword({ token, password: data.password });
      setIsSuccess(true);
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to reset password. The link may have expired.");
    } finally {
      setIsLoading(false);
    }
  };

  if (!token) {
    return (
      <div className="text-center">
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white mb-4">Invalid Reset Link</h2>
        <p className="text-slate-500 mb-6">
          This password reset link is invalid or has expired.
        </p>
        <Link href="/forgot-password">
          <Button>Request New Link</Button>
        </Link>
      </div>
    );
  }

  if (isSuccess) {
    return (
      <div className="text-center">
        <div className="flex justify-center mb-6">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-green-100">
            <CheckCircle className="h-8 w-8 text-green-600" />
          </div>
        </div>
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white mb-2">Password Reset!</h2>
        <p className="text-slate-500 mb-8">
          Your password has been successfully reset. You can now sign in with your new password.
        </p>
        <Link href="/login">
          <Button size="lg">Sign In</Button>
        </Link>
      </div>
    );
  }

  return (
    <div>
      <Link href="/login" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-8">
        <ArrowLeft className="h-4 w-4" />
        Back to Sign In
      </Link>

      <div className="mb-8">
        <h2 className="text-2xl font-bold text-slate-900 dark:text-white">Set new password</h2>
        <p className="text-slate-500 mt-2">
          Create a strong password for your account.
        </p>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
        {/* Password */}
        <div className="space-y-2">
          <Label htmlFor="password" error={!!errors.password}>New Password</Label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="password"
              type={showPassword ? "text" : "password"}
              placeholder="••••••••"
              className="pl-10 pr-10"
              error={!!errors.password}
              {...register("password")}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
            </button>
          </div>
          {errors.password && <p className="text-sm text-red-500">{errors.password.message}</p>}
        </div>

        {/* Confirm Password */}
        <div className="space-y-2">
          <Label htmlFor="confirmPassword" error={!!errors.confirmPassword}>Confirm Password</Label>
          <div className="relative">
            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
            <Input
              id="confirmPassword"
              type={showConfirmPassword ? "text" : "password"}
              placeholder="••••••••"
              className="pl-10 pr-10"
              error={!!errors.confirmPassword}
              {...register("confirmPassword")}
            />
            <button
              type="button"
              onClick={() => setShowConfirmPassword(!showConfirmPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
            >
              {showConfirmPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
            </button>
          </div>
          {errors.confirmPassword && <p className="text-sm text-red-500">{errors.confirmPassword.message}</p>}
        </div>

        {/* Submit */}
        <Button type="submit" className="w-full" size="lg" loading={isLoading}>
          Reset Password
        </Button>
      </form>
    </div>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <ResetPasswordContent />
    </Suspense>
  );
}
EOF
echo -e "${GREEN}✓${NC} reset-password page"

echo -e "${GREEN}✓ Auth pages created${NC}"