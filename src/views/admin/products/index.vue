<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ store.meta ? store.meta.total + " products" : "" }}
        </p>
        <Button size="sm" @click="openNew"
          ><Plus :size="14" /> New product</Button
        >
      </div>

      <div
        v-if="store.error"
        class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4"
      >
        <AlertTriangle :size="14" class="shrink-0" />{{ store.error }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Product</TableHead>
              <TableHead>Category / Line</TableHead>
              <TableHead class="text-right">Price</TableHead>
              <TableHead>Stock</TableHead>
              <TableHead>Status</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="store.loading" v-for="n in 8" :key="'skel-' + n">
              <TableCell colspan="6">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <template v-if="!store.loading">
              <TableRow
                v-for="p in store.products"
                :key="p.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="router.push(ADMIN_ROUTES.products.detail(p.uuid))"
              >
                <TableCell>
                  <div class="flex items-center gap-2.5">
                    <PlaceholderThumb :tone="p.tone" :size="36" />
                    <div>
                      <div class="font-medium">{{ p.name }}</div>
                      <div
                        class="text-muted-foreground font-mono text-[11.5px]"
                      >
                        {{ p.sku ?? p.code }}
                      </div>
                    </div>
                  </div>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px]">
                  {{ p.category_name ?? "—" }}
                  <span v-if="p.line_name"> · {{ p.line_name }}</span>
                </TableCell>
                <TableCell class="text-right font-medium">{{
                  money(p.price)
                }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="stockStyle(p.current_stock)"
                  >
                    {{ p.current_stock }} units
                  </span>
                </TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="statusStyle(p.status)"
                  >
                    <span class="status-dot" />{{ statusLabel(p.status) }}
                  </span>
                </TableCell>
                <TableCell class="text-right" @click.stop>
                  <Button
                    variant="ghost"
                    size="icon"
                    class="h-8 w-8 text-muted-foreground hover:text-foreground"
                    title="Upload images"
                    @click="openUploadDrawer(p)"
                  >
                    <ImagePlus :size="15" />
                  </Button>
                </TableCell>
              </TableRow>

              <TableRow v-if="store.products.length === 0 && !store.error">
                <TableCell
                  colspan="6"
                  class="text-center text-muted-foreground py-12 text-sm"
                >
                  No products found.
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div
        v-if="store.meta && store.meta.total_pages > 1"
        class="flex flex-col items-center gap-2 mt-4"
      >
        <Pagination
          :page="currentPage"
          :total-pages="store.meta.total_pages"
          @change="changePage"
        />
      </div>
    </div>

    <!-- Create drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div
            class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background"
          >
            <span class="text-[15px] font-semibold">New product</span>
            <Button
              variant="ghost"
              size="icon"
              class="h-8 w-8"
              @click="drawerOpen = false"
            >
              <X :size="18" />
            </Button>
          </div>

          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <!-- Step indicators -->
            <div class="flex items-center gap-2 mb-1">
              <div
                v-for="(label, i) in ['Model', 'Variant', 'Details']"
                :key="i"
                class="flex items-center gap-1.5"
              >
                <div
                  class="w-5 h-5 rounded-full flex items-center justify-center text-[11px] font-semibold shrink-0 transition-colors"
                  :class="
                    stepDone(i)
                      ? 'bg-primary text-primary-foreground'
                      : currentStep === i
                        ? 'bg-primary/15 text-primary border border-primary/30'
                        : 'bg-muted text-muted-foreground'
                  "
                >
                  <Check v-if="stepDone(i)" :size="10" />
                  <span v-else>{{ i + 1 }}</span>
                </div>
                <span
                  class="text-[12px]"
                  :class="
                    currentStep === i
                      ? 'text-foreground font-medium'
                      : 'text-muted-foreground'
                  "
                  >{{ label }}</span
                >
                <ChevronRight
                  v-if="i < 2"
                  :size="12"
                  class="text-muted-foreground/50"
                />
              </div>
            </div>

            <!-- Details -->
            <div class="flex flex-col gap-1.5">
              <Label>Product name <span class="text-red-500">*</span></Label>
              <Input
                v-model="name"
                :error="errors.name"
                placeholder="iPhone 15 128GB Black"
              />
              <p v-if="errors.name" class="text-[12px] text-red-500">
                {{ errors.name }}
              </p>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Code</Label>
                <Input v-model="code" placeholder="P001" />
              </div>
              <div class="flex flex-col gap-1.5">
                <Label>Initial stock</Label>
                <Input
                  v-model="initial_stock"
                  type="number"
                  min="0"
                  placeholder="0"
                />
              </div>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Price ($) <span class="text-red-500">*</span></Label>
                <Input
                  v-model="price"
                  type="number"
                  min="0"
                  step="0.01"
                  :error="errors.price"
                />
                <p v-if="errors.price" class="text-[12px] text-red-500">
                  {{ errors.price }}
                </p>
              </div>
              <div class="flex flex-col gap-1.5">
                <Label>Cost ($)</Label>
                <Input v-model="cost" type="number" min="0" step="0.01" />
              </div>
            </div>

            <div class="border-t border-border/50 pt-1" />

            <!-- Step 1 — Model -->
            <div class="flex flex-col gap-1.5">
              <Label>Model <span class="text-red-500">*</span></Label>
              <CustomDropdown
                v-model="selectedModelId"
                :load-fn="modelsLoadFn"
                placeholder="Select model…"
                @change="onModelChange"
              />
            </div>

            <!-- Step 2 — Variant (enabled after model picked) -->
            <div class="flex flex-col gap-1.5">
              <Label>
                Variant <span class="text-red-500">*</span>
                <span
                  v-if="!selectedModelId"
                  class="ml-1 text-muted-foreground font-normal text-[12px]"
                  >— pick a model first</span
                >
              </Label>
              <CustomDropdown
                :key="selectedModelId || '__none__'"
                v-model="selectedVariantId"
                :load-fn="variantsLoadFn"
                :disabled="!selectedModelId"
                placeholder="Select variant…"
                @change="onVariantChange"
              />
              <p v-if="variantError" class="text-[12px] text-red-500">
                {{ variantError }}
              </p>
            </div>

            <div
              v-if="drawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ drawerError }}
            </div>

            <Button class="w-full mt-1" :disabled="saving" @click="saveProduct">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Creating…" : "Create product" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Upload images drawer -->
    <Sheet
      :open="uploadDrawerOpen"
      @update:open="(v) => !v && closeUploadDrawer()"
    >
      <SheetContent class="overflow-y-auto p-0 w-[480px] sm:max-w-[480px]">
        <div class="flex flex-col h-full">
          <div
            class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background"
          >
            <div>
              <span class="text-[15px] font-semibold">Upload images</span>
              <p
                v-if="uploadTarget"
                class="text-[12.5px] text-muted-foreground mt-0.5"
              >
                {{ uploadTarget.name }}
              </p>
            </div>
            <Button
              variant="ghost"
              size="icon"
              class="h-8 w-8"
              @click="closeUploadDrawer"
            >
              <X :size="18" />
            </Button>
          </div>

          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <!-- Drop zone -->
            <label
              class="flex flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed border-border bg-muted/30 px-6 py-10 text-center cursor-pointer transition-colors hover:bg-muted/50 hover:border-muted-foreground/40"
              :class="uploading ? 'pointer-events-none opacity-50' : ''"
            >
              <ImagePlus :size="28" class="text-muted-foreground" />
              <span class="text-[13.5px] font-medium"
                >Click to select images</span
              >
              <span class="text-[12px] text-muted-foreground"
                >JPG, PNG, WEBP — multiple allowed</span
              >
              <input
                ref="fileInputRef"
                type="file"
                accept="image/*"
                multiple
                class="hidden"
                @change="onFilesChange"
              />
            </label>

            <!-- Selected file previews -->
            <div v-if="selectedFiles.length" class="grid grid-cols-3 gap-2">
              <div
                v-for="(file, i) in selectedFiles"
                :key="i"
                class="relative group rounded-lg overflow-hidden border border-border aspect-square bg-muted"
              >
                <img :src="previews[i]" class="w-full h-full object-cover" />
                <button
                  class="absolute inset-0 flex items-center justify-center bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity"
                  @click="removeFile(i)"
                >
                  <X :size="18" class="text-white" />
                </button>
                <span
                  class="absolute bottom-0 left-0 right-0 bg-black/50 text-white text-[10px] px-1.5 py-0.5 truncate"
                >
                  {{ file.name }}
                </span>
              </div>
            </div>

            <div
              v-if="uploadError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ uploadError }}
            </div>

            <Button
              class="w-full mt-auto"
              :disabled="uploading || selectedFiles.length === 0"
              @click="uploadImages"
            >
              <Loader2 v-if="uploading" :size="14" class="animate-spin" />
              {{
                uploading
                  ? "Uploading…"
                  : `Upload ${selectedFiles.length || ""} image${selectedFiles.length !== 1 ? "s" : ""}`
              }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import { ADMIN_ROUTES } from "@/router/admin-routes";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import {
  Plus,
  X,
  AlertTriangle,
  Loader2,
  Check,
  ChevronRight,
  ImagePlus,
} from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import PlaceholderThumb from "@/components/admin/PlaceholderThumb.vue";
import Pagination from "@/components/admin/Pagination.vue";
import CustomDropdown from "@/components/shared/CustomDropdown.vue";
import type { DropdownOption } from "@/components/shared/CustomDropdown.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { money } from "@/utils/format";
import { useUIStore } from "@/stores/ui";
import { useProductsStore } from "@/stores/products";
import { createProduct, uploadProductImages } from "@/api/products";
import type { ProductResponse } from "@/api/products";
import { fetchModels, fetchModelVariants } from "@/api/models";

const toNum = (v: unknown) => (v === "" || v == null ? undefined : Number(v));

const ProductSchema = z.object({
  name: z.string().min(1, "Product name is required"),
  code: z.string().optional(),
  price: z.preprocess(
    toNum,
    z
      .number({
        required_error: "Price is required",
        invalid_type_error: "Price is required",
      })
      .positive("Price must be greater than 0"),
  ),
  cost: z.preprocess(toNum, z.number().min(0).optional()),
  initial_stock: z.preprocess(toNum, z.number().int().min(0).optional()),
});

const router = useRouter();
const ui = useUIStore();
const store = useProductsStore();
const drawerOpen = ref(false);
const saving = ref(false);
const drawerError = ref("");
const currentPage = ref(1);

// Selection state
const selectedModelId = ref<string>("");
const selectedModelName = ref<string>("");
const selectedVariantId = ref<string>("");
const variantError = ref("");

// Step indicator: 0=model, 1=variant, 2=details
const currentStep = computed(() => {
  if (!selectedModelId.value) return 0;
  if (!selectedVariantId.value) return 1;
  return 2;
});
function stepDone(i: number) {
  if (i === 0) return !!selectedModelId.value;
  if (i === 1) return !!selectedVariantId.value;
  return false;
}

const { defineField, handleSubmit, errors, resetForm, setFieldValue } = useForm(
  {
    validationSchema: toTypedSchema(ProductSchema),
    initialValues: {
      name: "",
      code: "",
      price: undefined,
      cost: undefined,
      initial_stock: undefined,
    },
  },
);

const [name] = defineField("name");
const [code] = defineField("code");
const [price] = defineField("price");
const [cost] = defineField("cost");
const [initial_stock] = defineField("initial_stock");

onMounted(() => store.loadProducts(currentPage.value));

function changePage(page: number) {
  currentPage.value = page;
  store.loadProducts(page);
}

function openNew() {
  resetForm();
  selectedModelId.value = "";
  selectedModelName.value = "";
  selectedVariantId.value = "";
  variantError.value = "";
  drawerError.value = "";
  drawerOpen.value = true;
}

async function modelsLoadFn(): Promise<DropdownOption[]> {
  const models = await fetchModels();
  return models.map((m) => ({
    value: String(m.id),
    label: m.name,
    sublabel: m.description,
  }));
}

async function variantsLoadFn(): Promise<DropdownOption[]> {
  if (!selectedModelId.value) return [];
  const variants = await fetchModelVariants(parseInt(selectedModelId.value));
  return variants.map((v) => {
    const parts = [v.size, v.color].filter(Boolean);
    return {
      value: String(v.id),
      label: parts.join(" · ") || `Variant ${v.id}`,
    };
  });
}

function onModelChange(
  value: string | string[],
  opt: DropdownOption | DropdownOption[],
) {
  selectedVariantId.value = "";
  variantError.value = "";
  if (!Array.isArray(opt)) selectedModelName.value = opt.label;
}

function onVariantChange(
  _value: string | string[],
  opt: DropdownOption | DropdownOption[],
) {
  variantError.value = "";
  if (!Array.isArray(opt)) {
    const variantLabel = opt.label.replace(" · ", " ");
    setFieldValue("name", `${selectedModelName.value} ${variantLabel}`.trim());
  }
}

const saveProduct = handleSubmit(async (values) => {
  if (!selectedVariantId.value) {
    variantError.value = "Please select a variant.";
    return;
  }
  variantError.value = "";
  saving.value = true;
  drawerError.value = "";
  try {
    await createProduct({
      variant_id: parseInt(selectedVariantId.value),
      name: values.name,
      code: values.code || undefined,
      price: values.price as number,
      cost: values.cost ?? undefined,
      initial_stock: values.initial_stock ?? undefined,
    });
    drawerOpen.value = false;
    ui.showToast("Product created successfully", "success");
    store.loadProducts(currentPage.value);
  } catch (e: unknown) {
    drawerError.value =
      e instanceof Error ? e.message : "Failed to create product.";
  } finally {
    saving.value = false;
  }
});

// ── Image upload ──────────────────────────────────────────────
const uploadDrawerOpen = ref(false);
const uploadTarget = ref<ProductResponse | null>(null);
const uploading = ref(false);
const uploadError = ref("");
const selectedFiles = ref<File[]>([]);
const previews = ref<string[]>([]);
const fileInputRef = ref<HTMLInputElement>();

function openUploadDrawer(product: ProductResponse) {
  uploadTarget.value = product;
  selectedFiles.value = [];
  previews.value = [];
  uploadError.value = "";
  uploadDrawerOpen.value = true;
}

function closeUploadDrawer() {
  previews.value.forEach(URL.revokeObjectURL);
  selectedFiles.value = [];
  previews.value = [];
  uploadDrawerOpen.value = false;
}

function onFilesChange(e: Event) {
  const input = e.target as HTMLInputElement;
  const added = Array.from(input.files ?? []);
  for (const file of added) {
    selectedFiles.value.push(file);
    previews.value.push(URL.createObjectURL(file));
  }
  input.value = "";
}

function removeFile(index: number) {
  URL.revokeObjectURL(previews.value[index]);
  selectedFiles.value.splice(index, 1);
  previews.value.splice(index, 1);
}

async function uploadImages() {
  if (!uploadTarget.value || selectedFiles.value.length === 0) return;
  uploading.value = true;
  uploadError.value = "";
  try {
    await uploadProductImages(uploadTarget.value.uuid, selectedFiles.value);
    ui.showToast("Images uploaded successfully", "success");
    closeUploadDrawer();
  } catch (e: unknown) {
    uploadError.value =
      e instanceof Error ? e.message : "Failed to upload images.";
  } finally {
    uploading.value = false;
  }
}

onUnmounted(() => previews.value.forEach(URL.revokeObjectURL));

function statusLabel(status: string): string {
  if (status === "in_stock") return "In stock";
  if (status === "low_stock") return "Low stock";
  if (status === "out_of_stock") return "Out of stock";
  return status;
}
function statusStyle(status: string): string {
  if (status === "in_stock")
    return "background:var(--green-bg);color:var(--green)";
  if (status === "low_stock")
    return "background:var(--amber-bg);color:var(--amber)";
  return "background:var(--red-bg);color:var(--red)";
}
function stockStyle(stock: number): string {
  if (stock === 0) return "background:var(--red-bg);color:var(--red)";
  if (stock <= 10) return "background:var(--amber-bg);color:var(--amber)";
  return "background:var(--green-bg);color:var(--green)";
}
</script>
