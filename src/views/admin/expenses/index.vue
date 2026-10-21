<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <div>
          <p class="text-muted-foreground text-[13.5px]">
            {{ meta ? meta.total + " expenses" : "" }}
            <span v-if="expenses.length > 0" class="ml-2 text-foreground font-semibold">
              Total (this page): {{ money(pageTotal) }}
            </span>
          </p>
        </div>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New Expense</Button>
      </div>

      <!-- Filters -->
      <div class="flex flex-wrap gap-3 mb-4">
        <select
          v-model="filterCategory"
          class="h-9 rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
          @change="onFilterChange"
        >
          <option value="">All Categories</option>
          <option v-for="cat in activeCategories" :key="cat.uuid" :value="cat.uuid">{{ cat.name }}</option>
        </select>

        <select
          v-model="filterPaymentMethod"
          class="h-9 rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
          @change="onFilterChange"
        >
          <option value="">All Payment Methods</option>
          <option value="CASH">Cash</option>
          <option value="BANK_TRANSFER">Bank Transfer</option>
          <option value="CARD">Card</option>
          <option value="OTHER">Other</option>
        </select>

        <Input
          v-model="filterDateFrom"
          type="date"
          class="h-9 w-40"
          placeholder="From"
          @change="onFilterChange"
        />
        <Input
          v-model="filterDateTo"
          type="date"
          class="h-9 w-40"
          placeholder="To"
          @change="onFilterChange"
        />
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Category</TableHead>
              <TableHead>Description</TableHead>
              <TableHead class="text-right">Amount</TableHead>
              <TableHead>Payment Method</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>Ref #</TableHead>
              <TableHead>Created</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 7" :key="'s' + n">
              <TableCell colspan="8"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="exp in expenses"
                :key="exp.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="openEdit(exp)"
              >
                <TableCell class="font-medium">{{ exp.category_name }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ exp.description ?? "—" }}</TableCell>
                <TableCell class="text-right font-semibold">{{ money(exp.amount) }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ exp.payment_method ? formatPaymentMethod(exp.payment_method) : "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(exp.expense_date) }}</TableCell>
                <TableCell class="font-mono text-[12px] text-muted-foreground">{{ exp.reference_number ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(exp.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-destructive" @click="confirmRemove(exp)">
                    <Trash2 :size="14" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="expenses.length === 0 && !loadError">
                <TableCell colspan="8" class="text-center text-muted-foreground py-12 text-sm">No expenses found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div v-if="meta && meta.total_pages > 1" class="flex justify-center mt-4">
        <Pagination :page="currentPage" :total-pages="meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Create / Edit Sheet -->
    <Sheet :open="formOpen" @update:open="(v) => !v && (formOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background z-10">
            <span class="text-[15px] font-semibold">{{ editTarget ? "Edit Expense" : "New Expense" }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="formOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <!-- Category -->
            <div class="flex flex-col gap-1.5">
              <Label>Category <span class="text-red-500">*</span></Label>
              <select
                v-model="fCategoryUuid"
                class="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                :class="ferrors.category_uuid ? 'border-red-400' : ''"
              >
                <option value="">Select category…</option>
                <option v-for="cat in activeCategories" :key="cat.uuid" :value="cat.uuid">{{ cat.name }}</option>
              </select>
              <p v-if="ferrors.category_uuid" class="text-[12px] text-red-500">{{ ferrors.category_uuid }}</p>
            </div>

            <!-- Amount -->
            <div class="flex flex-col gap-1.5">
              <Label>Amount <span class="text-red-500">*</span></Label>
              <Input v-model="fAmount" type="number" min="0.01" step="0.01" :class="ferrors.amount ? 'border-red-400' : ''" placeholder="0.00" />
              <p v-if="ferrors.amount" class="text-[12px] text-red-500">{{ ferrors.amount }}</p>
            </div>

            <!-- Description -->
            <div class="flex flex-col gap-1.5">
              <Label>Description</Label>
              <Input v-model="fDescription" placeholder="Optional description" />
            </div>

            <!-- Expense Date -->
            <div class="flex flex-col gap-1.5">
              <Label>Expense Date <span class="text-red-500">*</span></Label>
              <Input v-model="fDate" type="date" :class="ferrors.expense_date ? 'border-red-400' : ''" />
              <p v-if="ferrors.expense_date" class="text-[12px] text-red-500">{{ ferrors.expense_date }}</p>
            </div>

            <!-- Payment Method -->
            <div class="flex flex-col gap-1.5">
              <Label>Payment Method</Label>
              <select
                v-model="fPaymentMethod"
                class="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
              >
                <option value="">None</option>
                <option value="CASH">Cash</option>
                <option value="BANK_TRANSFER">Bank Transfer</option>
                <option value="CARD">Card</option>
                <option value="OTHER">Other</option>
              </select>
            </div>

            <!-- Reference Number -->
            <div class="flex flex-col gap-1.5">
              <Label>Reference Number</Label>
              <Input v-model="fReference" placeholder="Optional reference #" />
            </div>

            <div v-if="formError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ formError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="save">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Saving…" : editTarget ? "Save Changes" : "Create Expense" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <ConfirmDialog
      :open="!!pendingDelete"
      title="Delete expense?"
      :description="`This expense of ${pendingDelete ? money(pendingDelete.amount) : ''} will be permanently removed.`"
      confirm-label="Delete"
      loading-label="Deleting…"
      :loading="deleting"
      @confirm="doDelete"
      @cancel="pendingDelete = null"
    />
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { Plus, X, Trash2, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import Pagination from "@/components/admin/Pagination.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import {
  fetchExpenses,
  createExpense,
  updateExpense,
  deleteExpense,
  fetchExpenseCategories,
} from "@/api/expenses";
import type { ExpenseResponse, ExpensePaymentMethod, ExpenseCategoryResponse } from "@/api/expenses";
import type { PageMeta } from "@/api/users";
import { fmtDateShort, money } from "@/utils/format";

const ui = useUIStore();

const expenses = ref<ExpenseResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);

const filterCategory = ref("");
const filterPaymentMethod = ref<ExpensePaymentMethod | "">("");
const filterDateFrom = ref("");
const filterDateTo = ref("");

const activeCategories = ref<ExpenseCategoryResponse[]>([]);

const pageTotal = computed(() => expenses.value.reduce((sum, e) => sum + e.amount, 0));

function formatPaymentMethod(method: ExpensePaymentMethod) {
  const map: Record<ExpensePaymentMethod, string> = {
    CASH: "Cash",
    BANK_TRANSFER: "Bank Transfer",
    CARD: "Card",
    OTHER: "Other",
  };
  return map[method] ?? method;
}

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchExpenses({
      page: currentPage.value,
      category_uuid: filterCategory.value || undefined,
      payment_method: filterPaymentMethod.value || undefined,
      date_from: filterDateFrom.value || undefined,
      date_to: filterDateTo.value || undefined,
    });
    expenses.value = res.expenses;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load expenses.";
  } finally {
    loading.value = false;
  }
}

async function loadCategories() {
  try {
    const res = await fetchExpenseCategories({ status: "ACTIVE", size: 200 });
    activeCategories.value = res.expense_categories;
  } catch {
    // ignore
  }
}

onMounted(() => {
  load();
  loadCategories();
});

function onFilterChange() {
  currentPage.value = 1;
  load();
}

function changePage(p: number) {
  currentPage.value = p;
  load();
}

// ── Form ──────────────────────────────────────────────────────
const Schema = z.object({
  category_uuid: z.string().min(1, "Category is required"),
  amount: z.number({ invalid_type_error: "Amount is required" }).positive("Amount must be greater than 0"),
  description: z.string().optional(),
  expense_date: z.string().min(1, "Date is required"),
  payment_method: z.string().optional(),
  reference_number: z.string().optional(),
});

const { defineField, handleSubmit, errors: ferrors, resetForm, setValues } = useForm({
  validationSchema: toTypedSchema(Schema),
  initialValues: { category_uuid: "", amount: undefined as unknown as number, description: "", expense_date: "", payment_method: "", reference_number: "" },
});

const [fCategoryUuid] = defineField("category_uuid");
const [fAmount] = defineField("amount");
const [fDescription] = defineField("description");
const [fDate] = defineField("expense_date");
const [fPaymentMethod] = defineField("payment_method");
const [fReference] = defineField("reference_number");

const formOpen = ref(false);
const formError = ref("");
const saving = ref(false);
const editTarget = ref<ExpenseResponse | null>(null);

function openCreate() {
  editTarget.value = null;
  resetForm();
  formError.value = "";
  formOpen.value = true;
}

function openEdit(exp: ExpenseResponse) {
  editTarget.value = exp;
  setValues({
    category_uuid: exp.category_uuid,
    amount: exp.amount,
    description: exp.description ?? "",
    expense_date: exp.expense_date,
    payment_method: exp.payment_method ?? "",
    reference_number: exp.reference_number ?? "",
  });
  formError.value = "";
  formOpen.value = true;
}

const save = handleSubmit(async (values) => {
  saving.value = true;
  formError.value = "";
  try {
    const payload = {
      category_uuid: values.category_uuid,
      amount: values.amount,
      expense_date: values.expense_date,
      description: values.description || undefined,
      payment_method: (values.payment_method as ExpensePaymentMethod) || undefined,
      reference_number: values.reference_number || undefined,
    };
    if (editTarget.value) {
      await updateExpense(editTarget.value.uuid, payload);
      ui.showToast("Expense updated", "success");
    } else {
      await createExpense(payload);
      ui.showToast("Expense created", "success");
    }
    formOpen.value = false;
    await load();
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : "Failed to save.";
  } finally {
    saving.value = false;
  }
});

// ── Delete ────────────────────────────────────────────────────
const pendingDelete = ref<ExpenseResponse | null>(null);
const deleting = ref(false);

function confirmRemove(exp: ExpenseResponse) {
  pendingDelete.value = exp;
}

async function doDelete() {
  if (!pendingDelete.value) return;
  deleting.value = true;
  try {
    await deleteExpense(pendingDelete.value.uuid);
    expenses.value = expenses.value.filter((e) => e.uuid !== pendingDelete.value!.uuid);
    pendingDelete.value = null;
    ui.showToast("Expense deleted", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to delete.", "danger");
  } finally {
    deleting.value = false;
  }
}
</script>
