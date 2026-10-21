<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ meta ? meta.total + " suppliers" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New supplier</Button>
      </div>

      <!-- Search + Status Tabs -->
      <div class="flex flex-col sm:flex-row gap-3 mb-4">
        <div class="relative max-w-xs w-full">
          <Search :size="15" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
          <Input v-model="query" class="pl-8" placeholder="Search suppliers…" @input="onSearch" />
        </div>
        <Tabs v-model="statusFilter" @update:model-value="onStatusChange">
          <TabsList>
            <TabsTrigger value="">All</TabsTrigger>
            <TabsTrigger value="ACTIVE">Active</TabsTrigger>
            <TabsTrigger value="INACTIVE">Inactive</TabsTrigger>
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
              <TableHead>Name</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Contact Person</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Joined</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 7" :key="'s' + n">
              <TableCell colspan="7"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="s in suppliers"
                :key="s.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="openDetail(s)"
              >
                <TableCell class="font-medium">{{ s.name }}</TableCell>
                <TableCell class="font-mono text-[12.5px]">{{ s.phone ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ s.email ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ s.contact_person ?? "—" }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="statusStyle(s.status)"
                  >{{ s.status }}</span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(s.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-destructive" @click="confirmRemove(s)">
                    <Trash2 :size="14" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="suppliers.length === 0 && !loadError">
                <TableCell colspan="7" class="text-center text-muted-foreground py-12 text-sm">No suppliers found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div v-if="meta && meta.total_pages > 1" class="flex justify-center mt-4">
        <Pagination :page="currentPage" :total-pages="meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Detail Sheet -->
    <Sheet :open="!!selected" @update:open="(v) => !v && (selected = null)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div v-if="selected" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background z-10">
            <span class="text-[15px] font-semibold">Supplier Details</span>
            <div class="flex items-center gap-2">
              <Button variant="outline" size="sm" @click="openEdit(selected)"><Pencil :size="13" /> Edit</Button>
              <Button variant="ghost" size="icon" class="h-8 w-8" @click="selected = null"><X :size="18" /></Button>
            </div>
          </div>
          <div class="p-5 flex flex-col gap-4">
            <div>
              <div class="text-[18px] font-semibold">{{ selected.name }}</div>
              <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold mt-1" :style="statusStyle(selected.status)">{{ selected.status }}</span>
            </div>
            <div class="grid grid-cols-1 gap-3 text-[13.5px]">
              <div class="flex gap-2">
                <span class="text-muted-foreground w-32 shrink-0">Phone</span>
                <span class="font-medium font-mono">{{ selected.phone ?? "—" }}</span>
              </div>
              <div class="flex gap-2">
                <span class="text-muted-foreground w-32 shrink-0">Email</span>
                <span class="font-medium">{{ selected.email ?? "—" }}</span>
              </div>
              <div class="flex gap-2">
                <span class="text-muted-foreground w-32 shrink-0">Address</span>
                <span class="font-medium">{{ selected.address ?? "—" }}</span>
              </div>
              <div class="flex gap-2">
                <span class="text-muted-foreground w-32 shrink-0">Contact Person</span>
                <span class="font-medium">{{ selected.contact_person ?? "—" }}</span>
              </div>
              <div class="flex gap-2">
                <span class="text-muted-foreground w-32 shrink-0">Joined</span>
                <span class="font-medium">{{ fmtDateShort(selected.created_at) }}</span>
              </div>
            </div>
            <div class="border-t pt-4">
              <RouterLink
                :to="`/admin/purchases?supplier=${selected.uuid}`"
                class="inline-flex items-center gap-2 text-[13px] text-primary font-medium hover:underline"
                @click="selected = null"
              >
                <ShoppingCart :size="14" /> View Purchase History
              </RouterLink>
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Create / Edit Sheet -->
    <Sheet :open="formOpen" @update:open="(v) => !v && (formOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background z-10">
            <span class="text-[15px] font-semibold">{{ editTarget ? "Edit Supplier" : "New Supplier" }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="formOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div class="flex flex-col gap-1.5">
              <Label>Name <span class="text-red-500">*</span></Label>
              <Input v-model="fname" :class="ferrors.name ? 'border-red-400' : ''" placeholder="Supplier name" />
              <p v-if="ferrors.name" class="text-[12px] text-red-500">{{ ferrors.name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Phone</Label>
              <Input v-model="fphone" placeholder="095123456" />
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Email</Label>
              <Input v-model="femail" placeholder="supplier@example.com" />
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Address</Label>
              <Input v-model="faddress" placeholder="123 Street, City" />
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Contact Person</Label>
              <Input v-model="fcontact" placeholder="Contact name" />
            </div>
            <div v-if="editTarget" class="flex flex-col gap-1.5">
              <Label>Status</Label>
              <select
                v-model="fstatus"
                class="flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
              >
                <option value="ACTIVE">Active</option>
                <option value="INACTIVE">Inactive</option>
              </select>
            </div>
            <div v-if="formError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ formError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="save">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Saving…" : editTarget ? "Save Changes" : "Create Supplier" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <ConfirmDialog
      :open="!!pendingDelete"
      title="Delete supplier?"
      :description="`'${pendingDelete?.name ?? 'this supplier'}' will be permanently removed.`"
      confirm-label="Delete"
      loading-label="Deleting…"
      :loading="deleting"
      @confirm="doDelete"
      @cancel="pendingDelete = null"
    />
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { Plus, X, Trash2, AlertTriangle, Loader2, Search, Pencil, ShoppingCart } from "@lucide/vue";
import { RouterLink } from "vue-router";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import Pagination from "@/components/admin/Pagination.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import {
  fetchSuppliers,
  createSupplier,
  updateSupplier,
  deleteSupplier,
} from "@/api/suppliers";
import type { SupplierResponse, SupplierStatus } from "@/api/suppliers";
import type { PageMeta } from "@/api/users";
import { fmtDateShort } from "@/utils/format";

const ui = useUIStore();

const suppliers = ref<SupplierResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);
const query = ref("");
const statusFilter = ref<SupplierStatus | "">("");

function statusStyle(status: SupplierStatus) {
  if (status === "ACTIVE") return "background:#dcfce7;color:#15803d";
  return "background:hsl(var(--muted));color:hsl(var(--muted-foreground))";
}

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchSuppliers({
      page: currentPage.value,
      search: query.value || undefined,
      status: statusFilter.value || undefined,
    });
    suppliers.value = res.suppliers;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load suppliers.";
  } finally {
    loading.value = false;
  }
}

onMounted(load);

let searchTimer: ReturnType<typeof setTimeout> | null = null;
function onSearch() {
  if (searchTimer) clearTimeout(searchTimer);
  searchTimer = setTimeout(() => {
    currentPage.value = 1;
    load();
  }, 350);
}

function onStatusChange() {
  currentPage.value = 1;
  load();
}

function changePage(p: number) {
  currentPage.value = p;
  load();
}

// ── Detail sheet ──────────────────────────────────────────────
const selected = ref<SupplierResponse | null>(null);

function openDetail(s: SupplierResponse) {
  selected.value = s;
}

// ── Create / Edit form ────────────────────────────────────────
const Schema = z.object({
  name: z.string().min(1, "Name is required"),
  phone: z.string().optional(),
  email: z.string().optional(),
  address: z.string().optional(),
  contact_person: z.string().optional(),
});

const { defineField, handleSubmit, errors: ferrors, resetForm, setValues } = useForm({
  validationSchema: toTypedSchema(Schema),
  initialValues: { name: "", phone: "", email: "", address: "", contact_person: "" },
});

const [fname] = defineField("name");
const [fphone] = defineField("phone");
const [femail] = defineField("email");
const [faddress] = defineField("address");
const [fcontact] = defineField("contact_person");

const fstatus = ref<SupplierStatus>("ACTIVE");
const formOpen = ref(false);
const formError = ref("");
const saving = ref(false);
const editTarget = ref<SupplierResponse | null>(null);

function openCreate() {
  editTarget.value = null;
  resetForm();
  fstatus.value = "ACTIVE";
  formError.value = "";
  formOpen.value = true;
}

function openEdit(s: SupplierResponse) {
  selected.value = null;
  editTarget.value = s;
  setValues({
    name: s.name,
    phone: s.phone ?? "",
    email: s.email ?? "",
    address: s.address ?? "",
    contact_person: s.contact_person ?? "",
  });
  fstatus.value = s.status;
  formError.value = "";
  formOpen.value = true;
}

const save = handleSubmit(async (values) => {
  saving.value = true;
  formError.value = "";
  try {
    const payload = {
      name: values.name,
      phone: values.phone || undefined,
      email: values.email || undefined,
      address: values.address || undefined,
      contact_person: values.contact_person || undefined,
    };
    if (editTarget.value) {
      await updateSupplier(editTarget.value.uuid, { ...payload, status: fstatus.value });
      ui.showToast("Supplier updated", "success");
    } else {
      await createSupplier(payload);
      ui.showToast("Supplier created", "success");
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
const pendingDelete = ref<SupplierResponse | null>(null);
const deleting = ref(false);

function confirmRemove(s: SupplierResponse) {
  pendingDelete.value = s;
}

async function doDelete() {
  if (!pendingDelete.value) return;
  deleting.value = true;
  try {
    await deleteSupplier(pendingDelete.value.uuid);
    suppliers.value = suppliers.value.filter((s) => s.uuid !== pendingDelete.value!.uuid);
    pendingDelete.value = null;
    ui.showToast("Supplier deleted", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to delete.", "danger");
  } finally {
    deleting.value = false;
  }
}
</script>
