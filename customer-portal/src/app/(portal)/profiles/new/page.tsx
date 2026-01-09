"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { ArrowLeft } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useAuthStore, MAX_PROFILES } from "@/store";
import { profilesApi } from "@/lib/api";
import { toast } from "sonner";

const profileSchema = z.object({
  firstName: z.string().min(2, "First name must be at least 2 characters"),
  lastName: z.string().min(2, "Last name must be at least 2 characters"),
  dateOfBirth: z.string().min(1, "Date of birth is required"),
  gender: z.enum(["MALE", "FEMALE", "OTHER"], { required_error: "Gender is required" }),
  relationship: z.enum(["SELF", "SPOUSE", "CHILD", "PARENT", "SIBLING", "OTHER"], { required_error: "Relationship is required" }),
  email: z.string().email().optional().or(z.literal("")),
  phone: z.string().optional(),
  street1: z.string().optional(),
  street2: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  zipCode: z.string().optional(),
});

type ProfileForm = z.infer<typeof profileSchema>;

export default function NewProfilePage() {
  const router = useRouter();
  const { profiles, addProfile, canAddProfile } = useAuthStore();
  const [isLoading, setIsLoading] = useState(false);

  const { register, handleSubmit, formState: { errors }, setValue, watch } = useForm<ProfileForm>({
    resolver: zodResolver(profileSchema),
  });

  if (!canAddProfile()) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h1 className="text-2xl font-bold mb-4">Maximum Profiles Reached</h1>
        <p className="text-slate-500 mb-6">
          You have reached the maximum of {MAX_PROFILES} profiles.
        </p>
        <Link href="/profiles">
          <Button>Back to Profiles</Button>
        </Link>
      </div>
    );
  }

  const onSubmit = async (data: ProfileForm) => {
    setIsLoading(true);
    try {
      const profileData = {
        ...data,
        isPrimary: profiles.length === 0,
        address: data.street1 ? {
          street1: data.street1,
          street2: data.street2,
          city: data.city,
          state: data.state,
          zipCode: data.zipCode,
        } : undefined,
      };

      const response = await profilesApi.create(profileData);
      addProfile(response.data);
      toast.success("Profile created successfully!");
      router.push("/profiles");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to create profile");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-2xl">
      <Link href="/profiles" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-6">
        <ArrowLeft className="h-4 w-4" />
        Back to Profiles
      </Link>

      <Card>
        <CardHeader>
          <CardTitle>Create New Profile</CardTitle>
          <CardDescription>
            Add a family member or dependent to shop for healthcare plans.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            {/* Basic Info */}
            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="firstName" error={!!errors.firstName}>First Name *</Label>
                <Input id="firstName" error={!!errors.firstName} {...register("firstName")} />
                {errors.firstName && <p className="text-xs text-red-500">{errors.firstName.message}</p>}
              </div>
              <div className="space-y-2">
                <Label htmlFor="lastName" error={!!errors.lastName}>Last Name *</Label>
                <Input id="lastName" error={!!errors.lastName} {...register("lastName")} />
                {errors.lastName && <p className="text-xs text-red-500">{errors.lastName.message}</p>}
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-3">
              <div className="space-y-2">
                <Label htmlFor="dateOfBirth" error={!!errors.dateOfBirth}>Date of Birth *</Label>
                <Input id="dateOfBirth" type="date" error={!!errors.dateOfBirth} {...register("dateOfBirth")} />
                {errors.dateOfBirth && <p className="text-xs text-red-500">{errors.dateOfBirth.message}</p>}
              </div>
              <div className="space-y-2">
                <Label error={!!errors.gender}>Gender *</Label>
                <Select onValueChange={(value) => setValue("gender", value as any)}>
                  <SelectTrigger error={!!errors.gender}>
                    <SelectValue placeholder="Select gender" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="MALE">Male</SelectItem>
                    <SelectItem value="FEMALE">Female</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
                {errors.gender && <p className="text-xs text-red-500">{errors.gender.message}</p>}
              </div>
              <div className="space-y-2">
                <Label error={!!errors.relationship}>Relationship *</Label>
                <Select onValueChange={(value) => setValue("relationship", value as any)}>
                  <SelectTrigger error={!!errors.relationship}>
                    <SelectValue placeholder="Select relationship" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="SELF">Self</SelectItem>
                    <SelectItem value="SPOUSE">Spouse</SelectItem>
                    <SelectItem value="CHILD">Child</SelectItem>
                    <SelectItem value="PARENT">Parent</SelectItem>
                    <SelectItem value="SIBLING">Sibling</SelectItem>
                    <SelectItem value="OTHER">Other</SelectItem>
                  </SelectContent>
                </Select>
                {errors.relationship && <p className="text-xs text-red-500">{errors.relationship.message}</p>}
              </div>
            </div>

            {/* Contact Info */}
            <div className="border-t pt-6">
              <h3 className="font-medium mb-4">Contact Information (Optional)</h3>
              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" type="email" {...register("email")} />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone</Label>
                  <Input id="phone" type="tel" {...register("phone")} />
                </div>
              </div>
            </div>

            {/* Address */}
            <div className="border-t pt-6">
              <h3 className="font-medium mb-4">Address (Optional)</h3>
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="street1">Street Address</Label>
                  <Input id="street1" {...register("street1")} />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="street2">Apt, Suite, etc.</Label>
                  <Input id="street2" {...register("street2")} />
                </div>
                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2">
                    <Label htmlFor="city">City</Label>
                    <Input id="city" {...register("city")} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="state">State</Label>
                    <Input id="state" {...register("state")} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="zipCode">ZIP Code</Label>
                    <Input id="zipCode" {...register("zipCode")} />
                  </div>
                </div>
              </div>
            </div>

            {/* Actions */}
            <div className="flex gap-4 pt-4">
              <Button type="submit" loading={isLoading}>
                Create Profile
              </Button>
              <Link href="/profiles">
                <Button type="button" variant="outline">Cancel</Button>
              </Link>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
