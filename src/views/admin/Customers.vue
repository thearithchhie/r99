<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ meta ? meta.total + " customers" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New customer</Button>
      </div>

      <!-- Search -->
      <div class="relative max-w-xs mb-4">
        <Search :size="15" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input v-model="query" class="pl-8" placeholder="Search by name or phone…" @input="onSearch" />
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Facebook</TableHead>
              <TableHead>Province</TableHead>
              <TableHead>Joined</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 8" :key="'s'+n">
              <TableCell colspan="6"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="c in customers"
                :key="c.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="openDetail(c)"
              >
                <TableCell>
                  <div class="flex items-center gap-2.5">
                    <UserAvatar :name="c.name" :size="30" />
                    <span class="font-medium">{{ c.name }}</span>
                  </div>
                </TableCell>
                <TableCell class="font-mono text-[12.5px]">{{ c.phone }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ c.facebook_name ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ c.province ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(c.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-destructive" @click="confirmRemove(c)">
                    <Trash2 :size="14" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="customers.length === 0 && !loadError">
                <TableCell colspan="6" class="text-center text-muted-foreground py-12 text-sm">No customers found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div v-if="meta && meta.total_pages > 1" class="flex justify-center mt-4">
        <Pagination :page="currentPage" :total-pages="meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Detail dialog (centered) -->
    <Dialog :open="!!selected" @update:open="(v) => !v && (selected = null)">
      <DialogContent class="p-0 gap-0 max-w-5xl w-[92vw] max-h-[88vh] overflow-hidden flex flex-col">
        <div v-if="selected" class="flex flex-col overflow-hidden">
          <!-- Header -->
          <div class="flex items-start gap-4 px-6 py-5 border-b shrink-0">
            <UserAvatar :name="selected.name" :size="44" />
            <div class="flex-1 min-w-0">
              <div class="text-[17px] font-semibold leading-tight">{{ selected.name }}</div>
              <div class="font-mono text-[13px] text-muted-foreground mt-0.5">{{ selected.phone }}</div>
            </div>
            <Button variant="outline" size="sm" class="shrink-0 mt-0.5 mr-7" @click="openEdit(selected)">
              <Pencil :size="13" /> Edit
            </Button>
          </div>

          <!-- Info strip -->
          <div class="flex flex-wrap gap-x-8 gap-y-1.5 px-6 py-3.5 border-b bg-muted/30 shrink-0">
            <div v-for="row in detailRows" :key="row.label" class="flex items-center gap-1.5 text-[12.5px]">
              <span class="text-muted-foreground">{{ row.label }}:</span>
              <span class="font-medium">{{ row.value }}</span>
            </div>
          </div>

          <!-- Summary cards -->
          <div class="flex flex-col gap-2 px-6 py-4 border-b shrink-0">
            <!-- Row 1 -->
            <div class="grid grid-cols-4 gap-2">
              <div class="rounded-lg border border-border bg-card px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-muted-foreground font-medium uppercase tracking-wide">Total Orders</span>
                <span v-if="statsLoading" class="h-6 w-10 rounded bg-muted animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight">{{ selected.total_orders ?? 0 }}</span>
              </div>
              <div class="rounded-lg border border-green-200 bg-green-50 dark:bg-green-950/30 dark:border-green-900 px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-green-700 dark:text-green-400 font-medium uppercase tracking-wide">Completed</span>
                <span v-if="statsLoading" class="h-6 w-10 rounded bg-green-100 animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight text-green-700 dark:text-green-400">{{ selected.completed_orders ?? 0 }}</span>
              </div>
              <div class="rounded-lg border border-blue-200 bg-blue-50 dark:bg-blue-950/30 dark:border-blue-900 px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-blue-600 dark:text-blue-400 font-medium uppercase tracking-wide">Total Paid</span>
                <span v-if="statsLoading" class="h-6 w-16 rounded bg-blue-100 animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight text-blue-600 dark:text-blue-400">{{ money(selected.total_paid ?? 0) }}</span>
              </div>
              <div class="rounded-lg border border-blue-300 bg-blue-100 dark:bg-blue-900/30 dark:border-blue-800 px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-blue-800 dark:text-blue-300 font-medium uppercase tracking-wide">Net Spent</span>
                <span v-if="statsLoading" class="h-6 w-16 rounded bg-blue-200 animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight text-blue-800 dark:text-blue-300">{{ money(selected.net_spent ?? 0) }}</span>
              </div>
            </div>
            <!-- Row 2 -->
            <div class="grid grid-cols-4 gap-2">
              <div class="rounded-lg border border-yellow-200 bg-yellow-50 dark:bg-yellow-950/30 dark:border-yellow-900 px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-yellow-700 dark:text-yellow-400 font-medium uppercase tracking-wide">Pending</span>
                <span v-if="statsLoading" class="h-6 w-8 rounded bg-yellow-100 animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight text-yellow-700 dark:text-yellow-400">{{ selected.pending_orders ?? 0 }}</span>
              </div>
              <div class="rounded-lg border border-red-200 bg-red-50 dark:bg-red-950/30 dark:border-red-900 px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-red-600 dark:text-red-400 font-medium uppercase tracking-wide">Cancelled</span>
                <span v-if="statsLoading" class="h-6 w-8 rounded bg-red-100 animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight text-red-600 dark:text-red-400">{{ selected.cancelled_orders ?? 0 }}</span>
              </div>
              <div class="rounded-lg border border-orange-200 bg-orange-50 dark:bg-orange-950/30 dark:border-orange-900 px-4 py-3 flex flex-col gap-0.5">
                <span class="text-[11px] text-orange-600 dark:text-orange-400 font-medium uppercase tracking-wide">Refunded</span>
                <span v-if="statsLoading" class="h-6 w-16 rounded bg-orange-100 animate-pulse mt-1" />
                <span v-else class="text-[22px] font-bold leading-tight text-orange-600 dark:text-orange-400">{{ money(selected.refunded ?? 0) }}</span>
              </div>
              <div />
            </div>
          </div>

          <!-- Tabs + history -->
          <div class="flex-1 overflow-y-auto px-6 py-4">
            <Tabs v-model="historyTab" @update:model-value="onHistoryTabChange">
              <TabsList class="mb-4">
                <TabsTrigger value="orders">Order History</TabsTrigger>
                <TabsTrigger value="deliveries">Delivery History</TabsTrigger>
              </TabsList>

              <!-- Order History -->
              <div v-show="historyTab === 'orders'">
                <div class="mb-3">
                  <select
                    v-model="orderHistoryStatus"
                    class="h-8 rounded-md border border-input bg-background px-3 text-[12.5px] focus:outline-none focus:ring-1 focus:ring-ring"
                    @change="onOrderStatusChange"
                  >
                    <option value="">All status</option>
                    <option v-for="s in ORDER_STATUSES" :key="s" :value="s">{{ s.replace(/_/g, ' ') }}</option>
                  </select>
                </div>
                <div v-if="orderHistoryLoading" class="flex flex-col gap-2">
                  <div v-for="n in 5" :key="n" class="h-8 rounded bg-muted animate-pulse" />
                </div>
                <div v-else class="rounded-lg border border-border overflow-hidden">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead class="w-12">#</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Source</TableHead>
                        <TableHead>Payment Type</TableHead>
                        <TableHead>Payment Method</TableHead>
                        <TableHead class="text-right">Total</TableHead>
                        <TableHead>Staff</TableHead>
                        <TableHead>Date</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      <TableRow v-for="o in orderHistory" :key="o.uuid">
                        <TableCell class="font-mono text-[11.5px] text-muted-foreground">{{ o.id }}</TableCell>
                        <TableCell>
                          <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="orderBadgeStyle(o.status)">
                            {{ o.status.replace(/_/g, ' ') }}
                          </span>
                        </TableCell>
                        <TableCell class="text-[12.5px]">{{ o.page_source }}</TableCell>
                        <TableCell class="text-[12px] text-muted-foreground">{{ o.payment_type === 'PAID_UPFRONT' ? 'Paid upfront' : 'Pay on delivery' }}</TableCell>
                        <TableCell class="text-[12px] text-muted-foreground">{{ o.payment_method ?? '—' }}</TableCell>
                        <TableCell class="text-right font-medium text-[12.5px]">{{ money(o.total_amount) }}</TableCell>
                        <TableCell class="text-[12px] text-muted-foreground">{{ o.staff_name }}</TableCell>
                        <TableCell class="text-[11.5px] text-muted-foreground whitespace-nowrap">{{ fmtDate(o.created_at) }}</TableCell>
                      </TableRow>
                      <TableRow v-if="orderHistory.length === 0">
                        <TableCell colspan="8" class="text-center text-muted-foreground py-8 text-sm">No orders found.</TableCell>
                      </TableRow>
                    </TableBody>
                  </Table>
                </div>
                <div v-if="orderHistoryMeta && orderHistoryMeta.total_pages > 1" class="flex justify-center mt-3">
                  <Pagination :page="orderHistoryPage" :total-pages="orderHistoryMeta.total_pages" @change="onOrderHistoryPage" />
                </div>
              </div>

              <!-- Delivery History -->
              <div v-show="historyTab === 'deliveries'">
                <div v-if="deliveryHistoryLoading" class="flex flex-col gap-2">
                  <div v-for="n in 5" :key="n" class="h-8 rounded bg-muted animate-pulse" />
                </div>
                <div v-else class="rounded-lg border border-border overflow-hidden">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead class="w-12">#</TableHead>
                        <TableHead>Status</TableHead>
                        <TableHead>Driver</TableHead>
                        <TableHead>Partner</TableHead>
                        <TableHead class="text-right">Cost</TableHead>
                        <TableHead class="text-right">Commission</TableHead>
                        <TableHead>Delivered</TableHead>
                        <TableHead>Date</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      <TableRow v-for="d in deliveryHistory" :key="d.uuid">
                        <TableCell class="font-mono text-[11.5px] text-muted-foreground">{{ d.id }}</TableCell>
                        <TableCell>
                          <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="deliveryBadgeStyle(d.status)">
                            {{ d.status.replace(/_/g, ' ') }}
                          </span>
                        </TableCell>
                        <TableCell>
                          <div class="text-[12.5px]">{{ d.driver_name ?? '—' }}</div>
                          <div v-if="d.driver_phone" class="font-mono text-[11px] text-muted-foreground">{{ d.driver_phone }}</div>
                        </TableCell>
                        <TableCell class="text-[12.5px]">{{ PARTNER_LABELS[d.partner_type] ?? d.partner_type }}</TableCell>
                        <TableCell class="text-right text-[12.5px]">{{ money(d.delivery_cost) }}</TableCell>
                        <TableCell class="text-right text-[12.5px]">{{ money(d.commission_earned) }}</TableCell>
                        <TableCell class="text-[11.5px] text-muted-foreground whitespace-nowrap">{{ d.delivered_at ? fmtDate(d.delivered_at) : '—' }}</TableCell>
                        <TableCell class="text-[11.5px] text-muted-foreground whitespace-nowrap">{{ fmtDate(d.created_at) }}</TableCell>
                      </TableRow>
                      <TableRow v-if="deliveryHistory.length === 0">
                        <TableCell colspan="8" class="text-center text-muted-foreground py-8 text-sm">No deliveries found.</TableCell>
                      </TableRow>
                    </TableBody>
                  </Table>
                </div>
                <div v-if="deliveryHistoryMeta && deliveryHistoryMeta.total_pages > 1" class="flex justify-center mt-3">
                  <Pagination :page="deliveryHistoryPage" :total-pages="deliveryHistoryMeta.total_pages" @change="onDeliveryHistoryPage" />
                </div>
              </div>
            </Tabs>
          </div>
        </div>
      </DialogContent>
    </Dialog>

    <!-- Create / edit form sheet -->
    <Sheet :open="formOpen" @update:open="(v) => !v && (formOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">{{ editTarget ? "Edit customer" : "New customer" }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="formOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div class="flex flex-col gap-1.5">
              <Label>Facebook name <span class="text-red-500">*</span></Label>
              <Input v-model="ffacebook" :error="ferrors.facebook_name" placeholder="john.doe" />
              <p v-if="ferrors.facebook_name" class="text-[12px] text-red-500">{{ ferrors.facebook_name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Phone <span class="text-red-500">*</span></Label>
              <Input v-model="fphone" :error="ferrors.phone" placeholder="012345678" />
              <p v-if="ferrors.phone" class="text-[12px] text-red-500">{{ ferrors.phone }}</p>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Province</Label>
                <Input v-model="fprovince" placeholder="Phnom Penh" />
              </div>
              <div class="flex flex-col gap-1.5">
                <Label>Address</Label>
                <Input v-model="faddress" placeholder="St 123" />
              </div>
            </div>
            <div v-if="formError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ formError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="save">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Saving…" : editTarget ? "Save changes" : "Create customer" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <ConfirmDialog
      :open="!!pendingDelete"
      title="Delete customer?"
      :description="`'${pendingDelete?.name}' will be permanently removed. This cannot be undone.`"
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
import { Search, Plus, X, Trash2, AlertTriangle, Loader2, Pencil } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import UserAvatar from "@/components/admin/UserAvatar.vue";
import Pagination from "@/components/admin/Pagination.vue";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useUIStore } from "@/stores/ui";
import {
  fetchCustomer, fetchCustomers, searchCustomers, createCustomer, updateCustomer, deleteCustomer,
  fetchCustomerOrders, fetchCustomerDeliveries,
} from "@/api/customers";
import type { CustomerResponse } from "@/api/customers";
import type { OrderResponse, OrderStatus } from "@/api/orders";
import type { DeliveryResponse } from "@/api/deliveries";
import type { PageMeta } from "@/api/users";
import { fmtDate, money } from "@/utils/format";

const ui = useUIStore();

// ── List ──────────────────────────────────────────────────────
const customers = ref<CustomerResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);
const query = ref("");

let searchTimer: ReturnType<typeof setTimeout> | null = null;

async function load(page = 1) {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchCustomers(page, 20);
    customers.value = res.customers;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load customers.";
  } finally {
    loading.value = false;
  }
}

function onSearch() {
  if (searchTimer) clearTimeout(searchTimer);
  searchTimer = setTimeout(async () => {
    const q = query.value.trim();
    if (!q) { load(1); return; }
    loading.value = true;
    loadError.value = "";
    try {
      customers.value = await searchCustomers(q);
      meta.value = null;
    } catch (e: unknown) {
      loadError.value = e instanceof Error ? e.message : "Search failed.";
    } finally {
      loading.value = false;
    }
  }, 350);
}

function changePage(page: number) {
  currentPage.value = page;
  load(page);
}

onMounted(() => load(1));

// ── Detail dialog ─────────────────────────────────────────────
const selected = ref<CustomerResponse | null>(null);
const statsLoading = ref(false);

const detailRows = computed(() => {
  if (!selected.value) return [];
  const c = selected.value;
  return [
    { label: "Phone", value: c.phone },
    { label: "Facebook", value: c.facebook_name ?? "—" },
    { label: "Province", value: c.province ?? "—" },
    { label: "Address", value: c.address ?? "—" },
    { label: "Joined", value: fmtDate(c.created_at) },
  ];
});

// ── History badges ────────────────────────────────────────────
const ORDER_STATUS_STYLES: Record<string, string> = {
  PENDING:            "background:hsl(var(--muted));color:hsl(var(--muted-foreground))",
  CONFIRMED:          "background:#dbeafe;color:#1d4ed8",
  DELIVERING:         "background:#fef9c3;color:#a16207",
  DELIVERED:          "background:#dcfce7;color:#15803d",
  CANCELLED:          "background:#fee2e2;color:#b91c1c",
  RETURNED:           "background:#fff7ed;color:#c2410c",
  PARTIALLY_RETURNED: "background:#ffedd5;color:#ea580c",
  DELIVERY_FAILED:    "background:#fee2e2;color:#b91c1c",
};

const DELIVERY_STATUS_STYLES: Record<string, string> = {
  PENDING:    "background:hsl(var(--muted));color:hsl(var(--muted-foreground))",
  PICKING:    "background:#dbeafe;color:#1d4ed8",
  DELIVERING: "background:#fef9c3;color:#a16207",
  DELIVERED:  "background:#dcfce7;color:#15803d",
  FAILED:     "background:#fee2e2;color:#b91c1c",
  RETURNED:   "background:#fff7ed;color:#c2410c",
};

const PARTNER_LABELS: Record<string, string> = {
  R_EXPRESS: "R-Express",
  PERSONAL:  "Personal",
  OTHER:     "Other",
};

const ORDER_STATUSES: OrderStatus[] = [
  "PENDING", "CONFIRMED", "DELIVERING", "DELIVERED",
  "CANCELLED", "RETURNED", "PARTIALLY_RETURNED",
];

function orderBadgeStyle(status: string) {
  return ORDER_STATUS_STYLES[status] ?? ORDER_STATUS_STYLES.PENDING;
}

function deliveryBadgeStyle(status: string) {
  return DELIVERY_STATUS_STYLES[status] ?? DELIVERY_STATUS_STYLES.PENDING;
}

// ── History state ─────────────────────────────────────────────
const historyTab = ref("orders");

const orderHistory = ref<OrderResponse[]>([]);
const orderHistoryMeta = ref<PageMeta | null>(null);
const orderHistoryLoading = ref(false);
const orderHistoryPage = ref(1);
const orderHistoryStatus = ref<OrderStatus | "">("");

const deliveryHistory = ref<DeliveryResponse[]>([]);
const deliveryHistoryMeta = ref<PageMeta | null>(null);
const deliveryHistoryLoading = ref(false);
const deliveryHistoryPage = ref(1);

async function loadOrderHistory() {
  if (!selected.value) return;
  orderHistoryLoading.value = true;
  try {
    const res = await fetchCustomerOrders(
      selected.value.uuid,
      orderHistoryPage.value,
      20,
      orderHistoryStatus.value || undefined,
    );
    orderHistory.value = res.orders;
    orderHistoryMeta.value = res.meta;
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to load order history.", "danger");
  } finally {
    orderHistoryLoading.value = false;
  }
}

async function loadDeliveryHistory() {
  if (!selected.value) return;
  deliveryHistoryLoading.value = true;
  try {
    const res = await fetchCustomerDeliveries(selected.value.uuid, deliveryHistoryPage.value, 20);
    deliveryHistory.value = res.deliveries;
    deliveryHistoryMeta.value = res.meta;
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to load delivery history.", "danger");
  } finally {
    deliveryHistoryLoading.value = false;
  }
}

function onHistoryTabChange(tab: string | number) {
  if (tab === "orders" && orderHistory.value.length === 0 && !orderHistoryLoading.value) {
    loadOrderHistory();
  } else if (tab === "deliveries" && deliveryHistory.value.length === 0 && !deliveryHistoryLoading.value) {
    loadDeliveryHistory();
  }
}

function onOrderStatusChange() {
  orderHistoryPage.value = 1;
  loadOrderHistory();
}

function onOrderHistoryPage(p: number) {
  orderHistoryPage.value = p;
  loadOrderHistory();
}

function onDeliveryHistoryPage(p: number) {
  deliveryHistoryPage.value = p;
  loadDeliveryHistory();
}

function openDetail(c: CustomerResponse) {
  selected.value = c;
  historyTab.value = "orders";
  orderHistory.value = [];
  orderHistoryMeta.value = null;
  orderHistoryPage.value = 1;
  orderHistoryStatus.value = "";
  deliveryHistory.value = [];
  deliveryHistoryMeta.value = null;
  deliveryHistoryPage.value = 1;
  statsLoading.value = true;
  fetchCustomer(c.uuid)
    .then((detail) => { if (selected.value?.uuid === detail.uuid) selected.value = detail; })
    .catch(() => {})
    .finally(() => { statsLoading.value = false; });
  loadOrderHistory();
}

// ── Create / edit form ────────────────────────────────────────
const Schema = z.object({
  phone: z.string().min(1, "Phone is required"),
  facebook_name: z.string().min(1, "Facebook name is required"),
  province: z.string().optional(),
  address: z.string().optional(),
});

const { defineField, handleSubmit, errors: ferrors, resetForm, setValues } = useForm({
  validationSchema: toTypedSchema(Schema),
  initialValues: { phone: "", facebook_name: "", province: "", address: "" },
});

const [fphone] = defineField("phone");
const [ffacebook] = defineField("facebook_name");
const [fprovince] = defineField("province");
const [faddress] = defineField("address");

const formOpen = ref(false);
const formError = ref("");
const saving = ref(false);
const editTarget = ref<CustomerResponse | null>(null);

function openCreate() {
  editTarget.value = null;
  resetForm();
  formError.value = "";
  formOpen.value = true;
}

function openEdit(c: CustomerResponse) {
  editTarget.value = c;
  setValues({ phone: c.phone, facebook_name: c.facebook_name ?? "", province: c.province ?? "", address: c.address ?? "" });
  formError.value = "";
  formOpen.value = true;
}

const save = handleSubmit(async (values) => {
  saving.value = true;
  formError.value = "";
  try {
    const payload = {
      name: values.facebook_name,
      phone: values.phone,
      facebook_name: values.facebook_name,
      province: values.province || undefined,
      address: values.address || undefined,
    };
    if (editTarget.value) {
      const updated = await updateCustomer(editTarget.value.uuid, payload);
      const idx = customers.value.findIndex((c) => c.uuid === editTarget.value!.uuid);
      if (idx !== -1) customers.value[idx] = updated;
      if (selected.value?.uuid === updated.uuid) selected.value = updated;
      ui.showToast("Customer updated", "success");
    } else {
      const created = await createCustomer(payload);
      customers.value.unshift(created);
      ui.showToast("Customer created", "success");
    }
    formOpen.value = false;
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : "Failed to save.";
  } finally {
    saving.value = false;
  }
});

// ── Delete ────────────────────────────────────────────────────
const pendingDelete = ref<CustomerResponse | null>(null);
const deleting = ref(false);

function confirmRemove(c: CustomerResponse) { pendingDelete.value = c; }

async function doDelete() {
  if (!pendingDelete.value) return;
  deleting.value = true;
  try {
    await deleteCustomer(pendingDelete.value.uuid);
    customers.value = customers.value.filter((c) => c.uuid !== pendingDelete.value!.uuid);
    if (selected.value?.uuid === pendingDelete.value.uuid) selected.value = null;
    pendingDelete.value = null;
    ui.showToast("Customer deleted", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to delete.", "danger");
  } finally {
    deleting.value = false;
  }
}
</script>
