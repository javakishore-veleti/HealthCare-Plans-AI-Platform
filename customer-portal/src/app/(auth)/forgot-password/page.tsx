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
