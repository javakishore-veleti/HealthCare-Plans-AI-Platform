#!/bin/bash
set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}[5/8] Creating UI components...${NC}"

cd customer-portal
mkdir -p src/components/ui src/components/layout src/components/forms

# =============================================================================
# BUTTON
# =============================================================================
cat > src/components/ui/button.tsx << 'EOF'
import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";
import { Loader2 } from "lucide-react";

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-lg text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-blue-600 text-white hover:bg-blue-700",
        destructive: "bg-red-600 text-white hover:bg-red-700",
        outline: "border border-slate-300 bg-white hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900 dark:hover:bg-slate-800",
        secondary: "bg-slate-100 text-slate-900 hover:bg-slate-200 dark:bg-slate-800 dark:text-slate-100",
        ghost: "hover:bg-slate-100 dark:hover:bg-slate-800",
        link: "text-blue-600 underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-12 rounded-lg px-8 text-base",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  }
);

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement>, VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  loading?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, loading, children, disabled, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        disabled={disabled || loading}
        {...props}
      >
        {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
        {children}
      </Comp>
    );
  }
);
Button.displayName = "Button";

export { Button, buttonVariants };
EOF
echo -e "${GREEN}✓${NC} button.tsx"

# =============================================================================
# INPUT
# =============================================================================
cat > src/components/ui/input.tsx << 'EOF'
import * as React from "react";
import { cn } from "@/lib/utils";

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  error?: boolean;
}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, error, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-10 w-full rounded-lg border bg-white px-3 py-2 text-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-slate-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-slate-900",
          error
            ? "border-red-500 focus-visible:ring-red-500"
            : "border-slate-300 dark:border-slate-700",
          className
        )}
        ref={ref}
        {...props}
      />
    );
  }
);
Input.displayName = "Input";

export { Input };
EOF
echo -e "${GREEN}✓${NC} input.tsx"

# =============================================================================
# LABEL
# =============================================================================
cat > src/components/ui/label.tsx << 'EOF'
"use client";

import * as React from "react";
import * as LabelPrimitive from "@radix-ui/react-label";
import { cn } from "@/lib/utils";

const Label = React.forwardRef
  React.ElementRef<typeof LabelPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof LabelPrimitive.Root> & { error?: boolean }
>(({ className, error, ...props }, ref) => (
  <LabelPrimitive.Root
    ref={ref}
    className={cn(
      "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
      error && "text-red-500",
      className
    )}
    {...props}
  />
));
Label.displayName = LabelPrimitive.Root.displayName;

export { Label };
EOF
echo -e "${GREEN}✓${NC} label.tsx"

# =============================================================================
# CARD
# =============================================================================
cat > src/components/ui/card.tsx << 'EOF'
import * as React from "react";
import { cn } from "@/lib/utils";

const Card = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("rounded-xl border border-slate-200 bg-white shadow-sm dark:border-slate-800 dark:bg-slate-900", className)}
      {...props}
    />
  )
);
Card.displayName = "Card";

const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex flex-col space-y-1.5 p-6", className)} {...props} />
  )
);
CardHeader.displayName = "CardHeader";

const CardTitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, ...props }, ref) => (
    <h3 ref={ref} className={cn("text-xl font-semibold leading-none tracking-tight", className)} {...props} />
  )
);
CardTitle.displayName = "CardTitle";

const CardDescription = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLParagraphElement>>(
  ({ className, ...props }, ref) => (
    <p ref={ref} className={cn("text-sm text-slate-500 dark:text-slate-400", className)} {...props} />
  )
);
CardDescription.displayName = "CardDescription";

const CardContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
);
CardContent.displayName = "CardContent";

const CardFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex items-center p-6 pt-0", className)} {...props} />
  )
);
CardFooter.displayName = "CardFooter";

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent };
EOF
echo -e "${GREEN}✓${NC} card.tsx"

# =============================================================================
# BADGE
# =============================================================================
cat > src/components/ui/badge.tsx << 'EOF'
import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const badgeVariants = cva(
  "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors",
  {
    variants: {
      variant: {
        default: "border-transparent bg-blue-600 text-white",
        secondary: "border-transparent bg-slate-100 text-slate-900 dark:bg-slate-800 dark:text-slate-100",
        destructive: "border-transparent bg-red-600 text-white",
        outline: "border-slate-300 text-slate-900 dark:border-slate-700 dark:text-slate-100",
        success: "border-transparent bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100",
        warning: "border-transparent bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-100",
      },
    },
    defaultVariants: { variant: "default" },
  }
);

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return <div className={cn(badgeVariants({ variant }), className)} {...props} />;
}

export { Badge, badgeVariants };
EOF
echo -e "${GREEN}✓${NC} badge.tsx"

# =============================================================================
# AVATAR
# =============================================================================
cat > src/components/ui/avatar.tsx << 'EOF'
"use client";

import * as React from "react";
import * as AvatarPrimitive from "@radix-ui/react-avatar";
import { cn } from "@/lib/utils";

const Avatar = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Root
    ref={ref}
    className={cn("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", className)}
    {...props}
  />
));
Avatar.displayName = AvatarPrimitive.Root.displayName;

const AvatarImage = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Image>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Image ref={ref} className={cn("aspect-square h-full w-full", className)} {...props} />
));
AvatarImage.displayName = AvatarPrimitive.Image.displayName;

const AvatarFallback = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Fallback>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Fallback
    ref={ref}
    className={cn("flex h-full w-full items-center justify-center rounded-full bg-blue-100 text-blue-600 font-medium", className)}
    {...props}
  />
));
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName;

export { Avatar, AvatarImage, AvatarFallback };
EOF
echo -e "${GREEN}✓${NC} avatar.tsx"

# =============================================================================
# SKELETON
# =============================================================================
cat > src/components/ui/skeleton.tsx << 'EOF'
import { cn } from "@/lib/utils";

function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("animate-pulse rounded-md bg-slate-200 dark:bg-slate-800", className)} {...props} />;
}

export { Skeleton };
EOF
echo -e "${GREEN}✓${NC} skeleton.tsx"

# =============================================================================
# SELECT
# =============================================================================
cat > src/components/ui/select.tsx << 'EOF'
"use client";

import * as React from "react";
import * as SelectPrimitive from "@radix-ui/react-select";
import { Check, ChevronDown } from "lucide-react";
import { cn } from "@/lib/utils";

const Select = SelectPrimitive.Root;
const SelectGroup = SelectPrimitive.Group;
const SelectValue = SelectPrimitive.Value;

const SelectTrigger = React.forwardRef
  React.ElementRef<typeof SelectPrimitive.Trigger>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Trigger> & { error?: boolean }
>(({ className, children, error, ...props }, ref) => (
  <SelectPrimitive.Trigger
    ref={ref}
    className={cn(
      "flex h-10 w-full items-center justify-between rounded-lg border bg-white px-3 py-2 text-sm placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50 dark:bg-slate-900",
      error ? "border-red-500" : "border-slate-300 dark:border-slate-700",
      className
    )}
    {...props}
  >
    {children}
    <SelectPrimitive.Icon asChild>
      <ChevronDown className="h-4 w-4 opacity-50" />
    </SelectPrimitive.Icon>
  </SelectPrimitive.Trigger>
));
SelectTrigger.displayName = SelectPrimitive.Trigger.displayName;

const SelectContent = React.forwardRef
  React.ElementRef<typeof SelectPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Content>
>(({ className, children, position = "popper", ...props }, ref) => (
  <SelectPrimitive.Portal>
    <SelectPrimitive.Content
      ref={ref}
      className={cn(
        "relative z-50 min-w-[8rem] overflow-hidden rounded-lg border border-slate-200 bg-white shadow-md dark:border-slate-800 dark:bg-slate-900",
        position === "popper" && "translate-y-1",
        className
      )}
      position={position}
      {...props}
    >
      <SelectPrimitive.Viewport className={cn("p-1", position === "popper" && "h-[var(--radix-select-trigger-height)] w-full min-w-[var(--radix-select-trigger-width)]")}>
        {children}
      </SelectPrimitive.Viewport>
    </SelectPrimitive.Content>
  </SelectPrimitive.Portal>
));
SelectContent.displayName = SelectPrimitive.Content.displayName;

const SelectItem = React.forwardRef
  React.ElementRef<typeof SelectPrimitive.Item>,
  React.ComponentPropsWithoutRef<typeof SelectPrimitive.Item>
>(({ className, children, ...props }, ref) => (
  <SelectPrimitive.Item
    ref={ref}
    className={cn(
      "relative flex w-full cursor-pointer select-none items-center rounded-md py-2 pl-8 pr-2 text-sm outline-none focus:bg-slate-100 data-[disabled]:pointer-events-none data-[disabled]:opacity-50 dark:focus:bg-slate-800",
      className
    )}
    {...props}
  >
    <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
      <SelectPrimitive.ItemIndicator>
        <Check className="h-4 w-4" />
      </SelectPrimitive.ItemIndicator>
    </span>
    <SelectPrimitive.ItemText>{children}</SelectPrimitive.ItemText>
  </SelectPrimitive.Item>
));
SelectItem.displayName = SelectPrimitive.Item.displayName;

export { Select, SelectGroup, SelectValue, SelectTrigger, SelectContent, SelectItem };
EOF
echo -e "${GREEN}✓${NC} select.tsx"

# =============================================================================
# CHECKBOX
# =============================================================================
cat > src/components/ui/checkbox.tsx << 'EOF'
"use client";

import * as React from "react";
import * as CheckboxPrimitive from "@radix-ui/react-checkbox";
import { Check } from "lucide-react";
import { cn } from "@/lib/utils";

const Checkbox = React.forwardRef
  React.ElementRef<typeof CheckboxPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof CheckboxPrimitive.Root>
>(({ className, ...props }, ref) => (
  <CheckboxPrimitive.Root
    ref={ref}
    className={cn(
      "peer h-5 w-5 shrink-0 rounded border border-slate-300 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50 data-[state=checked]:bg-blue-600 data-[state=checked]:border-blue-600 data-[state=checked]:text-white dark:border-slate-700",
      className
    )}
    {...props}
  >
    <CheckboxPrimitive.Indicator className={cn("flex items-center justify-center text-current")}>
      <Check className="h-4 w-4" />
    </CheckboxPrimitive.Indicator>
  </CheckboxPrimitive.Root>
));
Checkbox.displayName = CheckboxPrimitive.Root.displayName;

export { Checkbox };
EOF
echo -e "${GREEN}✓${NC} checkbox.tsx"

# =============================================================================
# DIALOG
# =============================================================================
cat > src/components/ui/dialog.tsx << 'EOF'
"use client";

import * as React from "react";
import * as DialogPrimitive from "@radix-ui/react-dialog";
import { X } from "lucide-react";
import { cn } from "@/lib/utils";

const Dialog = DialogPrimitive.Root;
const DialogTrigger = DialogPrimitive.Trigger;
const DialogPortal = DialogPrimitive.Portal;
const DialogClose = DialogPrimitive.Close;

const DialogOverlay = React.forwardRef
  React.ElementRef<typeof DialogPrimitive.Overlay>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Overlay>
>(({ className, ...props }, ref) => (
  <DialogPrimitive.Overlay
    ref={ref}
    className={cn("fixed inset-0 z-50 bg-black/50 backdrop-blur-sm", className)}
    {...props}
  />
));
DialogOverlay.displayName = DialogPrimitive.Overlay.displayName;

const DialogContent = React.forwardRef
  React.ElementRef<typeof DialogPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Content>
>(({ className, children, ...props }, ref) => (
  <DialogPortal>
    <DialogOverlay />
    <DialogPrimitive.Content
      ref={ref}
      className={cn(
        "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 border border-slate-200 bg-white p-6 shadow-lg rounded-xl dark:border-slate-800 dark:bg-slate-900",
        className
      )}
      {...props}
    >
      {children}
      <DialogPrimitive.Close className="absolute right-4 top-4 rounded-sm opacity-70 hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-blue-500">
        <X className="h-4 w-4" />
        <span className="sr-only">Close</span>
      </DialogPrimitive.Close>
    </DialogPrimitive.Content>
  </DialogPortal>
));
DialogContent.displayName = DialogPrimitive.Content.displayName;

const DialogHeader = ({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) => (
  <div className={cn("flex flex-col space-y-1.5 text-center sm:text-left", className)} {...props} />
);
DialogHeader.displayName = "DialogHeader";

const DialogFooter = ({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) => (
  <div className={cn("flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", className)} {...props} />
);
DialogFooter.displayName = "DialogFooter";

const DialogTitle = React.forwardRef
  React.ElementRef<typeof DialogPrimitive.Title>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Title>
>(({ className, ...props }, ref) => (
  <DialogPrimitive.Title ref={ref} className={cn("text-lg font-semibold leading-none tracking-tight", className)} {...props} />
));
DialogTitle.displayName = DialogPrimitive.Title.displayName;

const DialogDescription = React.forwardRef
  React.ElementRef<typeof DialogPrimitive.Description>,
  React.ComponentPropsWithoutRef<typeof DialogPrimitive.Description>
>(({ className, ...props }, ref) => (
  <DialogPrimitive.Description ref={ref} className={cn("text-sm text-slate-500 dark:text-slate-400", className)} {...props} />
));
DialogDescription.displayName = DialogPrimitive.Description.displayName;

export { Dialog, DialogPortal, DialogOverlay, DialogClose, DialogTrigger, DialogContent, DialogHeader, DialogFooter, DialogTitle, DialogDescription };
EOF
echo -e "${GREEN}✓${NC} dialog.tsx"

# =============================================================================
# COMPONENTS INDEX
# =============================================================================
cat > src/components/ui/index.ts << 'EOF'
export { Button, buttonVariants } from "./button";
export { Input } from "./input";
export { Label } from "./label";
export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent } from "./card";
export { Badge, badgeVariants } from "./badge";
export { Avatar, AvatarImage, AvatarFallback } from "./avatar";
export { Skeleton } from "./skeleton";
export { Select, SelectGroup, SelectValue, SelectTrigger, SelectContent, SelectItem } from "./select";
export { Checkbox } from "./checkbox";
export { Dialog, DialogPortal, DialogOverlay, DialogClose, DialogTrigger, DialogContent, DialogHeader, DialogFooter, DialogTitle, DialogDescription } from "./dialog";
EOF
echo -e "${GREEN}✓${NC} ui/index.ts"

# =============================================================================
# PROFILE SELECTOR COMPONENT
# =============================================================================
cat > src/components/layout/profile-selector.tsx << 'EOF'
"use client";

import { useState } from "react";
import { ChevronDown, Plus, User, Check } from "lucide-react";
import { useAuthStore } from "@/store";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { cn, getInitials } from "@/lib/utils";
import Link from "next/link";

export function ProfileSelector() {
  const [open, setOpen] = useState(false);
  const { profiles, activeProfileId, setActiveProfile, getActiveProfile, canAddProfile } = useAuthStore();
  const activeProfile = getActiveProfile();

  if (!activeProfile) return null;

  return (
    <div className="relative">
      <button
        onClick={() => setOpen(!open)}
        className="flex items-center gap-3 rounded-lg border border-slate-200 bg-white px-3 py-2 hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-900"
      >
        <Avatar className="h-8 w-8">
          <AvatarFallback className="text-xs">
            {getInitials(activeProfile.firstName, activeProfile.lastName)}
          </AvatarFallback>
        </Avatar>
        <div className="text-left">
          <p className="text-sm font-medium">{activeProfile.firstName} {activeProfile.lastName}</p>
          <p className="text-xs text-slate-500">{activeProfile.relationship}</p>
        </div>
        <ChevronDown className={cn("h-4 w-4 text-slate-400 transition-transform", open && "rotate-180")} />
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setOpen(false)} />
          <div className="absolute right-0 top-full z-50 mt-2 w-72 rounded-xl border border-slate-200 bg-white shadow-lg dark:border-slate-800 dark:bg-slate-900">
            <div className="p-2">
              <p className="px-3 py-2 text-xs font-medium text-slate-500 uppercase">Select Profile</p>
              {profiles.map((profile) => (
                <button
                  key={profile.id}
                  onClick={() => {
                    setActiveProfile(profile.id);
                    setOpen(false);
                  }}
                  className={cn(
                    "flex w-full items-center gap-3 rounded-lg px-3 py-2 hover:bg-slate-100 dark:hover:bg-slate-800",
                    activeProfileId === profile.id && "bg-blue-50 dark:bg-blue-900/20"
                  )}
                >
                  <Avatar className="h-8 w-8">
                    <AvatarFallback className="text-xs">
                      {getInitials(profile.firstName, profile.lastName)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 text-left">
                    <p className="text-sm font-medium">{profile.firstName} {profile.lastName}</p>
                    <p className="text-xs text-slate-500">{profile.relationship}</p>
                  </div>
                  {activeProfileId === profile.id && (
                    <Check className="h-4 w-4 text-blue-600" />
                  )}
                  {profile.isPrimary && (
                    <span className="text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">Primary</span>
                  )}
                </button>
              ))}
            </div>
            {canAddProfile() && (
              <div className="border-t border-slate-200 p-2 dark:border-slate-800">
                <Link href="/profiles/new" onClick={() => setOpen(false)}>
                  <Button variant="ghost" className="w-full justify-start gap-2">
                    <Plus className="h-4 w-4" />
                    Add New Profile
                  </Button>
                </Link>
              </div>
            )}
            <div className="border-t border-slate-200 p-2 dark:border-slate-800">
              <Link href="/profiles" onClick={() => setOpen(false)}>
                <Button variant="ghost" className="w-full justify-start gap-2">
                  <User className="h-4 w-4" />
                  Manage Profiles
                </Button>
              </Link>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
EOF
echo -e "${GREEN}✓${NC} profile-selector.tsx"

# =============================================================================
# HEADER
# =============================================================================
cat > src/components/layout/header.tsx << 'EOF'
"use client";

import Link from "next/link";
import { ShoppingCart, Heart, User, LogOut, Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { ProfileSelector } from "./profile-selector";
import { useAuthStore, useCartStore } from "@/store";
import { useAuth } from "@/hooks";
import { getInitials } from "@/lib/utils";
import { useState } from "react";

export function Header() {
  const [menuOpen, setMenuOpen] = useState(false);
  const { user, isAuthenticated } = useAuthStore();
  const { getItemCount } = useCartStore();
  const { logout } = useAuth(false);
  const cartCount = getItemCount();

  return (
    <header className="sticky top-0 z-50 border-b border-slate-200 bg-white/95 backdrop-blur dark:border-slate-800 dark:bg-slate-900/95">
      <div className="container mx-auto flex h-16 items-center justify-between px-4">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2">
          <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
            <Heart className="h-5 w-5 text-white" />
          </div>
          <span className="text-xl font-bold text-slate-900 dark:text-white">Your Care</span>
        </Link>

        {/* Navigation - Desktop */}
        <nav className="hidden md:flex items-center gap-6">
          <Link href="/shop" className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white">
            Browse Plans
          </Link>
          {isAuthenticated && (
            <>
              <Link href="/orders" className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white">
                My Orders
              </Link>
              <Link href="/quotes" className="text-sm font-medium text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-white">
                My Quotes
              </Link>
            </>
          )}
        </nav>

        {/* Actions */}
        <div className="flex items-center gap-3">
          {isAuthenticated ? (
            <>
              {/* Profile Selector */}
              <div className="hidden md:block">
                <ProfileSelector />
              </div>

              {/* Cart */}
              <Link href="/cart">
                <Button variant="ghost" size="icon" className="relative">
                  <ShoppingCart className="h-5 w-5" />
                  {cartCount > 0 && (
                    <Badge className="absolute -right-1 -top-1 h-5 w-5 rounded-full p-0 flex items-center justify-center text-xs">
                      {cartCount}
                    </Badge>
                  )}
                </Button>
              </Link>

              {/* User Menu */}
              <div className="relative">
                <button
                  onClick={() => setMenuOpen(!menuOpen)}
                  className="flex items-center gap-2"
                >
                  <Avatar className="h-9 w-9">
                    <AvatarFallback>
                      {user ? getInitials(user.firstName, user.lastName) : "U"}
                    </AvatarFallback>
                  </Avatar>
                </button>

                {menuOpen && (
                  <>
                    <div className="fixed inset-0 z-40" onClick={() => setMenuOpen(false)} />
                    <div className="absolute right-0 top-full z-50 mt-2 w-56 rounded-xl border border-slate-200 bg-white py-2 shadow-lg dark:border-slate-800 dark:bg-slate-900">
                      <div className="px-4 py-2 border-b border-slate-200 dark:border-slate-800">
                        <p className="font-medium">{user?.firstName} {user?.lastName}</p>
                        <p className="text-sm text-slate-500">{user?.email}</p>
                      </div>
                      <Link href="/dashboard" className="flex items-center gap-2 px-4 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-800" onClick={() => setMenuOpen(false)}>
                        <User className="h-4 w-4" />
                        Dashboard
                      </Link>
                      <Link href="/profiles" className="flex items-center gap-2 px-4 py-2 text-sm hover:bg-slate-100 dark:hover:bg-slate-800" onClick={() => setMenuOpen(false)}>
                        <User className="h-4 w-4" />
                        Manage Profiles
                      </Link>
                      <button onClick={() => { logout(); setMenuOpen(false); }} className="flex w-full items-center gap-2 px-4 py-2 text-sm text-red-600 hover:bg-slate-100 dark:hover:bg-slate-800">
                        <LogOut className="h-4 w-4" />
                        Sign Out
                      </button>
                    </div>
                  </>
                )}
              </div>
            </>
          ) : (
            <>
              <Link href="/login">
                <Button variant="ghost">Sign In</Button>
              </Link>
              <Link href="/signup">
                <Button>Get Started</Button>
              </Link>
            </>
          )}

          {/* Mobile Menu */}
          <Button variant="ghost" size="icon" className="md:hidden">
            <Menu className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
EOF
echo -e "${GREEN}✓${NC} header.tsx"

# =============================================================================
# FOOTER
# =============================================================================
cat > src/components/layout/footer.tsx << 'EOF'
import Link from "next/link";
import { Heart } from "lucide-react";

export function Footer() {
  return (
    <footer className="border-t border-slate-200 bg-slate-50 dark:border-slate-800 dark:bg-slate-900">
      <div className="container mx-auto px-4 py-12">
        <div className="grid gap-8 md:grid-cols-4">
          {/* Brand */}
          <div>
            <Link href="/" className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600">
                <Heart className="h-4 w-4 text-white" />
              </div>
              <span className="font-bold">Your Care</span>
            </Link>
            <p className="mt-4 text-sm text-slate-500">
              Find the perfect Your Care plan for you and your family.
            </p>
          </div>

          {/* Plans */}
          <div>
            <h4 className="font-semibold mb-4">Plans</h4>
            <ul className="space-y-2 text-sm text-slate-500">
              <li><Link href="/shop?tier=BRONZE" className="hover:text-slate-900">Bronze Plans</Link></li>
              <li><Link href="/shop?tier=SILVER" className="hover:text-slate-900">Silver Plans</Link></li>
              <li><Link href="/shop?tier=GOLD" className="hover:text-slate-900">Gold Plans</Link></li>
              <li><Link href="/shop?tier=PLATINUM" className="hover:text-slate-900">Platinum Plans</Link></li>
            </ul>
          </div>

          {/* Support */}
          <div>
            <h4 className="font-semibold mb-4">Support</h4>
            <ul className="space-y-2 text-sm text-slate-500">
              <li><Link href="/help" className="hover:text-slate-900">Help Center</Link></li>
              <li><Link href="/contact" className="hover:text-slate-900">Contact Us</Link></li>
              <li><Link href="/faq" className="hover:text-slate-900">FAQs</Link></li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="font-semibold mb-4">Legal</h4>
            <ul className="space-y-2 text-sm text-slate-500">
              <li><Link href="/privacy" className="hover:text-slate-900">Privacy Policy</Link></li>
              <li><Link href="/terms" className="hover:text-slate-900">Terms of Service</Link></li>
            </ul>
          </div>
        </div>

        <div className="mt-12 border-t border-slate-200 pt-8 text-center text-sm text-slate-500 dark:border-slate-800">
          © {new Date().getFullYear()} HealthCare Plans. All rights reserved.
        </div>
      </div>
    </footer>
  );
}
EOF
echo -e "${GREEN}✓${NC} footer.tsx"

# =============================================================================
# LAYOUT INDEX
# =============================================================================
cat > src/components/layout/index.ts << 'EOF'
export { Header } from "./header";
export { Footer } from "./footer";
export { ProfileSelector } from "./profile-selector";
EOF
echo -e "${GREEN}✓${NC} layout/index.ts"

echo -e "${GREEN}✓ Components created${NC}"