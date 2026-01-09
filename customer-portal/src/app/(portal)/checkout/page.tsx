"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, CreditCard, Building, Check, Loader2, ShieldCheck } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { useCartStore, useAuthStore } from "@/store";
import { ordersApi, paymentsApi } from "@/lib/api";
import { formatCurrency, getMetalTierColor } from "@/lib/utils";
import { toast } from "sonner";

type Step = "review" | "payment" | "confirmation";

export default function CheckoutPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>("review");
  const [isProcessing, setIsProcessing] = useState(false);
  const [orderId, setOrderId] = useState<string | null>(null);
  const [paymentMethod, setPaymentMethod] = useState<"card" | "bank">("card");
  
  const { items, clearCart, getMonthlyTotal, getAnnualTotal } = useCartStore();
  const { profiles, user } = useAuthStore();

  const [cardDetails, setCardDetails] = useState({
    cardNumber: "",
    expiryDate: "",
    cvv: "",
    cardholderName: "",
  });

  const [bankDetails, setBankDetails] = useState({
    accountNumber: "",
    routingNumber: "",
    accountName: "",
  });

  const monthlyTotal = getMonthlyTotal();
  const annualTotal = getAnnualTotal();

  // Group items by profile
  const itemsByProfile = items.reduce((acc, item) => {
    if (!acc[item.profileId]) {
      acc[item.profileId] = [];
    }
    acc[item.profileId].push(item);
    return acc;
  }, {} as Record<string, typeof items>);

  const handleCreateOrder = async () => {
    if (items.length === 0) {
      toast.error("Your cart is empty");
      return;
    }

    setIsProcessing(true);
    try {
      // Create order
      const orderData = {
        customerId: user?.id,
        orderType: "NEW_ENROLLMENT",
        effectiveDate: new Date(new Date().setMonth(new Date().getMonth() + 1)).toISOString().split("T")[0],
        billingFrequency: "MONTHLY",
        items: items.map((item) => ({
          planId: item.planId,
          profileId: item.profileId,
          monthlyPremium: item.monthlyPremium,
        })),
        totalMonthlyPremium: monthlyTotal,
        totalAnnualPremium: annualTotal,
      };

      const orderResponse = await ordersApi.create(orderData);
      setOrderId(orderResponse.data.id);
      setStep("payment");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to create order");
    } finally {
      setIsProcessing(false);
    }
  };

  const handleProcessPayment = async () => {
    if (!orderId) return;

    setIsProcessing(true);
    try {
      const paymentData = {
        orderId,
        amount: monthlyTotal,
        currency: "USD",
        paymentMethod: paymentMethod === "card" ? "CREDIT_CARD" : "ACH",
        ...(paymentMethod === "card" ? {
          cardNumber: cardDetails.cardNumber.replace(/\s/g, ""),
          expiryDate: cardDetails.expiryDate,
          cvv: cardDetails.cvv,
          cardholderName: cardDetails.cardholderName,
        } : {
          accountNumber: bankDetails.accountNumber,
          routingNumber: bankDetails.routingNumber,
          accountName: bankDetails.accountName,
        }),
      };

      await paymentsApi.process(paymentData);
      clearCart();
      setStep("confirmation");
      toast.success("Payment successful!");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Payment failed");
    } finally {
      setIsProcessing(false);
    }
  };

  const formatCardNumber = (value: string) => {
    const v = value.replace(/\s+/g, "").replace(/[^0-9]/gi, "");
    const matches = v.match(/\d{4,16}/g);
    const match = (matches && matches[0]) || "";
    const parts = [];
    for (let i = 0, len = match.length; i < len; i += 4) {
      parts.push(match.substring(i, i + 4));
    }
    return parts.length ? parts.join(" ") : value;
  };

  const formatExpiryDate = (value: string) => {
    const v = value.replace(/\s+/g, "").replace(/[^0-9]/gi, "");
    if (v.length >= 2) {
      return v.substring(0, 2) + "/" + v.substring(2, 4);
    }
    return v;
  };

  if (items.length === 0 && step !== "confirmation") {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h1 className="text-2xl font-bold mb-4">Your cart is empty</h1>
        <p className="text-slate-500 mb-6">Add plans to your cart before checking out.</p>
        <Link href="/shop">
          <Button>Browse Plans</Button>
        </Link>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      {step !== "confirmation" && (
        <Link href="/cart" className="inline-flex items-center gap-2 text-sm text-slate-500 hover:text-slate-900 mb-6">
          <ArrowLeft className="h-4 w-4" />
          Back to Cart
        </Link>
      )}

      {/* Progress Steps */}
      <div className="flex items-center justify-center mb-8">
        {["review", "payment", "confirmation"].map((s, i) => (
          <div key={s} className="flex items-center">
            <div className={`flex items-center justify-center w-8 h-8 rounded-full text-sm font-medium ${
              step === s ? "bg-blue-600 text-white" : 
              ["review", "payment", "confirmation"].indexOf(step) > i ? "bg-green-500 text-white" : 
              "bg-slate-200 text-slate-500"
            }`}>
              {["review", "payment", "confirmation"].indexOf(step) > i ? (
                <Check className="h-4 w-4" />
              ) : (
                i + 1
              )}
            </div>
            <span className={`ml-2 text-sm ${step === s ? "font-medium" : "text-slate-500"}`}>
              {s.charAt(0).toUpperCase() + s.slice(1)}
            </span>
            {i < 2 && <div className="w-16 h-px bg-slate-300 mx-4" />}
          </div>
        ))}
      </div>

      {/* Step: Review */}
      {step === "review" && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Review Your Order</CardTitle>
              <CardDescription>Please review the plans you're enrolling in</CardDescription>
            </CardHeader>
            <CardContent>
              {Object.entries(itemsByProfile).map(([profileId, profileItems]) => {
                const profile = profiles.find((p) => p.id === profileId);
                return (
                  <div key={profileId} className="mb-6 last:mb-0">
                    <h4 className="font-medium mb-3">
                      {profile?.firstName} {profile?.lastName}
                      <span className="text-sm font-normal text-slate-500 ml-2">
                        ({profile?.relationship})
                      </span>
                    </h4>
                    <div className="space-y-2">
                      {profileItems.map((item) => (
                        <div key={item.id} className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
                          <div className="flex items-center gap-3">
                            <Badge className={getMetalTierColor(item.metalTier)}>
                              {item.metalTier}
                            </Badge>
                            <span className="font-medium">{item.planName}</span>
                          </div>
                          <span className="font-semibold">{formatCurrency(item.monthlyPremium)}/mo</span>
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}

              <div className="border-t pt-4 mt-4 space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-500">Monthly Total</span>
                  <span className="font-semibold">{formatCurrency(monthlyTotal)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Annual Total</span>
                  <span>{formatCurrency(annualTotal)}</span>
                </div>
              </div>
            </CardContent>
          </Card>

          <div className="flex justify-end">
            <Button size="lg" onClick={handleCreateOrder} disabled={isProcessing}>
              {isProcessing ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Processing...
                </>
              ) : (
                "Continue to Payment"
              )}
            </Button>
          </div>
        </div>
      )}

      {/* Step: Payment */}
      {step === "payment" && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Payment Information</CardTitle>
              <CardDescription>Choose your payment method</CardDescription>
            </CardHeader>
            <CardContent>
              {/* Payment Method Selection */}
              <div className="flex gap-4 mb-6">
                <button
                  onClick={() => setPaymentMethod("card")}
                  className={`flex-1 p-4 rounded-lg border-2 transition-colors ${
                    paymentMethod === "card" ? "border-blue-500 bg-blue-50" : "border-slate-200"
                  }`}
                >
                  <CreditCard className={`h-6 w-6 mx-auto mb-2 ${paymentMethod === "card" ? "text-blue-600" : "text-slate-400"}`} />
                  <p className="font-medium">Credit/Debit Card</p>
                </button>
                <button
                  onClick={() => setPaymentMethod("bank")}
                  className={`flex-1 p-4 rounded-lg border-2 transition-colors ${
                    paymentMethod === "bank" ? "border-blue-500 bg-blue-50" : "border-slate-200"
                  }`}
                >
                  <Building className={`h-6 w-6 mx-auto mb-2 ${paymentMethod === "bank" ? "text-blue-600" : "text-slate-400"}`} />
                  <p className="font-medium">Bank Account (ACH)</p>
                </button>
              </div>

              {/* Card Form */}
              {paymentMethod === "card" && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="cardNumber">Card Number</Label>
                    <Input
                      id="cardNumber"
                      placeholder="1234 5678 9012 3456"
                      value={cardDetails.cardNumber}
                      onChange={(e) => setCardDetails({ ...cardDetails, cardNumber: formatCardNumber(e.target.value) })}
                      maxLength={19}
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="expiryDate">Expiry Date</Label>
                      <Input
                        id="expiryDate"
                        placeholder="MM/YY"
                        value={cardDetails.expiryDate}
                        onChange={(e) => setCardDetails({ ...cardDetails, expiryDate: formatExpiryDate(e.target.value) })}
                        maxLength={5}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="cvv">CVV</Label>
                      <Input
                        id="cvv"
                        placeholder="123"
                        value={cardDetails.cvv}
                        onChange={(e) => setCardDetails({ ...cardDetails, cvv: e.target.value.replace(/\D/g, "").slice(0, 4) })}
                        maxLength={4}
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="cardholderName">Cardholder Name</Label>
                    <Input
                      id="cardholderName"
                      placeholder="John Doe"
                      value={cardDetails.cardholderName}
                      onChange={(e) => setCardDetails({ ...cardDetails, cardholderName: e.target.value })}
                    />
                  </div>
                </div>
              )}

              {/* Bank Form */}
              {paymentMethod === "bank" && (
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="accountName">Account Holder Name</Label>
                    <Input
                      id="accountName"
                      placeholder="John Doe"
                      value={bankDetails.accountName}
                      onChange={(e) => setBankDetails({ ...bankDetails, accountName: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="routingNumber">Routing Number</Label>
                    <Input
                      id="routingNumber"
                      placeholder="123456789"
                      value={bankDetails.routingNumber}
                      onChange={(e) => setBankDetails({ ...bankDetails, routingNumber: e.target.value.replace(/\D/g, "").slice(0, 9) })}
                      maxLength={9}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="accountNumber">Account Number</Label>
                    <Input
                      id="accountNumber"
                      placeholder="1234567890"
                      value={bankDetails.accountNumber}
                      onChange={(e) => setBankDetails({ ...bankDetails, accountNumber: e.target.value.replace(/\D/g, "") })}
                    />
                  </div>
                </div>
              )}

              <div className="mt-6 p-4 bg-slate-50 rounded-lg flex items-center gap-3">
                <ShieldCheck className="h-5 w-5 text-green-600" />
                <p className="text-sm text-slate-600">
                  Your payment information is encrypted and secure.
                </p>
              </div>
            </CardContent>
          </Card>

          {/* Order Summary */}
          <Card>
            <CardHeader>
              <CardTitle>Order Summary</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <div className="flex justify-between">
                  <span className="text-slate-500">First Month Payment</span>
                  <span className="font-semibold">{formatCurrency(monthlyTotal)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-slate-500">Recurring Monthly</span>
                  <span>{formatCurrency(monthlyTotal)}/mo</span>
                </div>
              </div>
            </CardContent>
          </Card>

          <div className="flex justify-between">
            <Button variant="outline" onClick={() => setStep("review")}>
              Back
            </Button>
            <Button size="lg" onClick={handleProcessPayment} disabled={isProcessing}>
              {isProcessing ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Processing Payment...
                </>
              ) : (
                `Pay ${formatCurrency(monthlyTotal)}`
              )}
            </Button>
          </div>
        </div>
      )}

      {/* Step: Confirmation */}
      {step === "confirmation" && (
        <Card>
          <CardContent className="py-16 text-center">
            <div className="flex justify-center mb-6">
              <div className="flex h-20 w-20 items-center justify-center rounded-full bg-green-100">
                <Check className="h-10 w-10 text-green-600" />
              </div>
            </div>
            <h2 className="text-2xl font-bold mb-2">Order Confirmed!</h2>
            <p className="text-slate-500 mb-2">
              Thank you for your enrollment. Your order has been processed successfully.
            </p>
            <p className="text-sm text-slate-500 mb-8">
              Order ID: <span className="font-mono">{orderId}</span>
            </p>
            <div className="flex gap-4 justify-center">
              <Link href={`/orders/${orderId}`}>
                <Button variant="outline">View Order Details</Button>
              </Link>
              <Link href="/dashboard">
                <Button>Go to Dashboard</Button>
              </Link>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
