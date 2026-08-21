<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ meta ? meta.total + " deliveries" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New delivery</Button>
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Customer</TableHead>
              <TableHead>Driver</TableHead>
              <TableHead>Partner</TableHead>
              <TableHead>Cost</TableHead>
              <TableHead>Commission</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Date</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 8" :key="'s'+n">
              <TableCell colspan="8"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow v-for="d in deliveries" :key="d.uuid" class="cursor-pointer hover:bg-muted/40 transition-colors" @click="openDetail(d)">
                <TableCell>
                  <div class="font-medium">{{ d.recipient_name }}</div>
                  <div class="font-mono text-[11.5px] text-muted-foreground">{{ d.recipient_phone }}</div>
                </TableCell>
                <TableCell class="text-[13px]">{{ d.driver_name ?? "—" }}</TableCell>
                <TableCell>
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold bg-muted text-muted-foreground">
                    {{ partnerLabel(d.partner_type) }}
                  </span>
                </TableCell>
                <TableCell class="font-medium">{{ money(d.delivery_cost) }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ money(d.commission_earned) }}</TableCell>
                <TableCell><DeliveryStatusBadge :status="d.status" /></TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(d.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button variant="outline" size="sm" class="h-7 text-[12px]" @click="openStatusUpdate(d)">
                    Update status
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="deliveries.length === 0 && !loadError">
                <TableCell colspan="8" class="text-center text-muted-foreground py-12 text-sm">No deliveries found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div v-if="meta && meta.total_pages > 1" class="flex justify-center mt-4">
        <Pagination :page="currentPage" :total-pages="meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Detail sheet -->
    <Sheet :open="!!selectedDelivery" @update:open="(v) => !v && (selectedDelivery = null)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div v-if="selectedDelivery" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">Delivery detail</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="selectedDelivery = null"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4">
            <div class="flex flex-col gap-0 rounded-lg border border-border overflow-hidden">
              <div v-for="row in detailRows" :key="row.label" class="flex items-center px-4 py-3 border-b border-border/50 last:border-0">
                <span class="w-36 text-[12.5px] text-muted-foreground shrink-0">{{ row.label }}</span>
                <span class="text-[13px]" v-if="row.label !== 'Status'">{{ row.value }}</span>
                <DeliveryStatusBadge v-else :status="selectedDelivery.status" />
              </div>
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Create delivery drawer -->
    <Sheet :open="createOpen" @update:open="(v) => !v && (createOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">New delivery</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="createOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">

            <!-- Order dropdown -->
            <div class="flex flex-col gap-1.5">
              <Label>Order <span class="text-red-500">*</span></Label>
              <div v-if="ordersLoading" class="h-9 rounded-md bg-muted animate-pulse" />
              <select
                v-else
                v-model="cform.orderUuid"
                class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring"
                :class="createError && !cform.orderUuid ? 'border-red-400' : ''"
              >
                <option value="" disabled>Select a confirmed order…</option>
                <option v-for="o in confirmedOrders" :key="o.uuid" :value="o.uuid">
                  #{{ o.id }} — {{ o.customer_name }} — {{ o.customer_phone }}
                </option>
              </select>
              <p v-if="confirmedOrders.length === 0 && !ordersLoading" class="text-[12px] text-muted-foreground">No confirmed orders available.</p>
            </div>

            <!-- Partner type -->
            <div class="flex flex-col gap-1.5">
              <Label>Partner type <span class="text-red-500">*</span></Label>
              <select v-model="cform.partnerType" class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                <option value="R_EXPRESS">R-Express</option>
                <option value="PERSONAL">Personal</option>
                <option value="OTHER">Other</option>
              </select>
            </div>

            <!-- Driver dropdown -->
            <div class="flex flex-col gap-1.5">
              <Label>Driver <span class="text-[12px] text-muted-foreground font-normal">(optional)</span></Label>
              <div v-if="driversLoading" class="h-9 rounded-md bg-muted animate-pulse" />
              <select
                v-else
                v-model="cform.driverUuid"
                class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring"
              >
                <option value="">No driver yet</option>
                <option v-for="d in driverList" :key="d.uuid" :value="d.uuid">
                  {{ d.name }} — {{ d.phone }}
                </option>
              </select>
            </div>

            <!-- Delivery cost -->
            <div class="flex flex-col gap-1.5">
              <Label>Delivery cost ($) <span class="text-red-500">*</span></Label>
              <Input v-model="cform.deliveryCost" type="number" min="0" step="0.01" placeholder="0.00" />
            </div>

            <!-- Note -->
            <div class="flex flex-col gap-1.5">
              <Label>Note</Label>
              <Input v-model="cform.note" placeholder="Deliver before 5pm" />
            </div>

            <div v-if="createError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ createError }}
            </div>
            <Button class="w-full mt-1" :disabled="creating || ordersLoading || driversLoading" @click="submitDelivery">
              <Loader2 v-if="creating" :size="14" class="animate-spin" />
              {{ creating ? "Creating…" : "Create delivery" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Status update sheet -->
    <Sheet :open="!!statusTarget" @update:open="(v) => !v && (statusTarget = null)">
      <SheetContent class="overflow-y-auto p-0 w-[360px] sm:max-w-[360px]">
        <div v-if="statusTarget" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">Update status</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="statusTarget = null"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4">
            <div class="flex items-center gap-2 text-[13px]">
              <span class="text-muted-foreground">Current:</span>
              <DeliveryStatusBadge :status="statusTarget.status" />
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>New status <span class="text-red-500">*</span></Label>
              <select v-model="newStatus" class="h-9 rounded-md border border-input bg-background px-3 text-[13px] focus:outline-none focus:ring-1 focus:ring-ring">
                <option v-for="s in DELIVERY_STATUSES" :key="s" :value="s">{{ s.replace(/_/g,' ') }}</option>
              </select>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Note</Label>
              <Input v-model="statusNote" placeholder="Delivered successfully" />
            </div>
            <div v-if="statusError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ statusError }}
            </div>
            <Button class="w-full" :disabled="statusUpdating" @click="doStatusUpdate">
              <Loader2 v-if="statusUpdating" :size="14" class="animate-spin" />
              {{ statusUpdating ? "Saving…" : "Save" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, reactive, onMounted, h } from "vue";
import { Plus, X, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import Pagination from "@/components/admin/Pagination.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import { fetchDeliveries, createDelivery, updateDeliveryStatus } from "@/api/deliveries";
import type { DeliveryResponse, DeliveryStatus, DeliveryPartnerType } from "@/api/deliveries";
import { fetchOrders } from "@/api/orders";
import type { OrderResponse } from "@/api/orders";
import { fetchDrivers } from "@/api/drivers";
import type { DriverResponse } from "@/api/drivers";
import type { PageMeta } from "@/api/users";
import { money, fmtDate } from "@/utils/format";

const DELIVERY_STATUSES: DeliveryStatus[] = ["PENDING", "PICKING", "DELIVERING", "DELIVERED", "FAILED", "RETURNED"];

const DELIVERY_STATUS_STYLES: Record<string, string> = {
  PENDING:    "background:var(--amber-bg);color:var(--amber)",
  PICKING:    "background:#dbeafe;color:#1d4ed8",
  DELIVERING: "background:#ede9fe;color:#6d28d9",
  DELIVERED:  "background:var(--green-bg);color:var(--green)",
  FAILED:     "background:var(--red-bg);color:var(--red)",
  RETURNED:   "background:hsl(var(--muted));color:hsl(var(--muted-foreground))",
};
const DeliveryStatusBadge = {
  props: ["status"],
  setup(props: { status?: string }) {
    return () => {
      const s = (props.status ?? "").toUpperCase();
      return h("span", {
        class: "inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold",
        style: DELIVERY_STATUS_STYLES[s] ?? "",
      }, [h("span", { class: "status-dot" }), s.replace(/_/g, " ")]);
    };
  },
};

const ui = useUIStore();
const deliveries = ref<DeliveryResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);

async function load(page = 1) {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchDeliveries(page, 20);
    deliveries.value = res.deliveries;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load deliveries.";
  } finally {
    loading.value = false;
  }
}

function changePage(page: number) { currentPage.value = page; load(page); }
onMounted(() => load(1));

// ── Detail sheet ──────────────────────────────────────────────
const selectedDelivery = ref<DeliveryResponse | null>(null);

const detailRows = computed(() => {
  const d = selectedDelivery.value;
  if (!d) return [];
  return [
    { label: "Status", value: d.status },
    { label: "Recipient", value: d.recipient_name },
    { label: "Phone", value: d.recipient_phone },
    { label: "Address", value: d.recipient_address ?? "—" },
    { label: "Driver", value: d.driver_name ?? "—" },
    { label: "Driver phone", value: d.driver_phone ?? "—" },
    { label: "Partner", value: partnerLabel(d.partner_type) },
    { label: "Delivery cost", value: money(d.delivery_cost) },
    { label: "Commission", value: money(d.commission_earned) },
    { label: "Delivered at", value: d.delivered_at ? fmtDate(d.delivered_at) : "—" },
    { label: "Note", value: d.note ?? "—" },
    { label: "Created", value: fmtDate(d.created_at) },
  ];
});

function openDetail(d: DeliveryResponse) { selectedDelivery.value = d; }

// ── Create form ───────────────────────────────────────────────
const confirmedOrders = ref<OrderResponse[]>([]);
const driverList = ref<DriverResponse[]>([]);
const ordersLoading = ref(false);
const driversLoading = ref(false);

const cform = reactive({
  orderUuid: "",
  partnerType: "R_EXPRESS" as DeliveryPartnerType,
  driverUuid: "",
  deliveryCost: "",
  note: "",
});

const createOpen = ref(false);
const createError = ref("");
const creating = ref(false);

async function openCreate() {
  Object.assign(cform, { orderUuid: "", partnerType: "R_EXPRESS", driverUuid: "", deliveryCost: "", note: "" });
  createError.value = "";
  createOpen.value = true;

  ordersLoading.value = true;
  driversLoading.value = true;
  try {
    const [ordersRes, driversRes] = await Promise.all([
      fetchOrders(1, 100, "CONFIRMED"),
      fetchDrivers(100),
    ]);
    confirmedOrders.value = ordersRes.orders ?? [];
    driverList.value = driversRes.drivers ?? [];
  } catch { /* silent — dropdowns stay empty */ } finally {
    ordersLoading.value = false;
    driversLoading.value = false;
  }
}

async function submitDelivery() {
  if (!cform.orderUuid) { createError.value = "Please select an order."; return; }
  const cost = parseFloat(cform.deliveryCost);
  if (isNaN(cost) || cost < 0) { createError.value = "Please enter a valid delivery cost (min 0)."; return; }
  creating.value = true;
  createError.value = "";
  try {
    const created = await createDelivery({
      order_uuid: cform.orderUuid,
      partner_type: cform.partnerType,
      driver_uuid: cform.driverUuid || undefined,
      delivery_cost: cost,
      note: cform.note.trim() || undefined,
    });
    deliveries.value.unshift(created);
    createOpen.value = false;
    ui.showToast("Delivery created", "success");
  } catch (e: unknown) {
    createError.value = e instanceof Error ? e.message : "Failed to create delivery.";
  } finally {
    creating.value = false;
  }
}

// ── Status update ─────────────────────────────────────────────
const statusTarget = ref<DeliveryResponse | null>(null);
const newStatus = ref<DeliveryStatus>("PENDING");
const statusNote = ref("");
const statusError = ref("");
const statusUpdating = ref(false);

function openStatusUpdate(d: DeliveryResponse) {
  statusTarget.value = d;
  newStatus.value = d.status;
  statusNote.value = "";
  statusError.value = "";
}

async function doStatusUpdate() {
  if (!statusTarget.value) return;
  statusUpdating.value = true;
  statusError.value = "";
  try {
    const updated = await updateDeliveryStatus(statusTarget.value.uuid, {
      status: newStatus.value,
      note: statusNote.value.trim() || undefined,
    });
    const idx = deliveries.value.findIndex((d) => d.uuid === updated.uuid);
    if (idx !== -1) deliveries.value[idx] = updated;
    if (selectedDelivery.value?.uuid === updated.uuid) selectedDelivery.value = updated;
    statusTarget.value = null;
    ui.showToast("Status updated", "success");
  } catch (e: unknown) {
    statusError.value = e instanceof Error ? e.message : "Failed to update status.";
  } finally {
    statusUpdating.value = false;
  }
}

function partnerLabel(t: DeliveryPartnerType) {
  const m: Record<DeliveryPartnerType, string> = { R_EXPRESS: "R-Express", PERSONAL: "Personal", OTHER: "Other" };
  return m[t] ?? t;
}
</script>
