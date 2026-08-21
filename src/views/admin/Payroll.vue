<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ meta ? meta.total + " payrolls" : "" }}
        </p>
        <Button size="sm" @click="openGenerate"><Plus :size="14" /> Generate payroll</Button>
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Week</TableHead>
              <TableHead>Note</TableHead>
              <TableHead class="text-right">Total</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Paid at</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 5" :key="'s'+n">
              <TableCell colspan="6"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="p in payrolls"
                :key="p.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="openDetail(p)"
              >
                <TableCell>
                  <div class="font-medium text-[13px]">{{ p.week_start }} – {{ p.week_end }}</div>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ p.note ?? "—" }}</TableCell>
                <TableCell class="text-right font-semibold">{{ money(p.total_amount) }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="p.status?.toUpperCase() === 'PAID' ? 'background:var(--green-bg);color:var(--green)' : 'background:var(--amber-bg);color:var(--amber)'"
                  >
                    <span class="status-dot" />{{ p.status?.toUpperCase() }}
                  </span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ p.paid_at ? fmtDate(p.paid_at) : "—" }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button
                    v-if="p.status?.toUpperCase() === 'DRAFT'"
                    size="sm"
                    class="h-7 text-[12px]"
                    :disabled="markingPaid === p.uuid"
                    @click="confirmMarkPaid(p)"
                  >
                    <Loader2 v-if="markingPaid === p.uuid" :size="12" class="animate-spin" />
                    Mark as paid
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="payrolls.length === 0 && !loadError">
                <TableCell colspan="6" class="text-center text-muted-foreground py-12 text-sm">No payrolls yet. Generate the first one.</TableCell>
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
    <Sheet :open="!!selectedPayroll" @update:open="(v) => !v && (selectedPayroll = null)">
      <SheetContent class="overflow-y-auto p-0 w-[480px] sm:max-w-[480px]">
        <div v-if="selectedPayroll" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div>
              <span class="text-[15px] font-semibold">Payroll detail</span>
              <p class="text-[12.5px] text-muted-foreground mt-0.5">{{ selectedPayroll.week_start }} – {{ selectedPayroll.week_end }}</p>
            </div>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="selectedPayroll = null"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4">
            <!-- Summary -->
            <div class="flex flex-col gap-0 rounded-lg border border-border overflow-hidden">
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Status</span>
                <span class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                  :style="selectedPayroll.status?.toUpperCase() === 'PAID' ? 'background:var(--green-bg);color:var(--green)' : 'background:var(--amber-bg);color:var(--amber)'">
                  <span class="status-dot" />{{ selectedPayroll.status?.toUpperCase() }}
                </span>
              </div>
              <div class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Total</span>
                <span class="font-semibold">{{ money(selectedPayroll.total_amount) }}</span>
              </div>
              <div v-if="selectedPayroll.note" class="flex items-center px-4 py-3 border-b border-border/50">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Note</span>
                <span class="text-[13px]">{{ selectedPayroll.note }}</span>
              </div>
              <div v-if="selectedPayroll.paid_at" class="flex items-center px-4 py-3">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">Paid at</span>
                <span class="text-[13px]">{{ fmtDate(selectedPayroll.paid_at) }}</span>
              </div>
            </div>

            <!-- Line items -->
            <div>
              <p class="text-[13px] font-semibold mb-2">Breakdown</p>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Recipient</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead class="text-center">Commissions</TableHead>
                    <TableHead class="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow v-for="item in selectedPayroll.items" :key="item.id">
                    <TableCell class="font-medium">{{ item.recipient_name }}</TableCell>
                    <TableCell>
                      <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold bg-muted text-muted-foreground">
                        {{ item.recipient_type }}
                      </span>
                    </TableCell>
                    <TableCell class="text-center text-muted-foreground">{{ item.commission_count }}</TableCell>
                    <TableCell class="text-right font-semibold text-green-600">{{ money(item.total_amount) }}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Generate payroll drawer -->
    <Sheet :open="generateOpen" @update:open="(v) => !v && (generateOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">Generate payroll</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="generateOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Week start <span class="text-red-500">*</span></Label>
                <Input v-model="gform.weekStart" type="date" />
              </div>
              <div class="flex flex-col gap-1.5">
                <Label>Week end <span class="text-red-500">*</span></Label>
                <Input v-model="gform.weekEnd" type="date" />
              </div>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Note</Label>
              <Input v-model="gform.note" placeholder="Week 33" />
            </div>

            <!-- Staff selection -->
            <div class="flex flex-col gap-1.5">
              <div class="flex items-center justify-between">
                <Label>Staff <span class="text-[12px] text-muted-foreground font-normal">(empty = all staff)</span></Label>
                <button v-if="selectedStaffUuids.length" class="text-[12px] text-primary hover:underline" @click="selectedStaffUuids = []">Clear</button>
              </div>
              <div v-if="staffLoading" class="h-9 rounded-md bg-muted animate-pulse" />
              <div v-else class="rounded-md border border-input max-h-36 overflow-y-auto">
                <label
                  v-for="s in staffList" :key="s.uuid"
                  class="flex items-center gap-2.5 px-3 py-2 cursor-pointer hover:bg-muted/40 border-b border-border/40 last:border-0 transition-colors"
                  :class="selectedStaffUuids.includes(s.uuid) ? 'bg-primary/5' : ''"
                >
                  <input type="checkbox" :value="s.uuid" v-model="selectedStaffUuids" class="w-4 h-4 rounded accent-primary shrink-0" />
                  <span class="text-[13px] font-medium flex-1">{{ s.name }}</span>
                  <span class="text-[11.5px] text-muted-foreground">{{ s.role }}</span>
                </label>
                <p v-if="staffList.length === 0" class="px-3 py-2 text-[13px] text-muted-foreground">No staff found.</p>
              </div>
              <p v-if="selectedStaffUuids.length" class="text-[12px] text-muted-foreground">{{ selectedStaffUuids.length }} staff selected</p>
            </div>

            <!-- Driver selection -->
            <div class="flex flex-col gap-1.5">
              <div class="flex items-center justify-between">
                <Label>Drivers <span class="text-[12px] text-muted-foreground font-normal">(empty = all drivers)</span></Label>
                <button v-if="selectedDriverUuids.length" class="text-[12px] text-primary hover:underline" @click="selectedDriverUuids = []">Clear</button>
              </div>
              <div v-if="driversLoading" class="h-9 rounded-md bg-muted animate-pulse" />
              <div v-else class="rounded-md border border-input max-h-36 overflow-y-auto">
                <label
                  v-for="d in driverList" :key="d.uuid"
                  class="flex items-center gap-2.5 px-3 py-2 cursor-pointer hover:bg-muted/40 border-b border-border/40 last:border-0 transition-colors"
                  :class="selectedDriverUuids.includes(d.uuid) ? 'bg-primary/5' : ''"
                >
                  <input type="checkbox" :value="d.uuid" v-model="selectedDriverUuids" class="w-4 h-4 rounded accent-primary shrink-0" />
                  <span class="text-[13px] font-medium flex-1">{{ d.name }}</span>
                  <span class="text-[11.5px] text-muted-foreground font-mono">{{ d.phone }}</span>
                </label>
                <p v-if="driverList.length === 0" class="px-3 py-2 text-[13px] text-muted-foreground">No drivers found.</p>
              </div>
              <p v-if="selectedDriverUuids.length" class="text-[12px] text-muted-foreground">{{ selectedDriverUuids.length }} driver(s) selected</p>
            </div>

            <div class="rounded-lg border border-border/60 bg-muted/30 px-4 py-3 text-[12.5px] text-muted-foreground">
              Collects all pending commissions in the date range, groups by staff and driver, and marks them as paid. Safe to generate once per week.
            </div>
            <div v-if="generateError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ generateError }}
            </div>
            <Button class="w-full mt-1" :disabled="generating" @click="doGenerate">
              <Loader2 v-if="generating" :size="14" class="animate-spin" />
              {{ generating ? "Generating…" : "Generate" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Mark as paid confirm -->
    <ConfirmDialog
      :open="!!pendingPaid"
      title="Mark payroll as paid?"
      :description="`Mark ${pendingPaid?.week_start} – ${pendingPaid?.week_end} (${money(pendingPaid?.total_amount ?? 0)}) as paid? This cannot be undone.`"
      confirm-label="Mark as paid"
      confirm-variant="default"
      loading-label="Saving…"
      :loading="!!markingPaid"
      @confirm="doMarkPaid"
      @cancel="pendingPaid = null"
    />
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { Plus, X, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import Pagination from "@/components/admin/Pagination.vue";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import { fetchPayrolls, generatePayroll, markPayrollPaid } from "@/api/payrolls";
import type { PayrollResponse } from "@/api/payrolls";
import { fetchUsers } from "@/api/users";
import type { UserResponse, PageMeta } from "@/api/users";
import { fetchDrivers } from "@/api/drivers";
import type { DriverResponse } from "@/api/drivers";
import { money, fmtDate } from "@/utils/format";

const ui = useUIStore();
const payrolls = ref<PayrollResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);

async function load(page = 1) {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchPayrolls(page, 20);
    payrolls.value = res.payrolls;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load payrolls.";
  } finally {
    loading.value = false;
  }
}

function changePage(page: number) { currentPage.value = page; load(page); }
onMounted(() => load(1));

// ── Detail sheet ──────────────────────────────────────────────
const selectedPayroll = ref<PayrollResponse | null>(null);
function openDetail(p: PayrollResponse) { selectedPayroll.value = p; }

// ── Generate ──────────────────────────────────────────────────
const gform = reactive({ weekStart: "", weekEnd: "", note: "" });
const generateOpen = ref(false);
const generateError = ref("");
const generating = ref(false);

const staffList = ref<UserResponse[]>([]);
const driverList = ref<DriverResponse[]>([]);
const staffLoading = ref(false);
const driversLoading = ref(false);
const selectedStaffUuids = ref<string[]>([]);
const selectedDriverUuids = ref<string[]>([]);

async function openGenerate() {
  gform.weekStart = "";
  gform.weekEnd = "";
  gform.note = "";
  generateError.value = "";
  selectedStaffUuids.value = [];
  selectedDriverUuids.value = [];
  generateOpen.value = true;
  staffLoading.value = true;
  driversLoading.value = true;
  try {
    const [usersRes, driversRes] = await Promise.all([
      fetchUsers(1, 100),
      fetchDrivers(100),
    ]);
    staffList.value = usersRes.users;
    driverList.value = driversRes.drivers;
  } catch { /* silent — lists stay empty */ } finally {
    staffLoading.value = false;
    driversLoading.value = false;
  }
}

async function doGenerate() {
  if (!gform.weekStart) { generateError.value = "Week start date is required."; return; }
  if (!gform.weekEnd) { generateError.value = "Week end date is required."; return; }
  generating.value = true;
  generateError.value = "";
  try {
    const created = await generatePayroll({
      week_start: gform.weekStart,
      week_end: gform.weekEnd,
      note: gform.note || undefined,
      staff_uuids: selectedStaffUuids.value.length ? selectedStaffUuids.value : undefined,
      driver_uuids: selectedDriverUuids.value.length ? selectedDriverUuids.value : undefined,
    });
    payrolls.value.unshift(created);
    generateOpen.value = false;
    ui.showToast("Payroll generated", "success");
  } catch (e: unknown) {
    generateError.value = e instanceof Error ? e.message : "Failed to generate payroll.";
  } finally {
    generating.value = false;
  }
}

// ── Mark as paid ──────────────────────────────────────────────
const pendingPaid = ref<PayrollResponse | null>(null);
const markingPaid = ref<string | null>(null);

function confirmMarkPaid(p: PayrollResponse) { pendingPaid.value = p; }

async function doMarkPaid() {
  if (!pendingPaid.value) return;
  markingPaid.value = pendingPaid.value.uuid;
  try {
    const updated = await markPayrollPaid(pendingPaid.value.uuid);
    const idx = payrolls.value.findIndex((p) => p.uuid === updated.uuid);
    if (idx !== -1) payrolls.value[idx] = updated;
    if (selectedPayroll.value?.uuid === updated.uuid) selectedPayroll.value = updated;
    pendingPaid.value = null;
    ui.showToast("Payroll marked as paid", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to update.", "danger");
  } finally {
    markingPaid.value = null;
  }
}
</script>
