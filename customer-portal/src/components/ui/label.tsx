"use client";

import * as React from "react";
import * as LabelPrimitive from "@radix-ui/react-label";
import { cn } from "@/lib/utils";

interface LabelProps extends React.ComponentPropsWithoutRef<typeof LabelPrimitive.Root> {
  error?: boolean;
}

const Label = React.forwardRef<React.ElementRef<typeof LabelPrimitive.Root>, LabelProps>(({ className, error, ...props }, ref) => (
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