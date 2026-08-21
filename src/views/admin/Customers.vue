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

    <!-- Detail / edit sheet -->
    <Sheet :open="!!selected" @update:open="(v) => !v && (selected = null)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div v-if="selected" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">Customer detail</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="selected = null"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-5">
            <div class="flex items-center gap-3.5">
              <UserAvatar :name="selected.name" :size="48" />
              <div>
                <div class="text-[17px] font-semibold">{{ selected.name }}</div>
                <div class="font-mono text-[13px] text-muted-foreground">{{ selected.phone }}</div>
              </div>
            </div>
            <div class="flex flex-col gap-0 rounded-lg border border-border overflow-hidden">
              <div v-for="row in detailRows" :key="row.label" class="flex items-center px-4 py-3 border-b border-border/50 last:border-0">
                <span class="w-32 text-[12.5px] text-muted-foreground shrink-0">{{ row.label }}</span>
                <span class="text-[13px]">{{ row.value }}</span>
              </div>
            </div>
            <Button variant="outline" size="sm" class="self-start" @click="openEdit(selected)">
              <Pencil :size="13" /> Edit
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

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
              <Label>Name <span class="text-red-500">*</span></Label>
              <Input v-model="fname" :error="ferrors.name" placeholder="John Doe" />
              <p v-if="ferrors.name" class="text-[12px] text-red-500">{{ ferrors.name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Phone <span class="text-red-500">*</span></Label>
              <Input v-model="fphone" :error="ferrors.phone" placeholder="012345678" />
              <p v-if="ferrors.phone" class="text-[12px] text-red-500">{{ ferrors.phone }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Facebook name</Label>
              <Input v-model="ffacebook" placeholder="john.doe" />
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
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import {
  fetchCustomers, searchCustomers, createCustomer, updateCustomer, deleteCustomer,
} from "@/api/customers";
import type { CustomerResponse } from "@/api/customers";
import type { PageMeta } from "@/api/users";
import { fmtDate } from "@/utils/format";

const ui = useUIStore();

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

// ── Detail sheet ──────────────────────────────────────────────
const selected = ref<CustomerResponse | null>(null);

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

function openDetail(c: CustomerResponse) { selected.value = c; }

// ── Create / edit form ────────────────────────────────────────
const Schema = z.object({
  name: z.string().min(1, "Name is required"),
  phone: z.string().min(1, "Phone is required"),
  facebook_name: z.string().optional(),
  province: z.string().optional(),
  address: z.string().optional(),
});

const { defineField, handleSubmit, errors: ferrors, resetForm, setValues } = useForm({
  validationSchema: toTypedSchema(Schema),
  initialValues: { name: "", phone: "", facebook_name: "", province: "", address: "" },
});

const [fname] = defineField("name");
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
  setValues({ name: c.name, phone: c.phone, facebook_name: c.facebook_name ?? "", province: c.province ?? "", address: c.address ?? "" });
  formError.value = "";
  formOpen.value = true;
}

const save = handleSubmit(async (values) => {
  saving.value = true;
  formError.value = "";
  try {
    const payload = {
      name: values.name,
      phone: values.phone,
      facebook_name: values.facebook_name || undefined,
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
