<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ total !== null ? total + " models" : "" }}
        </p>
        <Button size="sm" @click="openNew"><Plus :size="14" /> New model</Button>
      </div>

      <div
        v-if="loadError"
        class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4"
      >
        <AlertTriangle :size="14" class="shrink-0" />{{ loadError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Description</TableHead>
              <TableHead>Created at</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="loading" v-for="n in 6" :key="'skel-' + n">
              <TableCell colspan="4">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <template v-if="!loading">
              <TableRow
                v-for="m in models"
                :key="m.id"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="router.push(ADMIN_ROUTES.models.detail(m.uuid))"
              >
                <TableCell class="font-medium">{{ m.name }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ m.description ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(m.created_at ?? '') }}</TableCell>
                <TableCell class="text-right" @click.stop="openVariantDrawer(m)">
                  <Button
                    variant="outline"
                    size="sm"
                    class="h-7 text-[12px]"
                  >
                    <Plus :size="12" /> Add variant
                  </Button>
                </TableCell>
              </TableRow>

              <TableRow v-if="models.length === 0 && !loadError">
                <TableCell colspan="4" class="text-center text-muted-foreground py-12 text-sm">
                  No models found.
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>
    </div>

    <!-- Create model drawer -->
    <Sheet :open="modelDrawerOpen" @update:open="(v) => !v && (modelDrawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">New model</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="modelDrawerOpen = false">
              <X :size="18" />
            </Button>
          </div>
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5">
              <Label>Name <span class="text-red-500">*</span></Label>
              <Input v-model="modelName" :error="modelErrors.name" placeholder="iPhone 15" />
              <p v-if="modelErrors.name" class="text-[12px] text-red-500">{{ modelErrors.name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Description</Label>
              <Input v-model="modelDescription" placeholder="Apple iPhone 15 series" />
            </div>
            <div
              v-if="modelDrawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ modelDrawerError }}
            </div>
            <Button class="w-full mt-1" :disabled="modelSaving" @click="saveModel">
              <Loader2 v-if="modelSaving" :size="14" class="animate-spin" />
              {{ modelSaving ? "Creating…" : "Create model" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Add variant drawer -->
    <Sheet :open="variantDrawerOpen" @update:open="(v) => !v && (variantDrawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div>
              <span class="text-[15px] font-semibold">Add variant</span>
              <p v-if="activeModel" class="text-[12.5px] text-muted-foreground mt-0.5">{{ activeModel.name }}</p>
            </div>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="variantDrawerOpen = false">
              <X :size="18" />
            </Button>
          </div>
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5">
              <Label>Size <span class="text-red-500">*</span></Label>
              <Input v-model="variantSize" :error="variantErrors.size" placeholder="128GB" />
              <p v-if="variantErrors.size" class="text-[12px] text-red-500">{{ variantErrors.size }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Color <span class="text-red-500">*</span></Label>
              <Input v-model="variantColor" :error="variantErrors.color" placeholder="Black" />
              <p v-if="variantErrors.color" class="text-[12px] text-red-500">{{ variantErrors.color }}</p>
            </div>
            <div
              v-if="variantDrawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ variantDrawerError }}
            </div>
            <Button class="w-full mt-1" :disabled="variantSaving" @click="saveVariant">
              <Loader2 v-if="variantSaving" :size="14" class="animate-spin" />
              {{ variantSaving ? "Adding…" : "Add variant" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { ADMIN_ROUTES } from "@/router/admin-routes";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { Plus, X, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell,
} from "@/components/ui/table";
import { fmtDate } from "@/utils/format";
import { useUIStore } from "@/stores/ui";
import { fetchModels, createModel, createModelVariant } from "@/api/models";
import type { ModelResponse } from "@/api/models";

// ── Model form ────────────────────────────────────────────────
const ModelSchema = z.object({
  name: z.string().min(1, "Name is required"),
  description: z.string().optional(),
})

const {
  defineField: defineModelField,
  handleSubmit: handleModelSubmit,
  errors: modelErrors,
  resetForm: resetModelForm,
} = useForm({ validationSchema: toTypedSchema(ModelSchema), initialValues: { name: "", description: "" } })

const [modelName] = defineModelField("name")
const [modelDescription] = defineModelField("description")

// ── Variant form ──────────────────────────────────────────────
const VariantSchema = z.object({
  size: z.string().min(1, "Size is required"),
  color: z.string().min(1, "Color is required"),
})

const {
  defineField: defineVariantField,
  handleSubmit: handleVariantSubmit,
  errors: variantErrors,
  resetForm: resetVariantForm,
} = useForm({ validationSchema: toTypedSchema(VariantSchema), initialValues: { size: "", color: "" } })

const [variantSize] = defineVariantField("size")
const [variantColor] = defineVariantField("color")

// ── Page state ────────────────────────────────────────────────
const router = useRouter();
const ui = useUIStore();
const models = ref<ModelResponse[]>([]);
const total = ref<number | null>(null);
const loading = ref(false);
const loadError = ref("");

const modelDrawerOpen = ref(false);
const modelSaving = ref(false);
const modelDrawerError = ref("");

const variantDrawerOpen = ref(false);
const variantSaving = ref(false);
const variantDrawerError = ref("");
const activeModel = ref<ModelResponse | null>(null);

async function load() {
  loading.value = true;
  loadError.value = "";
  try {
    models.value = await fetchModels();
    total.value = models.value.length;
  } catch (e: unknown) {
    loadError.value = e instanceof Error ? e.message : "Failed to load models.";
  } finally {
    loading.value = false;
  }
}

onMounted(load);

function openNew() {
  resetModelForm();
  modelDrawerError.value = "";
  modelDrawerOpen.value = true;
}

function openVariantDrawer(model: ModelResponse) {
  activeModel.value = model;
  resetVariantForm();
  variantDrawerError.value = "";
  variantDrawerOpen.value = true;
}

const saveModel = handleModelSubmit(async (values) => {
  modelSaving.value = true;
  modelDrawerError.value = "";
  try {
    await createModel({ name: values.name, description: values.description || undefined });
    modelDrawerOpen.value = false;
    ui.showToast("Model created successfully", "success");
    load();
  } catch (e: unknown) {
    modelDrawerError.value = e instanceof Error ? e.message : "Failed to create model.";
  } finally {
    modelSaving.value = false;
  }
});

const saveVariant = handleVariantSubmit(async (values) => {
  if (!activeModel.value) return;
  variantSaving.value = true;
  variantDrawerError.value = "";
  try {
    await createModelVariant(activeModel.value.id, { size: values.size, color: values.color });
    variantDrawerOpen.value = false;
    ui.showToast(`Variant added to ${activeModel.value.name}`, "success");
  } catch (e: unknown) {
    variantDrawerError.value = e instanceof Error ? e.message : "Failed to add variant.";
  } finally {
    variantSaving.value = false;
  }
});
</script>
