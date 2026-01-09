// Auth types
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone?: string;
  createdAt: string;
}

export interface Profile {
  id: string;
  userId: string;
  firstName: string;
  lastName: string;
  dateOfBirth: string;
  gender: "MALE" | "FEMALE" | "OTHER";
  relationship: "SELF" | "SPOUSE" | "CHILD" | "PARENT" | "SIBLING" | "OTHER";
  ssn?: string;
  email?: string;
  phone?: string;
  address?: Address;
  isPrimary: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Address {
  street1: string;
  street2?: string;
  city: string;
  state: string;
  zipCode: string;
}

// Plan types
export interface Plan {
  id: string;
  planCode: string;
  planName: string;
  planType: string;
  metalTier: "BRONZE" | "SILVER" | "GOLD" | "PLATINUM";
  issuerName: string;
  state: string;
  monthlyPremium: number;
  annualDeductible: number;
  outOfPocketMax: number;
  copayPrimaryCare: number;
  copaySpecialist: number;
  copayEmergency: number;
  coinsurance: number;
  hsaEligible: boolean;
  hraEligible: boolean;
  networkType: string;
  description?: string;
  status: string;
  year: number;
}

// Cart types
export interface CartItem {
  id: string;
  planId: string;
  planCode: string;
  planName: string;
  metalTier: string;
  monthlyPremium: number;
  profileId: string;
  profileName: string;
  relationship: string;
}

export interface Quote {
  id: string;
  quoteNumber: string;
  status: "DRAFT" | "ACTIVE" | "EXPIRED" | "CONVERTED";
  items: CartItem[];
  subtotal: number;
  totalMonthly: number;
  totalAnnual: number;
  validUntil: string;
  createdAt: string;
}

// Order types
export interface Order {
  id: string;
  orderNumber: string;
  status: "DRAFT" | "PENDING_PAYMENT" | "CONFIRMED" | "PROCESSING" | "COMPLETED" | "CANCELLED";
  items: OrderItem[];
  subtotal: number;
  taxAmount: number;
  discountAmount: number;
  totalAmount: number;
  effectiveDate: string;
  createdAt: string;
}

export interface OrderItem {
  id: string;
  planId: string;
  planCode: string;
  planName: string;
  metalTier: string;
  profileId: string;
  profileName: string;
  unitPrice: number;
  totalPrice: number;
}

// Payment types
export interface PaymentMethod {
  id: string;
  type: "CREDIT_CARD" | "DEBIT_CARD" | "ACH" | "BANK_TRANSFER";
  cardBrand?: string;
  cardLast4?: string;
  bankName?: string;
  accountLast4?: string;
  isDefault: boolean;
  expiryMonth?: number;
  expiryYear?: number;
}

// Common types
export interface PagedResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}
