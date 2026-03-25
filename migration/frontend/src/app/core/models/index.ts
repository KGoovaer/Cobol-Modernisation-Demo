export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  size: number;
  number: number;
}

export interface PaymentSubmitRequest {
  memberRnr: number;
  destinationMutuality: number;
  constantId: string;
  sequenceNo?: string;
  amountCents: number;
  currency: 'E' | 'B';
  paymentDescCode: number;
  iban: string;
  paymentMethod: ' ' | 'C' | 'D' | 'E' | 'F';
  accountingType: 1 | 3 | 4 | 5 | 6;
}

export interface PaymentResult {
  requestId: string;
  status: 'ACCEPTED' | 'REJECTED';
  diagnosticNl: string | null;
  diagnosticFr: string | null;
}

export interface PaymentRecord {
  id: string;
  paymentRequestId: string;
  memberRnr: number;
  memberName: string;
  amountCents: number;
  iban: string;
  bic: string;
  bankRouting: string;
  regionalTag: number;
  accountingType: number;
  destinationMutuality: number;
  paymentDescNl: string;
  paymentDescFr: string;
  createdAt: string;
}

export interface RejectionRecord {
  id: string;
  paymentRequestId: string;
  memberRnr: number;
  destinationMutuality: number;
  constantId: string;
  amountCents: number;
  diagnosticNl: string;
  diagnosticFr: string;
  createdAt: string;
}

export interface Discrepancy {
  id: string;
  paymentRequestId: string;
  memberRnr: number;
  destinationMutuality: number;
  constantId: string;
  providedIban: string;
  knownIban: string;
  createdAt: string;
}

export interface UserAdminDto {
  id: string;
  username: string;
  role: 'SUBMITTER' | 'READ_ONLY' | 'ADMIN';
  active: boolean;
  mutualityCodes: number[];
  createdAt: string;
}

export interface CreateUserRequest {
  username: string;
  password: string;
  role: 'SUBMITTER' | 'READ_ONLY' | 'ADMIN';
  mutualityCodes: number[];
}
