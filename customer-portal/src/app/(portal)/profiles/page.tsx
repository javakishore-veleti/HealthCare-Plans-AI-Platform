"use client";

import Link from "next/link";
import { Plus, User, Edit, Trash2, Star } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useAuthStore, MAX_PROFILES } from "@/store";
import { formatDate, getInitials, calculateAge } from "@/lib/utils";

export default function ProfilesPage() {
  const { profiles, canAddProfile } = useAuthStore();

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold text-slate-900 dark:text-white">My Profiles</h1>
          <p className="text-slate-500 mt-1">
            Manage profiles for yourself and family members ({profiles.length}/{MAX_PROFILES})
          </p>
        </div>
        {canAddProfile() && (
          <Link href="/profiles/new">
            <Button className="gap-2">
              <Plus className="h-4 w-4" />
              Add Profile
            </Button>
          </Link>
        )}
      </div>

      {/* Profiles Grid */}
      {profiles.length === 0 ? (
        <Card>
          <CardContent className="py-16 text-center">
            <div className="flex justify-center mb-6">
              <div className="flex h-20 w-20 items-center justify-center rounded-full bg-slate-100">
                <User className="h-10 w-10 text-slate-400" />
              </div>
            </div>
            <h2 className="text-xl font-semibold mb-2">No profiles yet</h2>
            <p className="text-slate-500 mb-6">
              Create your first profile to start shopping for healthcare plans.
            </p>
            <Link href="/profiles/new">
              <Button>Create Profile</Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {profiles.map((profile) => (
            <Card key={profile.id} className="hover:shadow-md transition-shadow">
              <CardContent className="pt-6">
                <div className="flex items-start gap-4">
                  <Avatar className="h-14 w-14">
                    <AvatarFallback className="text-lg">
                      {getInitials(profile.firstName, profile.lastName)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2">
                      <h3 className="font-semibold truncate">
                        {profile.firstName} {profile.lastName}
                      </h3>
                      {profile.isPrimary && (
                        <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
                      )}
                    </div>
                    <p className="text-sm text-slate-500">{profile.relationship}</p>
                    <div className="flex gap-2 mt-2">
                      <Badge variant="secondary">
                        {calculateAge(profile.dateOfBirth)} years old
                      </Badge>
                      <Badge variant="outline">{profile.gender}</Badge>
                    </div>
                  </div>
                </div>

                <div className="mt-4 pt-4 border-t flex gap-2">
                  <Link href={`/profiles/${profile.id}`} className="flex-1">
                    <Button variant="outline" className="w-full gap-1" size="sm">
                      <Edit className="h-4 w-4" />
                      Edit
                    </Button>
                  </Link>
                  {!profile.isPrimary && (
                    <Button
                      variant="outline"
                      size="sm"
                      className="text-red-500 hover:text-red-700 hover:bg-red-50"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
