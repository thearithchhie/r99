<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ drivers.length > 0 ? drivers.length + " drivers" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> Add driver</Button>
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
              <TableHead>Note</TableHead>
              <TableHead>Joined</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 5" :key="'s'+n">
              <TableCell colspan="5"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow v-for="d in drivers" :key="d.uuid">
                <TableCell>
                  <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-full bg-primary text-primary-foreground font-bold text-[13px] grid place-items-center shrink-0">
                      {{ (d.name ?? "?").charAt(0).toUpperCase() }}
                    </div>
                    <span class="font-medium">{{ d.name }}</span>
                  </div>
                </TableCell>
                <TableCell class="font-mono text-[12.5px]">{{ d.phone }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ d.note ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(d.created_at) }}</TableCell>
                <TableCell class="text-right">
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-destructive" @click="confirmRemove(d)">
                    <Trash2 :size="14" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="drivers.length === 0 && !loadError">
                <TableCell colspan="5" class="text-center text-muted-foreground py-12 text-sm">No drivers yet.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>
    </div>

    <!-- Create drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">Add driver</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div class="flex flex-col gap-1.5">
              <Label>Name <span class="text-red-500">*</span></Label>
              <Input v-model="dname" :error="derrors.name" placeholder="Dara" />
              <p v-if="derrors.name" class="text-[12px] text-red-500">{{ derrors.name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Phone <span class="text-red-500">*</span></Label>
              <Input v-model="dphone" :error="derrors.phone" placeholder="095123456" />
              <p v-if="derrors.phone" class="text-[12px] text-red-500">{{ derrors.phone }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Note</Label>
              <Input v-model="dnote" placeholder="R-Express driver" />
            </div>
            <div v-if="drawerError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600">
              <AlertTriangle :size="14" class="shrink-0" />{{ drawerError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="save">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Adding…" : "Add driver" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <ConfirmDialog
      :open="!!pendingDelete"
      title="Remove driver?"
      :description="`'${pendingDelete?.name ?? 'this driver'}' will be permanently removed. This cannot be undone.`"
      confirm-label="Remove"
      loading-label="Removing…"
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
import { Plus, X, Trash2, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import { fetchDrivers, createDriver, deleteDriver } from "@/api/drivers";
import type { DriverResponse } from "@/api/drivers";
import type { PageMeta } from "@/api/users";
import { fmtDate } from "@/utils/format";

const ui = useUIStore();
const drivers = ref<DriverResponse[]>([]);
const loading = ref(false);
const loadError = ref("");

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchDrivers();
    drivers.value = res.drivers;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load drivers.";
  } finally {
    loading.value = false;
  }
}

onMounted(load);

// ── Create form ───────────────────────────────────────────────
const Schema = z.object({
  name: z.string().min(1, "Name is required"),
  phone: z.string().min(1, "Phone is required"),
  note: z.string().optional(),
});

const { defineField, handleSubmit, errors: derrors, resetForm } = useForm({
  validationSchema: toTypedSchema(Schema),
  initialValues: { name: "", phone: "", note: "" },
});

const [dname] = defineField("name");
const [dphone] = defineField("phone");
const [dnote] = defineField("note");

const drawerOpen = ref(false);
const drawerError = ref("");
const saving = ref(false);

function openCreate() {
  resetForm();
  drawerError.value = "";
  drawerOpen.value = true;
}

const save = handleSubmit(async (values) => {
  saving.value = true;
  drawerError.value = "";
  try {
    await createDriver({ name: values.name, phone: values.phone, note: values.note || undefined });
    drawerOpen.value = false;
    ui.showToast("Driver added", "success");
    await load();
  } catch (e: unknown) {
    drawerError.value = e instanceof Error ? e.message : "Failed to add driver.";
  } finally {
    saving.value = false;
  }
});

// ── Delete ────────────────────────────────────────────────────
const pendingDelete = ref<DriverResponse | null>(null);
const deleting = ref(false);

function confirmRemove(d: DriverResponse) { pendingDelete.value = d; }

async function doDelete() {
  if (!pendingDelete.value) return;
  deleting.value = true;
  try {
    await deleteDriver(pendingDelete.value.uuid);
    drivers.value = drivers.value.filter((d) => d.uuid !== pendingDelete.value!.uuid);
    pendingDelete.value = null;
    ui.showToast("Driver removed", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to remove.", "danger");
  } finally {
    deleting.value = false;
  }
}
</script>
