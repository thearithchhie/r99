<template>
  <AdminLayout>
    <div class="fade p-5">
      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div class="h-8 rounded bg-muted animate-pulse w-64" />
        <div class="h-4 rounded bg-muted animate-pulse w-40" />
        <div class="h-64 rounded bg-muted animate-pulse w-full mt-6" />
      </div>

      <!-- Error -->
      <div v-else-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <template v-else-if="purchase">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-start gap-4 mb-6">
          <div class="flex-1">
            <div class="flex items-center gap-3 flex-wrap">
              <h1 class="text-[22px] font-bold font-mono">{{ purchase.order_number }}</h1>
              <span
                class="inline-flex items-center rounded-md px-2.5 py-1 text-xs font-semibold"
                :style="purchaseStatusStyle(purchase.status)"
              >{{ purchase.status }}</span>
            </div>
            <div class="text-muted-foreground text-[13.5px] mt-1">
              Supplier: <span class="font-medium text-foreground">{{ purchase.supplier_name }}</span>
              &nbsp;·&nbsp; Created: <span class="font-medium text-foreground">{{ fmtDate(purchase.created_at) }}</span>
            </div>
          </div>

          <!-- Action buttons -->
          <div class="flex items-center gap-2 flex-wrap">
            <template v-if="purchase.status === 'DRAFT'">
              <Button size="sm" :disabled="!!actionLoading" @click="doConfirm">
                <Loader2 v-if="actionLoading === 'confirm'" :size="13" class="animate-spin" />
                Confirm Order
              </Button>
              <Button variant="outline" size="sm" :disabled="!!actionLoading" @click="confirmCancel = true">
                Cancel
              </Button>
            </template>
            <template v-else-if="purchase.status === 'ORDERED' || purchase.status === 'PARTIALLY_RECEIVED'">
              <Button size="sm" :disabled="!!actionLoading" @click="openReceive">
                Receive Items
              </Button>
              <Button variant="outline" size="sm" :disabled="!!actionLoading" @click="confirmCancel = true">
                Cancel
              </Button>
            </template>
          </div>
        </div>

        <!-- Items table -->
        <Card class="mb-5">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Product</TableHead>
                <TableHead>Code</TableHead>
                <TableHead class="text-right">Ordered</TableHead>
                <TableHead class="text-right">Received</TableHead>
                <TableHead class="text-right">Remaining</TableHead>
                <TableHead class="text-right">Unit Cost</TableHead>
                <TableHead class="text-right">Discount</TableHead>
                <TableHead class="text-right">Subtotal</TableHead>
                <TableHead>Progress</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="item in purchase.items" :key="item.uuid">
                <TableCell class="font-medium">{{ item.product_name }}</TableCell>
                <TableCell class="font-mono text-[12px] text-muted-foreground">{{ item.product_code }}</TableCell>
                <TableCell class="text-right">{{ item.quantity }}</TableCell>
                <TableCell class="text-right">{{ item.received_quantity }}</TableCell>
                <TableCell class="text-right">{{ item.remaining_quantity }}</TableCell>
                <TableCell class="text-right">{{ money(item.cost_price) }}</TableCell>
                <TableCell class="text-right text-muted-foreground">{{ item.discount_amount ? money(item.discount_amount) : "—" }}</TableCell>
                <TableCell class="text-right font-semibold">{{ money(item.subtotal) }}</TableCell>
                <TableCell class="min-w-[100px]">
                  <div class="flex items-center gap-2">
                    <div class="flex-1 bg-muted rounded-full h-1.5 overflow-hidden">
                      <div
                        class="h-full bg-primary rounded-full transition-all"
                        :style="{ width: `${item.quantity > 0 ? Math.round((item.received_quantity / item.quantity) * 100) : 0}%` }"
                      />
                    </div>
                    <span class="text-[11px] text-muted-foreground shrink-0">
                      {{ item.quantity > 0 ? Math.round((item.received_quantity / item.quantity) * 100) : 0 }}%
                    </span>
                  </div>
                </TableCell>
              </TableRow>
              <TableRow v-if="purchase.items.length === 0">
                <TableCell colspan="9" class="text-center text-muted-foreground py-8 text-sm">No items.</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </Card>

        <!-- Arrival History -->
        <div
          v-if="arrivals.length > 0"
          class="mb-5"
        >
          <h2 class="text-[14px] font-semibold mb-2">Arrival History</h2>
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product</TableHead>
                  <TableHead>Code</TableHead>
                  <TableHead class="text-right">Qty Received</TableHead>
                  <TableHead>Arrived At</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow v-for="(a, i) in arrivals" :key="i">
                  <TableCell class="font-medium">{{ a.product_name }}</TableCell>
                  <TableCell class="font-mono text-[12px] text-muted-foreground">{{ a.product_code }}</TableCell>
                  <TableCell class="text-right">
                    <span class="text-green-600 font-semibold">+{{ a.quantity_received }}</span>
                  </TableCell>
                  <TableCell class="text-[12.5px] text-muted-foreground whitespace-nowrap">{{ fmtDate(a.arrived_at) }}</TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </Card>
        </div>

        <!-- Totals + Note -->
        <div class="flex flex-col sm:flex-row gap-5">
          <!-- Note -->
          <div v-if="purchase.note" class="flex-1">
            <div class="text-[13px] font-semibold text-muted-foreground mb-1">Note</div>
            <div class="text-[13.5px] rounded-lg border border-border bg-muted/30 px-4 py-3">{{ purchase.note }}</div>
          </div>
          <div v-else class="flex-1" />

          <!-- Totals (right-aligned) -->
          <div class="min-w-[240px]">
            <div class="rounded-lg border border-border bg-card p-4 flex flex-col gap-2 text-[13.5px]">
              <div class="flex justify-between">
                <span class="text-muted-foreground">Subtotal</span>
                <span>{{ money(purchase.subtotal) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-muted-foreground">Discount</span>
                <span>{{ money(purchase.discount_amount) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-muted-foreground">Tax</span>
                <span>{{ money(purchase.tax_amount) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-muted-foreground">Shipping</span>
                <span>{{ money(purchase.shipping_cost) }}</span>
              </div>
              <div class="flex justify-between font-bold text-[15px] border-t pt-2 mt-1">
                <span>Total</span>
                <span>{{ money(purchase.total_amount) }}</span>
              </div>
            </div>
          </div>
        </div>
      </template>
    </div>

    <!-- Receive Items Sheet -->
    <Sheet :open="receiveOpen" @update:open="(v) => !v && (receiveOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[480px] sm:max-w-[480px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background z-10">
            <span class="text-[15px] font-semibold">Receive Items</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="receiveOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div
              v-for="item in receiveItems"
              :key="item.purchase_item_uuid"
              class="flex items-center gap-3 py-2 border-b border-border last:border-0"
            >
              <div class="flex-1 min-w-0">
                <div class="text-[13.5px] font-medium truncate">{{ item.product_name }}</div>
                <div class="text-muted-foreground text-[12px] font-mono">{{ item.product_code }}</div>
                <div class="text-muted-foreground text-[12px]">Remaining: {{ item.remaining_quantity }}</div>
              </div>
              <Input
                v-model.number="item.received_quantity"
                type="number"
                min="0"
                :max="item.remaining_quantity"
                class="w-20 text-center"
              />
            </div>

            <div class="flex flex-col gap-1.5 pt-2">
              <Label>Note</Label>
              <textarea
                v-model="receiveNote"
                rows="2"
                placeholder="Optional note…"
                class="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm transition-colors placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring resize-none"
              />
            </div>

            <div v-if="receiveError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ receiveError }}
            </div>

            <Button class="w-full" :disabled="receiving" @click="doReceive">
              <Loader2 v-if="receiving" :size="14" class="animate-spin" />
              {{ receiving ? "Saving…" : "Confirm Receipt" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Cancel Confirm Dialog -->
    <ConfirmDialog
      :open="confirmCancel"
      title="Cancel purchase?"
      description="This will cancel the purchase order. This action cannot be undone."
      confirm-label="Cancel Order"
      loading-label="Cancelling…"
      :loading="actionLoading === 'cancel'"
      @confirm="doCancel"
      @cancel="confirmCancel = false"
    />
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { X, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import {
  fetchPurchase,
  confirmPurchase,
  receivePurchase,
  cancelPurchase,
  fetchPurchaseArrivals,
} from "@/api/purchases";
import type { PurchaseResponse, PurchaseStatus, ArrivalRecord } from "@/api/purchases";
import { fmtDate, money } from "@/utils/format";

const ui = useUIStore();
const route = useRoute();
const uuid = route.params.uuid as string;

const purchase = ref<PurchaseResponse | null>(null);
const loading = ref(false);
const loadError = ref("");

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

const arrivals = ref<ArrivalRecord[]>([]);

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    const [p, a] = await Promise.all([
      fetchPurchase(uuid),
      fetchPurchaseArrivals(uuid),
    ]);
    purchase.value = p;
    arrivals.value = a;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load purchase.";
  } finally {
    loading.value = false;
  }
}

onMounted(load);

// ── Actions ───────────────────────────────────────────────────
const actionLoading = ref<"confirm" | "cancel" | "">("");
const confirmCancel = ref(false);

async function doConfirm() {
  actionLoading.value = "confirm";
  try {
    purchase.value = await confirmPurchase(uuid);
    ui.showToast("Purchase confirmed", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to confirm.", "danger");
  } finally {
    actionLoading.value = "";
  }
}

async function doCancel() {
  actionLoading.value = "cancel";
  try {
    purchase.value = await cancelPurchase(uuid);
    confirmCancel.value = false;
    ui.showToast("Purchase cancelled", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to cancel.", "danger");
  } finally {
    actionLoading.value = "";
  }
}

// ── Receive Items ─────────────────────────────────────────────
interface ReceiveRow {
  purchase_item_uuid: string;
  product_name: string;
  product_code: string;
  remaining_quantity: number;
  received_quantity: number;
}

const receiveOpen = ref(false);
const receiveItems = ref<ReceiveRow[]>([]);
const receiveNote = ref("");
const receiving = ref(false);
const receiveError = ref("");

function openReceive() {
  if (!purchase.value) return;
  receiveItems.value = purchase.value.items
    .filter((i) => i.remaining_quantity > 0)
    .map((i) => ({
      purchase_item_uuid: i.uuid,
      product_name: i.product_name,
      product_code: i.product_code,
      remaining_quantity: i.remaining_quantity,
      received_quantity: i.remaining_quantity,
    }));
  receiveNote.value = "";
  receiveError.value = "";
  receiveOpen.value = true;
}

async function doReceive() {
  receiveError.value = "";
  const items = receiveItems.value.map((i) => ({
    purchase_item_uuid: i.purchase_item_uuid,
    received_quantity: Math.min(i.received_quantity, i.remaining_quantity),
  }));

  receiving.value = true;
  try {
    const [p, a] = await Promise.all([
      receivePurchase(uuid, { items, note: receiveNote.value || undefined }),
      fetchPurchaseArrivals(uuid),
    ]);
    purchase.value = p;
    arrivals.value = a;
    receiveOpen.value = false;
    ui.showToast("Items received", "success");
  } catch (e: unknown) {
    receiveError.value = e instanceof Error ? e.message : "Failed to receive items.";
  } finally {
    receiving.value = false;
  }
}
</script>
