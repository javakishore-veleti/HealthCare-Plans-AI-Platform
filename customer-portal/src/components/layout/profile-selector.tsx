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
