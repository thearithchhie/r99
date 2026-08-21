<template>
  <AdminLayout>
    <DataNotFound
      v-if="error && !loading"
      :message="error"
      :back-to="ADMIN_ROUTES.models.list"
      back-label="Back to models"
    />

    <div v-else class="p-6 max-w-2xl mx-auto">
      <button
        class="flex items-center gap-1.5 text-[13px] text-muted-foreground hover:text-foreground transition-colors mb-4"
        @click="router.back()"
      >
        <ArrowLeft :size="14" /> Back to models
      </button>

      <!-- Loading skeleton -->
      <template v-if="loading">
        <Card class="mb-5">
          <div class="flex items-center justify-between px-8 py-5 border-b border-border/40">
            <div class="h-4 w-24 rounded bg-muted animate-pulse" />
            <div class="h-8 w-24 rounded bg-muted animate-pulse" />
          </div>
          <div v-for="n in 2" :key="n" class="flex items-center px-8 py-4 gap-8 border-b border-border/40 last:border-0">
            <div class="h-4 w-24 rounded bg-muted animate-pulse shrink-0" />
            <div class="h-4 rounded bg-muted animate-pulse flex-1" />
          </div>
        </Card>
      </template>

      <template v-else-if="model">
        <!-- Info card -->
        <Card class="mb-5">
          <div class="flex items-center justify-between px-8 py-5 border-b border-border/40">
            <p class="text-[14px] font-semibold text-muted-foreground">Model info</p>
            <Button size="sm" @click="openVariantDrawer">
              <Plus :size="13" /> Add variant
            </Button>
          </div>
          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Name</span>
            <span class="text-[13.5px] font-medium">{{ model.name }}</span>
          </div>
          <div class="flex items-center px-8 py-4">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Description</span>
            <span class="text-[13.5px]">{{ model.description || "—" }}</span>
          </div>
        </Card>

        <!-- Variants -->
        <div class="flex items-center justify-between mb-3">
          <h2 class="text-[14px] font-semibold">Variants <span class="text-muted-foreground font-normal text-[13px]">{{ model.variants.length }}</span></h2>
        </div>

        <Card>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Size</TableHead>
                <TableHead>Color</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="v in model.variants" :key="v.id">
                <TableCell class="font-medium">{{ v.size ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground">{{ v.color ?? "—" }}</TableCell>
              </TableRow>
              <TableRow v-if="model.variants.length === 0">
                <TableCell colspan="2" class="text-center text-muted-foreground py-10 text-sm">
                  No variants yet. Click "Add variant" to create one.
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </Card>
      </template>
    </div>

    <!-- Add variant drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div>
              <span class="text-[15px] font-semibold">Add variant</span>
              <p v-if="model" class="text-[12.5px] text-muted-foreground mt-0.5">{{ model.name }}</p>
            </div>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false">
              <X :size="18" />
            </Button>
          </div>
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5">
              <Label>Size <span class="text-red-500">*</span></Label>
              <Input v-model="variantSize" :error="errors.size" placeholder="128GB" />
              <p v-if="errors.size" class="text-[12px] text-red-500">{{ errors.size }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Color <span class="text-red-500">*</span></Label>
              <Input v-model="variantColor" :error="errors.color" placeholder="Black" />
              <p v-if="errors.color" class="text-[12px] text-red-500">{{ errors.color }}</p>
            </div>
            <div
              v-if="drawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ drawerError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="save">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Adding…" : "Add variant" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { ArrowLeft, Plus, X, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import DataNotFound from "@/components/admin/DataNotFound.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell,
} from "@/components/ui/table";
import { useUIStore } from "@/stores/ui";
import { fetchModel, createModelVariant } from "@/api/models";
import type { ModelDetailResponse } from "@/api/models";
import { ADMIN_ROUTES } from "@/router/admin-routes";

const VariantSchema = z.object({
  size: z.string().min(1, "Size is required"),
  color: z.string().min(1, "Color is required"),
})

const route = useRoute();
const router = useRouter();
const ui = useUIStore();

const model = ref<ModelDetailResponse | null>(null);
const loading = ref(false);
const error = ref("");
const drawerOpen = ref(false);
const saving = ref(false);
const drawerError = ref("");

const { defineField, handleSubmit, errors, resetForm } = useForm({
  validationSchema: toTypedSchema(VariantSchema),
  initialValues: { size: "", color: "" },
})

const [variantSize] = defineField("size")
const [variantColor] = defineField("color")

async function load() {
  loading.value = true;
  error.value = "";
  try {
    model.value = await fetchModel(route.params.uuid as string);
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : "Model not found.";
  } finally {
    loading.value = false;
  }
}

onMounted(load);

function openVariantDrawer() {
  resetForm();
  drawerError.value = "";
  drawerOpen.value = true;
}

const save = handleSubmit(async (values) => {
  if (!model.value) return;
  saving.value = true;
  drawerError.value = "";
  try {
    const newVariant = await createModelVariant(model.value.id, {
      size: values.size,
      color: values.color,
    });
    model.value.variants.push(newVariant);
    drawerOpen.value = false;
    ui.showToast("Variant added", "success");
  } catch (e: unknown) {
    drawerError.value = e instanceof Error ? e.message : "Failed to add variant.";
  } finally {
    saving.value = false;
  }
});
</script>
