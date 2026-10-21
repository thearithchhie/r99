<template>
  <AdminLayout>
    <div class="fade p-5">
      <!-- Back to suppliers (only when filtering by supplier) -->
      <div v-if="supplierParam" class="flex items-center gap-2 mb-4">
        <Button variant="ghost" size="sm" class="gap-1.5 text-muted-foreground -ml-2" @click="router.push(ADMIN_ROUTES.suppliers.list)">
          <ArrowLeft :size="14" /> Back to Suppliers
        </Button>
        <span v-if="supplierName" class="text-muted-foreground text-[13px]">·</span>
        <span v-if="supplierName" class="text-[13.5px] font-semibold">{{ supplierName }}</span>
      </div>

      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ meta ? meta.total + " purchases" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New Purchase</Button>
      </div>

      <!-- Status Tabs -->
      <div class="mb-4">
        <Tabs v-model="statusFilter" @update:model-value="onStatusChange">
          <TabsList>
            <TabsTrigger value="">All</TabsTrigger>
            <TabsTrigger value="DRAFT">Draft</TabsTrigger>
            <TabsTrigger value="ORDERED">Ordered</TabsTrigger>
            <TabsTrigger value="PARTIALLY_RECEIVED">Partial</TabsTrigger>
            <TabsTrigger value="RECEIVED">Received</TabsTrigger>
            <TabsTrigger value="CANCELLED">Cancelled</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Order #</TableHead>
              <TableHead>Supplier</TableHead>
              <TableHead>Status</TableHead>
              <TableHead class="text-right">Total</TableHead>
              <TableHead>Created</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 7" :key="'s' + n">
              <TableCell colspan="5"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="p in purchases"
                :key="p.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="goToDetail(p.uuid)"
              >
                <TableCell class="font-mono text-[12.5px] font-semibold">{{ p.order_number }}</TableCell>
                <TableCell class="font-medium">{{ p.supplier_name }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="purchaseStatusStyle(p.status)"
                  >{{ p.status }}</span>
                </TableCell>
                <TableCell class="text-right font-semibold">{{ money(p.total_amount) }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(p.created_at) }}</TableCell>
              </TableRow>
              <TableRow v-if="purchases.length === 0 && !loadError">
                <TableCell colspan="5" class="text-center text-muted-foreground py-12 text-sm">No purchases found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div v-if="meta && meta.total_pages > 1" class="flex justify-center mt-4">
        <Pagination :page="currentPage" :total-pages="meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Create Sheet (560px) -->
    <Sheet :open="createOpen" @update:open="(v) => !v && (createOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[560px] sm:max-w-[560px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background z-10">
            <span class="text-[15px] font-semibold">New Purchase Order</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="createOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-5 flex-1 overflow-y-auto">
            <!-- Supplier -->
            <div class="flex flex-col gap-1.5">
              <Label>Supplier <span class="text-red-500">*</span></Label>
              <select
                v-model="newSupplierUuid"
                class="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                :class="createErrors.supplier_uuid ? 'border-red-400' : ''"
              >
                <option value="">Select supplier…</option>
                <option v-for="s in activeSuppliers" :key="s.uuid" :value="s.uuid">{{ s.name }}</option>
              </select>
              <p v-if="createErrors.supplier_uuid" class="text-[12px] text-red-500">{{ createErrors.supplier_uuid }}</p>
            </div>

            <!-- Items -->
            <div class="flex flex-col gap-3">
              <div class="flex items-center justify-between">
                <Label>Items <span class="text-red-500">*</span></Label>
                <Button variant="outline" size="sm" @click="addItem"><Plus :size="13" /> Add Item</Button>
              </div>

              <div v-for="(item, idx) in newItems" :key="idx" class="rounded-lg border border-border p-3 flex flex-col gap-3">
                <div class="flex items-center justify-between">
                  <span class="text-[13px] font-semibold text-muted-foreground">Item {{ idx + 1 }}</span>
                  <Button variant="ghost" size="icon" class="h-7 w-7 text-muted-foreground hover:text-destructive" @click="removeItem(idx)">
                    <Trash2 :size="13" />
                  </Button>
                </div>
                <div class="flex flex-col gap-1.5">
                  <Label class="text-[12px]">Product <span class="text-red-500">*</span></Label>
                  <ProductSelect v-model="item.product_uuid" placeholder="Search product…" />
                </div>
                <div class="grid grid-cols-3 gap-2">
                  <div class="flex flex-col gap-1.5">
                    <Label class="text-[12px]">Qty <span class="text-red-500">*</span></Label>
                    <Input v-model.number="item.quantity" type="number" min="1" placeholder="1" />
                  </div>
                  <div class="flex flex-col gap-1.5">
                    <Label class="text-[12px]">Cost Price <span class="text-red-500">*</span></Label>
                    <Input v-model.number="item.cost_price" type="number" min="0" placeholder="0" />
                  </div>
                  <div class="flex flex-col gap-1.5">
                    <Label class="text-[12px]">Discount</Label>
                    <Input v-model.number="item.discount_amount" type="number" min="0" placeholder="0" />
                  </div>
                </div>
                <div class="text-right text-[12.5px] text-muted-foreground">
                  Subtotal: <span class="font-semibold text-foreground">{{ money(Math.max(0, (item.quantity || 0) * (item.cost_price || 0) - (item.discount_amount || 0))) }}</span>
                </div>
              </div>

              <p v-if="createErrors.items" class="text-[12px] text-red-500">{{ createErrors.items }}</p>
            </div>

            <!-- Order-level fields -->
            <div class="border-t pt-4 grid grid-cols-3 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label class="text-[12px]">Discount</Label>
                <Input v-model.number="newDiscount" type="number" min="0" placeholder="0" />
              </div>
              <div class="flex flex-col gap-1.5">
                <Label class="text-[12px]">Tax</Label>
                <Input v-model.number="newTax" type="number" min="0" placeholder="0" />
              </div>
              <div class="flex flex-col gap-1.5">
                <Label class="text-[12px]">Shipping</Label>
                <Input v-model.number="newShipping" type="number" min="0" placeholder="0" />
              </div>
            </div>

            <!-- Note -->
            <div class="flex flex-col gap-1.5">
              <Label>Note</Label>
              <textarea
                v-model="newNote"
                rows="2"
                placeholder="Optional note…"
                class="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring resize-none"
              />
            </div>

            <div v-if="createError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ createError }}
            </div>

            <Button class="w-full" :disabled="creating" @click="submitCreate">
              <Loader2 v-if="creating" :size="14" class="animate-spin" />
              {{ creating ? "Creating…" : "Create Purchase" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from "vue";
import { useRoute, useRouter } from "vue-router";
import { Plus, X, Trash2, AlertTriangle, Loader2, ArrowLeft } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import Pagination from "@/components/admin/Pagination.vue";
import ProductSelect from "@/components/shared/ProductSelect.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import { fetchPurchases, createPurchase } from "@/api/purchases";
import type { PurchaseResponse, PurchaseStatus } from "@/api/purchases";
import { fetchSuppliers, fetchSupplier } from "@/api/suppliers";
import type { SupplierResponse } from "@/api/suppliers";
import type { PageMeta } from "@/api/users";
import { fmtDateShort, money } from "@/utils/format";
import { ADMIN_ROUTES } from "@/router/admin-routes";

const ui = useUIStore();
const router = useRouter();
const route = useRoute();

const purchases = ref<PurchaseResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);
const statusFilter = ref<PurchaseStatus | "">("");
const activeSuppliers = ref<SupplierResponse[]>([]);

// Check for supplier query param
const supplierParam = route.query.supplier as string | undefined;
const supplierName = ref<string | null>(null);

if (supplierParam) {
  fetchSupplier(supplierParam)
    .then((s) => { supplierName.value = s.name; })
    .catch(() => {});
}

function purchaseStatusStyle(status: PurchaseStatus) {
  const map: Record<PurchaseStatus, string> = {
    DRAFT: "background:hsl(var(--muted));color:hsl(var(--muted-foreground))",
    ORDERED: "background:#dbeafe;color:#1d4ed8",
    PARTIALLY_RECEIVED: "background:#fef9c3;color:#a16207",
    RECEIVED: "background:#dcfce7;color:#15803d",
    CANCELLED: "background:#fee2e2;color:#dc2626",
  };
  return map[status] ?? map.DRAFT;
}

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchPurchases({
      page: currentPage.value,
      status: statusFilter.value || undefined,
      supplier_uuid: supplierParam || undefined,
    });
    purchases.value = res.purchases;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load purchases.";
  } finally {
    loading.value = false;
  }
}

async function loadActiveSuppliers() {
  try {
    const res = await fetchSuppliers({ status: "ACTIVE", size: 200 });
    activeSuppliers.value = res.suppliers;
  } catch {
    // ignore
  }
}

onMounted(() => {
  load();
  loadActiveSuppliers();
});

function onStatusChange() {
  currentPage.value = 1;
  load();
}

function changePage(p: number) {
  currentPage.value = p;
  load();
}

function goToDetail(uuid: string) {
  router.push(ADMIN_ROUTES.purchases.detail(uuid));
}

// ── Create form ───────────────────────────────────────────────
interface ItemRow {
  product_uuid: string;
  quantity: number;
  cost_price: number;
  discount_amount: number;
}

const createOpen = ref(false);
const creating = ref(false);
const createError = ref("");
const newSupplierUuid = ref("");
const newItems = ref<ItemRow[]>([]);
const newDiscount = ref<number | undefined>(undefined);
const newTax = ref<number | undefined>(undefined);
const newShipping = ref<number | undefined>(undefined);
const newNote = ref("");
const createErrors = reactive<{ supplier_uuid?: string; items?: string }>({});

function resetCreateForm() {
  newSupplierUuid.value = "";
  newItems.value = [];
  newDiscount.value = undefined;
  newTax.value = undefined;
  newShipping.value = undefined;
  newNote.value = "";
  createError.value = "";
  createErrors.supplier_uuid = undefined;
  createErrors.items = undefined;
}

function openCreate() {
  resetCreateForm();
  addItem();
  createOpen.value = true;
}

function addItem() {
  newItems.value.push({ product_uuid: "", quantity: 1, cost_price: 0, discount_amount: 0 });
}

function removeItem(idx: number) {
  newItems.value.splice(idx, 1);
}

async function submitCreate() {
  createErrors.supplier_uuid = undefined;
  createErrors.items = undefined;
  createError.value = "";

  let valid = true;
  if (!newSupplierUuid.value) {
    createErrors.supplier_uuid = "Supplier is required";
    valid = false;
  }
  if (newItems.value.length === 0) {
    createErrors.items = "At least one item is required";
    valid = false;
  }
  const missingProduct = newItems.value.some((i) => !i.product_uuid);
  if (missingProduct) {
    createErrors.items = "All items must have a product selected";
    valid = false;
  }
  if (!valid) return;

  creating.value = true;
  try {
    const created = await createPurchase({
      supplier_uuid: newSupplierUuid.value,
      items: newItems.value.map((i) => ({
        product_uuid: i.product_uuid,
        quantity: i.quantity,
        cost_price: i.cost_price,
        discount_amount: i.discount_amount || undefined,
      })),
      discount_amount: newDiscount.value || undefined,
      tax_amount: newTax.value || undefined,
      shipping_cost: newShipping.value || undefined,
      note: newNote.value || undefined,
    });
    createOpen.value = false;
    ui.showToast("Purchase created", "success");
    router.push(ADMIN_ROUTES.purchases.detail(created.uuid));
  } catch (e: unknown) {
    createError.value = e instanceof Error ? e.message : "Failed to create purchase.";
  } finally {
    creating.value = false;
  }
}
</script>
