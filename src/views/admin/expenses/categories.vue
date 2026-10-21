<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ meta ? meta.total + " categories" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New Category</Button>
      </div>

      <!-- Search -->
      <div class="relative max-w-xs mb-4">
        <Search :size="15" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input v-model="query" class="pl-8" placeholder="Search categories…" @input="onSearch" />
      </div>

      <div v-if="loadError" class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4">
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Description</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Created</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 6" :key="'s' + n">
              <TableCell colspan="5"><div class="h-4 rounded bg-muted animate-pulse w-full" /></TableCell>
            </TableRow>
            <template v-if="!loading">
              <TableRow
                v-for="cat in categories"
                :key="cat.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="openEdit(cat)"
              >
                <TableCell class="font-medium">{{ cat.name }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ cat.description ?? "—" }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="catStatusStyle(cat.status)"
                  >{{ cat.status }}</span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(cat.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-destructive" @click="confirmRemove(cat)">
                    <Trash2 :size="14" />
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="categories.length === 0 && !loadError">
                <TableCell colspan="5" class="text-center text-muted-foreground py-12 text-sm">No categories found.</TableCell>
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
            <span class="text-[15px] font-semibold">{{ editTarget ? "Edit Category" : "New Category" }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="formOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div class="flex flex-col gap-1.5">
              <Label>Name <span class="text-red-500">*</span></Label>
              <Input v-model="fname" :class="ferrors.name ? 'border-red-400' : ''" placeholder="e.g. Office Supplies" maxlength="100" />
              <p v-if="ferrors.name" class="text-[12px] text-red-500">{{ ferrors.name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Description</Label>
              <Input v-model="fdesc" placeholder="Optional description" />
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
              {{ saving ? "Saving…" : editTarget ? "Save Changes" : "Create Category" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <ConfirmDialog
      :open="!!pendingDelete"
      title="Delete category?"
      :description="`'${pendingDelete?.name ?? 'this category'}' will be permanently removed.`"
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
import { Plus, X, Trash2, AlertTriangle, Loader2, Search } from "@lucide/vue";
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
  fetchExpenseCategories,
  createExpenseCategory,
  updateExpenseCategory,
  deleteExpenseCategory,
} from "@/api/expenses";
import type { ExpenseCategoryResponse, ExpenseCategoryStatus } from "@/api/expenses";
import type { PageMeta } from "@/api/users";
import { fmtDateShort } from "@/utils/format";

const ui = useUIStore();

const categories = ref<ExpenseCategoryResponse[]>([]);
const meta = ref<PageMeta | null>(null);
const loading = ref(false);
const loadError = ref("");
const currentPage = ref(1);
const query = ref("");

function catStatusStyle(status: ExpenseCategoryStatus) {
  if (status === "ACTIVE") return "background:#dcfce7;color:#15803d";
  return "background:hsl(var(--muted));color:hsl(var(--muted-foreground))";
}

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    const res = await fetchExpenseCategories({
      page: currentPage.value,
      search: query.value || undefined,
    });
    categories.value = res.expense_categories;
    meta.value = res.meta;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load categories.";
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

function changePage(p: number) {
  currentPage.value = p;
  load();
}

// ── Form ──────────────────────────────────────────────────────
const Schema = z.object({
  name: z.string().min(1, "Name is required").max(100, "Name must be 100 chars or less"),
  description: z.string().optional(),
});

const { defineField, handleSubmit, errors: ferrors, resetForm, setValues } = useForm({
  validationSchema: toTypedSchema(Schema),
  initialValues: { name: "", description: "" },
});

const [fname] = defineField("name");
const [fdesc] = defineField("description");
const fstatus = ref<ExpenseCategoryStatus>("ACTIVE");

const formOpen = ref(false);
const formError = ref("");
const saving = ref(false);
const editTarget = ref<ExpenseCategoryResponse | null>(null);

function openCreate() {
  editTarget.value = null;
  resetForm();
  fstatus.value = "ACTIVE";
  formError.value = "";
  formOpen.value = true;
}

function openEdit(cat: ExpenseCategoryResponse) {
  editTarget.value = cat;
  setValues({ name: cat.name, description: cat.description ?? "" });
  fstatus.value = cat.status;
  formError.value = "";
  formOpen.value = true;
}

const save = handleSubmit(async (values) => {
  saving.value = true;
  formError.value = "";
  try {
    if (editTarget.value) {
      await updateExpenseCategory(editTarget.value.uuid, {
        name: values.name,
        description: values.description || undefined,
        status: fstatus.value,
      });
      ui.showToast("Category updated", "success");
    } else {
      await createExpenseCategory({
        name: values.name,
        description: values.description || undefined,
      });
      ui.showToast("Category created", "success");
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
const pendingDelete = ref<ExpenseCategoryResponse | null>(null);
const deleting = ref(false);

function confirmRemove(cat: ExpenseCategoryResponse) {
  pendingDelete.value = cat;
}

async function doDelete() {
  if (!pendingDelete.value) return;
  deleting.value = true;
  try {
    await deleteExpenseCategory(pendingDelete.value.uuid);
    categories.value = categories.value.filter((c) => c.uuid !== pendingDelete.value!.uuid);
    pendingDelete.value = null;
    ui.showToast("Category deleted", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to delete.", "danger");
  } finally {
    deleting.value = false;
  }
}
</script>
