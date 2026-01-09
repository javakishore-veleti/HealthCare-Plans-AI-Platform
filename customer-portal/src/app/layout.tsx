import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Providers } from "@/lib/providers";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: {
    default: "HealthCare Plans - Find Your Perfect Coverage",
    template: "%s | HealthCare Plans",
  },
  description: "Find and compare healthcare plans for you and your family. Get quotes, enroll online, and manage your coverage all in one place.",
  keywords: ["healthcare", "insurance", "health plans", "medical coverage", "enrollment"],
  authors: [{ name: "HealthCare Plans" }],
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://healthcare-plans.com",
    siteName: "HealthCare Plans",
    title: "HealthCare Plans - Find Your Perfect Coverage",
    description: "Find and compare healthcare plans for you and your family.",
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
