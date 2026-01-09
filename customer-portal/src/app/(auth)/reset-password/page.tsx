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
