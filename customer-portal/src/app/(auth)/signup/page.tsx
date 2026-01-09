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
