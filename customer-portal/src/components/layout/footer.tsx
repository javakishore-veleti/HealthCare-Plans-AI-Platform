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
