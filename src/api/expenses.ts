import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export type ExpensePaymentMethod = "CASH" | "BANK_TRANSFER" | "CARD" | "OTHER";
export type ExpenseCategoryStatus = "ACTIVE" | "INACTIVE";

// ── Expense Categories ────────────────────────────────────────

export interface ExpenseCategoryResponse {
  id: number;
  uuid: string;
  name: string;
  description: string | null;
  status: ExpenseCategoryStatus;
  created_at: string;
  updated_at: string;
}

export interface ExpenseCategoryListData {
  expense_categories: ExpenseCategoryResponse[];
  meta: PageMeta;
}

export interface ExpenseCategoryRequest {
  name: string;
  description?: string;
}

export interface ExpenseCategoryUpdateRequest extends Partial<ExpenseCategoryRequest> {
  status?: ExpenseCategoryStatus;
}

export function fetchExpenseCategories(params: {
  page?: number;
  size?: number;
  search?: string;
  status?: ExpenseCategoryStatus | "";
} = {}): Promise<ExpenseCategoryListData> {
  const { page = 1, size = 20, search, status } = params;
  const qs = new URLSearchParams();
  qs.set("page", String(page - 1));
  qs.set("size", String(size));
  if (search) qs.set("search", search);
  if (status) qs.set("status", status);
  return apiFetch<ExpenseCategoryListData>(`${ROUTES.expenseCategories.list}?${qs}`);
}

export function fetchExpenseCategory(uuid: string): Promise<ExpenseCategoryResponse> {
  return apiFetch<ExpenseCategoryResponse>(ROUTES.expenseCategories.detail(uuid));
}

export function createExpenseCategory(payload: ExpenseCategoryRequest): Promise<ExpenseCategoryResponse> {
  return apiFetch<ExpenseCategoryResponse>(ROUTES.expenseCategories.create, {
    method: "POST",
    data: payload,
  });
}

export function updateExpenseCategory(
  uuid: string,
  payload: ExpenseCategoryUpdateRequest,
): Promise<ExpenseCategoryResponse> {
  return apiFetch<ExpenseCategoryResponse>(ROUTES.expenseCategories.update(uuid), {
    method: "PATCH",
    data: payload,
  });
}

export function deleteExpenseCategory(uuid: string): Promise<void> {
  return apiFetch<void>(ROUTES.expenseCategories.delete(uuid), { method: "DELETE" });
}

// ── Expenses ──────────────────────────────────────────────────

export interface ExpenseResponse {
  id: number;
  uuid: string;
  category_uuid: string;
  category_name: string;
  amount: number;
  description: string | null;
  expense_date: string;
  payment_method: ExpensePaymentMethod | null;
  reference_number: string | null;
  created_at: string;
  updated_at: string;
}

export interface ExpenseListData {
  expenses: ExpenseResponse[];
  meta: PageMeta;
}

export interface CreateExpenseRequest {
  category_uuid: string;
  amount: number;
  expense_date: string;
  description?: string;
  payment_method?: ExpensePaymentMethod;
  reference_number?: string;
}

export interface UpdateExpenseRequest extends Partial<CreateExpenseRequest> {}

export function fetchExpenses(params: {
  page?: number;
  size?: number;
  category_uuid?: string;
  payment_method?: ExpensePaymentMethod | "";
  date_from?: string;
  date_to?: string;
} = {}): Promise<ExpenseListData> {
  const { page = 1, size = 20, category_uuid, payment_method, date_from, date_to } = params;
  const qs = new URLSearchParams();
  qs.set("page", String(page - 1));
  qs.set("size", String(size));
  if (category_uuid) qs.set("category_uuid", category_uuid);
  if (payment_method) qs.set("payment_method", payment_method);
  if (date_from) qs.set("date_from", date_from);
  if (date_to) qs.set("date_to", date_to);
  return apiFetch<ExpenseListData>(`${ROUTES.expenses.list}?${qs}`);
}

export function fetchExpense(uuid: string): Promise<ExpenseResponse> {
  return apiFetch<ExpenseResponse>(ROUTES.expenses.detail(uuid));
}

export function createExpense(payload: CreateExpenseRequest): Promise<ExpenseResponse> {
  return apiFetch<ExpenseResponse>(ROUTES.expenses.create, {
    method: "POST",
    data: payload,
  });
}

export function updateExpense(uuid: string, payload: UpdateExpenseRequest): Promise<ExpenseResponse> {
  return apiFetch<ExpenseResponse>(ROUTES.expenses.update(uuid), {
    method: "PUT",
    data: payload,
  });
}

export function deleteExpense(uuid: string): Promise<void> {
  return apiFetch<void>(ROUTES.expenses.delete(uuid), { method: "DELETE" });
}
