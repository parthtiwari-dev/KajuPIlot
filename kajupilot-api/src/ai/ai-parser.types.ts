import {
  DealStatus,
  DealType,
  ExpenseCategory,
  ExpenseScope,
  PaymentType,
  TaskType,
} from "@prisma/client";
import { AiProvider } from "./ai-config.service";

export type ParsedItemKind = "task" | "deal" | "payment" | "expense";
export type PartyMatchStatus = "matched" | "new" | "ambiguous" | "missing";

export interface ParsedPartyMatch {
  status: PartyMatchStatus;
  partyId?: string;
  name?: string;
  candidates?: { id: string; name: string; phone: string | null }[];
}

export interface ParsedItemBase {
  kind: ParsedItemKind;
  tempId: string;
  partyName?: string | null;
  partyId?: string | null;
  partyMatch?: ParsedPartyMatch;
  notes?: string | null;
  needsReview: boolean;
  warnings: string[];
}

export interface ParsedTaskItem extends ParsedItemBase {
  kind: "task";
  type: TaskType;
  title: string;
  scheduledAt: string | null;
  priority: number;
  amountPaise?: number | null;
}

export interface ParsedDealLineItem {
  grade: string;
  quantityText: string;
  rateText?: string | null;
  totalPaise: number;
}

export interface ParsedDealItem extends ParsedItemBase {
  kind: "deal";
  type: DealType;
  items: ParsedDealLineItem[];
  totalPaise: number;
  paidPaise: number;
  status: DealStatus;
  deliveryDate?: string | null;
  paymentDue?: string | null;
}

export interface ParsedPaymentItem extends ParsedItemBase {
  kind: "payment";
  type: PaymentType;
  amountPaise: number;
  method?: string | null;
  paymentDate: string | null;
}

export interface ParsedExpenseItem extends ParsedItemBase {
  kind: "expense";
  scope: ExpenseScope;
  category: ExpenseCategory;
  amountPaise: number;
  expenseDate: string | null;
}

export type ParsedAiItem =
  | ParsedTaskItem
  | ParsedDealItem
  | ParsedPaymentItem
  | ParsedExpenseItem;

export interface ParsedAiPayload {
  tasks: ParsedTaskItem[];
  deals: ParsedDealItem[];
  payments: ParsedPaymentItem[];
  expenses: ParsedExpenseItem[];
}

export interface AiUsageSummary {
  inputTokens: number;
  outputTokens: number;
  estimatedCostUsd: number;
}

export interface AiParseResponse {
  logId: string;
  provider: AiProvider;
  model: string;
  usage: AiUsageSummary;
  parsed: ParsedAiPayload;
  itemCount: number;
  needsReviewCount: number;
}

export interface AiConfirmCreated {
  parties: unknown[];
  tasks: unknown[];
  deals: unknown[];
  payments: unknown[];
  expenses: unknown[];
}

export interface AiConfirmResponse {
  created: AiConfirmCreated;
}
