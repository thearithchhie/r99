<template>
  <AdminLayout>
    <DataNotFound
      v-if="error && !loading"
      :message="error"
      :back-to="ADMIN_ROUTES.products.list"
      back-label="Back to products"
    />

    <div v-else class="p-6 max-w-3xl mx-auto">
      <button
        class="flex items-center gap-1.5 text-[13px] text-muted-foreground hover:text-foreground transition-colors mb-4"
        @click="router.back()"
      >
        <ArrowLeft :size="14" /> Back to products
      </button>

      <!-- Loading skeleton -->
      <template v-if="loading">
        <Card class="mb-5">
          <div class="flex items-center justify-between px-8 py-5 border-b border-border/40">
            <div class="h-4 w-28 rounded bg-muted animate-pulse" />
            <div class="h-8 w-28 rounded bg-muted animate-pulse" />
          </div>
          <div v-for="n in 5" :key="n" class="flex items-center px-8 py-4 gap-8 border-b border-border/40 last:border-0">
            <div class="h-4 w-24 rounded bg-muted animate-pulse shrink-0" />
            <div class="h-4 rounded bg-muted animate-pulse flex-1" />
          </div>
        </Card>
        <div class="grid grid-cols-3 gap-3">
          <div v-for="n in 3" :key="n" class="aspect-square rounded-lg bg-muted animate-pulse" />
        </div>
      </template>

      <template v-else-if="product">
        <!-- Info card -->
        <Card class="mb-5">
          <div class="flex items-center justify-between px-8 py-5 border-b border-border/40">
            <p class="text-[14px] font-semibold text-muted-foreground">Product info</p>
            <Button size="sm" @click="openUploadDrawer">
              <ImagePlus :size="13" /> Upload images
            </Button>
          </div>

          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Name</span>
            <span class="text-[13.5px] font-medium">{{ product.name }}</span>
          </div>
          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Code</span>
            <span class="font-mono text-[13px]">{{ product.code || "—" }}</span>
          </div>
          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Model</span>
            <span class="text-[13.5px]">{{ product.model_name || "—" }}</span>
          </div>
          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Variant</span>
            <span class="text-[13.5px]">
              {{ [product.variant_size, product.variant_color].filter(Boolean).join(" · ") || "—" }}
            </span>
          </div>
          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Price</span>
            <span class="text-[13.5px] font-medium">{{ money(product.price) }}</span>
          </div>
          <div class="flex items-center px-8 py-4 border-b border-border/40">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Stock</span>
            <span
              class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
              :style="stockStyle(product.current_stock)"
            >{{ product.current_stock }} units</span>
          </div>
          <div class="flex items-center px-8 py-4">
            <span class="w-32 text-[13px] text-muted-foreground shrink-0">Status</span>
            <span
              class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
              :style="statusStyle(product.status)"
            ><span class="status-dot" />{{ statusLabel(product.status) }}</span>
          </div>
        </Card>

        <!-- Images -->
        <div class="flex items-center justify-between mb-3">
          <h2 class="text-[14px] font-semibold">
            Images
            <span class="text-muted-foreground font-normal text-[13px]">{{ product.images.length }}</span>
          </h2>
        </div>

        <div v-if="product.images.length" class="grid grid-cols-3 gap-3">
          <div
            v-for="img in product.images"
            :key="img.id"
            class="relative group rounded-lg overflow-hidden border border-border aspect-square bg-muted"
          >
            <img
              :src="img.file_url"
              :alt="img.file_name"
              class="w-full h-full object-cover"
              @error="(e) => ((e.target as HTMLImageElement).style.display = 'none')"
            />
            <!-- fallback when S3 URL is inaccessible -->
            <div class="absolute inset-0 flex flex-col items-center justify-center gap-1.5 text-muted-foreground pointer-events-none">
              <ImageOff :size="22" />
              <span class="text-[11px]">Not accessible</span>
            </div>
            <div class="absolute inset-0 bg-black/0 group-hover:bg-black/40 transition-colors" />
            <button
              class="absolute top-2 right-2 flex items-center justify-center w-7 h-7 rounded-full bg-black/60 text-white opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-600"
              :disabled="deletingId === img.id"
              @click="confirmDelete(img)"
            >
              <Loader2 v-if="deletingId === img.id" :size="13" class="animate-spin" />
              <Trash2 v-else :size="13" />
            </button>
            <span class="absolute bottom-0 left-0 right-0 bg-black/50 text-white text-[10px] px-2 py-1 truncate opacity-0 group-hover:opacity-100 transition-opacity">
              {{ img.file_name }}
            </span>
          </div>
        </div>

        <Card v-else class="py-14 text-center text-muted-foreground text-sm">
          No images yet. Click "Upload images" to add some.
        </Card>
      </template>
    </div>

    <!-- Delete confirm dialog -->
    <ConfirmDialog
      :open="!!pendingDeleteImage"
      title="Delete image?"
      :description="`'${pendingDeleteImage?.file_name}' will be permanently removed. This cannot be undone.`"
      confirm-label="Delete"
      loading-label="Deleting…"
      :loading="!!deletingId"
      @confirm="pendingDeleteImage && deleteImage(pendingDeleteImage.id)"
      @cancel="pendingDeleteImage = null"
    />

    <!-- Upload drawer -->
    <Sheet :open="uploadDrawerOpen" @update:open="(v) => !v && closeUploadDrawer()">
      <SheetContent class="overflow-y-auto p-0 w-[480px] sm:max-w-[480px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div>
              <span class="text-[15px] font-semibold">Upload images</span>
              <p v-if="product" class="text-[12.5px] text-muted-foreground mt-0.5">{{ product.name }}</p>
            </div>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="closeUploadDrawer">
              <X :size="18" />
            </Button>
          </div>

          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <label
              class="flex flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed border-border bg-muted/30 px-6 py-10 text-center cursor-pointer transition-colors hover:bg-muted/50 hover:border-muted-foreground/40"
              :class="uploading ? 'pointer-events-none opacity-50' : ''"
            >
              <ImagePlus :size="28" class="text-muted-foreground" />
              <span class="text-[13.5px] font-medium">Click to select images</span>
              <span class="text-[12px] text-muted-foreground">JPG, PNG, WEBP — multiple allowed</span>
              <input
                ref="fileInputRef"
                type="file"
                accept="image/*"
                multiple
                class="hidden"
                @change="onFilesChange"
              />
            </label>

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
                <span class="absolute bottom-0 left-0 right-0 bg-black/50 text-white text-[10px] px-1.5 py-0.5 truncate">
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
              @click="doUpload"
            >
              <Loader2 v-if="uploading" :size="14" class="animate-spin" />
              {{ uploading ? "Uploading…" : `Upload ${selectedFiles.length || ""} image${selectedFiles.length !== 1 ? "s" : ""}` }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ArrowLeft, ImagePlus, ImageOff, X, Trash2, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import DataNotFound from "@/components/admin/DataNotFound.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import ConfirmDialog from "@/components/shared/ConfirmDialog.vue";
import { useUIStore } from "@/stores/ui";
import { fetchProductWithImages, uploadProductImages, deleteProductImage } from "@/api/products";
import type { ProductDetailResponse } from "@/api/products";
import { ADMIN_ROUTES } from "@/router/admin-routes";
import { money } from "@/utils/format";

const route = useRoute();
const router = useRouter();
const ui = useUIStore();

const product = ref<ProductDetailResponse | null>(null);
const loading = ref(false);
const error = ref("");
const deletingId = ref<number | null>(null);
const pendingDeleteImage = ref<ProductDetailResponse["images"][number] | null>(null);

async function load() {
  loading.value = true;
  error.value = "";
  try {
    product.value = await fetchProductWithImages(route.params.uuid as string);
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : "Product not found.";
  } finally {
    loading.value = false;
  }
}

onMounted(load);

function confirmDelete(img: ProductDetailResponse["images"][number]) {
  pendingDeleteImage.value = img;
}

async function deleteImage(imageId: number) {
  if (!product.value) return;
  deletingId.value = imageId;
  try {
    await deleteProductImage(product.value.uuid, imageId);
    product.value.images = product.value.images.filter((img) => img.id !== imageId);
    pendingDeleteImage.value = null;
    ui.showToast("Image deleted", "success");
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to delete image.", "error");
  } finally {
    deletingId.value = null;
  }
}

// ── Upload drawer ─────────────────────────────────────────────
const uploadDrawerOpen = ref(false);
const uploading = ref(false);
const uploadError = ref("");
const selectedFiles = ref<File[]>([]);
const previews = ref<string[]>([]);
const fileInputRef = ref<HTMLInputElement>();

function openUploadDrawer() {
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
  for (const file of Array.from(input.files ?? [])) {
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

async function doUpload() {
  if (!product.value || selectedFiles.value.length === 0) return;
  uploading.value = true;
  uploadError.value = "";
  try {
    await uploadProductImages(product.value.uuid, selectedFiles.value);
    closeUploadDrawer();
    ui.showToast("Images uploaded", "success");
    load();
  } catch (e: unknown) {
    uploadError.value = e instanceof Error ? e.message : "Failed to upload images.";
  } finally {
    uploading.value = false;
  }
}

onUnmounted(() => previews.value.forEach(URL.revokeObjectURL));

function statusLabel(status: string) {
  if (status === "in_stock") return "In stock";
  if (status === "low_stock") return "Low stock";
  if (status === "out_of_stock") return "Out of stock";
  return status;
}
function statusStyle(status: string) {
  if (status === "in_stock") return "background:var(--green-bg);color:var(--green)";
  if (status === "low_stock") return "background:var(--amber-bg);color:var(--amber)";
  return "background:var(--red-bg);color:var(--red)";
}
function stockStyle(stock: number) {
  if (stock === 0) return "background:var(--red-bg);color:var(--red)";
  if (stock <= 10) return "background:var(--amber-bg);color:var(--amber)";
  return "background:var(--green-bg);color:var(--green)";
}
</script>
