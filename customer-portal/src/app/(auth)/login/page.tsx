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
