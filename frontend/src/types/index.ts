export interface PagedResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  first: boolean;
  last: boolean;
}

export interface Plan {
  id: string;
  planCode: string;
  planName: string;
  metalTier: "BRONZE" | "SILVER" | "GOLD" | "PLATINUM";
  issuerName: string;
  monthlyPremium: number;
  annualDeductible: number;
  outOfPocketMax: number;
  status: string;
}

export interface Customer {
  id: string;
  customerNumber: string;
  firstName: string;
  lastName: string;
  fullName: string;
  email: string;
  phone: string;
  status: string;
  createdAt: string;
}

export interface Order {
  id: string;
  orderNumber: string;
  customerId: string;
  customerName: string;
  status: string;
  totalAmount: number;
  createdAt: string;
}
