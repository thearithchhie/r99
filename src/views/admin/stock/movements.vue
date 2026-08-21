<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ store.movementsMeta ? store.movementsMeta.total + " movements" : "" }}
        </p>
        <div class="flex items-center gap-2">
          <Button size="sm" variant="outline" @click="openDrawer('out')">
            <TrendingDown :size="14" /> Stock Out
          </Button>
          <Button size="sm" @click="openDrawer('in')">
            <TrendingUp :size="14" /> Stock In
          </Button>
        </div>
      </div>

      <!-- Error -->
      <div
        v-if="store.movementsError"
        class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4"
      >
        <AlertTriangle :size="14" class="shrink-0" />{{ store.movementsError }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Product</TableHead>
              <TableHead>Reason</TableHead>
              <TableHead class="text-right">Delta</TableHead>
              <TableHead>Note</TableHead>
              <TableHead>Date</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="store.movementsLoading" v-for="n in 8" :key="'skel-' + n">
              <TableCell colspan="5">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <template v-if="!store.movementsLoading">
              <TableRow v-for="m in store.movements" :key="m.id">
                <TableCell>
                  <div class="flex flex-col">
                    <span class="font-medium">{{ m.product_name }}</span>
                    <span class="text-muted-foreground font-mono text-[11.5px]">{{ m.product_code }}</span>
                  </div>
                </TableCell>
                <TableCell>
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold bg-muted text-muted-foreground capitalize">
                    {{ m.reason }}
                  </span>
                </TableCell>
                <TableCell class="text-right">
                  <span
                    class="inline-flex items-center gap-0.5 font-semibold text-[13px]"
                    :class="m.delta >= 0 ? 'text-green-600' : 'text-red-500'"
                  >
                    <TrendingUp v-if="m.delta >= 0" :size="13" />
                    <TrendingDown v-else :size="13" />
                    {{ m.delta >= 0 ? "+" : "" }}{{ m.delta }}
                  </span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ m.note ?? "—" }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(m.created_at) }}</TableCell>
              </TableRow>

              <TableRow v-if="store.movements.length === 0 && !store.movementsError">
                <TableCell colspan="5" class="text-center text-muted-foreground py-12 text-sm">
                  No stock movements found.
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <!-- Pagination -->
      <div
        v-if="store.movementsMeta && store.movementsMeta.total_pages > 1"
        class="flex flex-col items-center gap-2 mt-4"
      >
        <Pagination :page="currentPage" :total-pages="store.movementsMeta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Stock In / Out drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <!-- Header -->
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div class="flex items-center gap-2">
              <span
                class="inline-flex items-center justify-center w-7 h-7 rounded-[6px]"
                :class="movementType === 'in' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-500'"
              >
                <TrendingUp v-if="movementType === 'in'" :size="14" />
                <TrendingDown v-else :size="14" />
              </span>
              <span class="text-[15px] font-semibold">
                {{ movementType === "in" ? "Stock In" : "Stock Out" }}
              </span>
            </div>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false">
              <X :size="18" />
            </Button>
          </div>

          <!-- Type toggle -->
          <div class="px-5 pt-4 pb-0">
            <div class="inline-flex rounded-lg border border-border p-0.5 bg-muted/40 w-full">
              <button
                class="flex-1 flex items-center justify-center gap-1.5 py-1.5 rounded-md text-[13px] font-medium transition-colors"
                :class="movementType === 'in' ? 'bg-background shadow-sm text-green-600' : 'text-muted-foreground hover:text-foreground'"
                @click="movementType = 'in'"
              >
                <TrendingUp :size="13" /> Stock In
              </button>
              <button
                class="flex-1 flex items-center justify-center gap-1.5 py-1.5 rounded-md text-[13px] font-medium transition-colors"
                :class="movementType === 'out' ? 'bg-background shadow-sm text-red-500' : 'text-muted-foreground hover:text-foreground'"
                @click="movementType = 'out'"
              >
                <TrendingDown :size="13" /> Stock Out
              </button>
            </div>
          </div>

          <!-- Form -->
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5">
              <Label>Product <span class="text-red-500">*</span></Label>
              <CustomDropdown
                v-model="selectedProductUuid"
                :search-fn="productSearchFn"
                placeholder="Search product…"
                search-placeholder="Search by name or code…"
                :error="productError || undefined"
              />
              <p v-if="productError" class="text-[12px] text-red-500">{{ productError }}</p>
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Quantity <span class="text-red-500">*</span></Label>
                <Input v-model="quantity" type="number" min="1" placeholder="0" :error="errors.quantity" />
                <p v-if="errors.quantity" class="text-[12px] text-red-500">{{ errors.quantity }}</p>
              </div>
              <div class="flex flex-col gap-1.5">
                <Label>Reason <span class="text-red-500">*</span></Label>
                <select
                  v-model="reason"
                  class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                >
                  <option v-if="movementType === 'in'" value="purchase">Purchase</option>
                  <option v-if="movementType === 'in'" value="return">Return</option>
                  <option v-if="movementType === 'in'" value="adjustment">Adjustment</option>
                  <option v-if="movementType === 'in'" value="initial">Initial</option>
                  <option v-if="movementType === 'out'" value="sale">Sale</option>
                  <option v-if="movementType === 'out'" value="damage">Damage</option>
                  <option v-if="movementType === 'out'" value="adjustment">Adjustment</option>
                  <option v-if="movementType === 'out'" value="loss">Loss</option>
                </select>
              </div>
            </div>

            <div class="flex flex-col gap-1.5">
              <Label>Reference ID <span class="text-muted-foreground font-normal">(optional)</span></Label>
              <Input v-model="reference_id" placeholder="PO-2026-001" />
            </div>

            <div class="flex flex-col gap-1.5">
              <Label>Note <span class="text-muted-foreground font-normal">(optional)</span></Label>
              <Input v-model="note" placeholder="e.g. Received from supplier" />
            </div>

            <div
              v-if="drawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ drawerError }}
            </div>

            <Button
              class="w-full mt-1"
              :class="movementType === 'out' ? 'bg-red-600 hover:bg-red-700 text-white' : ''"
              :disabled="saving"
              @click="save"
            >
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Saving…" : movementType === "in" ? "Add Stock" : "Deduct Stock" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from "vue";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { AlertTriangle, TrendingUp, TrendingDown, X, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import Pagination from "@/components/admin/Pagination.vue";
import CustomDropdown from "@/components/shared/CustomDropdown.vue";
import type { DropdownOption } from "@/components/shared/CustomDropdown.vue";
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
import { useStockStore } from "@/stores/stock";
import { createStockMovement } from "@/api/stock";
import { searchProducts } from "@/api/products";

async function productSearchFn(q: string): Promise<DropdownOption[]> {
  const data = await searchProducts(q);
  return data.map((p) => ({ value: p.uuid, label: p.name, sublabel: p.code }));
}

const MovementSchema = z.object({
  quantity: z.preprocess(
    (v) => (v === '' || v == null ? undefined : Number(v)),
    z.number({ required_error: 'Quantity is required', invalid_type_error: 'Quantity is required' })
      .int('Quantity must be a whole number')
      .positive('Quantity must be greater than 0'),
  ),
  reason: z.string().min(1, 'Reason is required'),
  reference_id: z.string().optional(),
  note: z.string().optional(),
})

const ui = useUIStore();
const store = useStockStore();
const currentPage = ref(1);

const drawerOpen = ref(false);
const saving = ref(false);
const drawerError = ref("");
const movementType = ref<"in" | "out">("in");
const selectedProductUuid = ref<string>("");
const productError = ref("");

const { defineField, handleSubmit, errors, resetForm, setFieldValue } = useForm({
  validationSchema: toTypedSchema(MovementSchema),
  initialValues: { quantity: undefined, reason: 'purchase', reference_id: '', note: '' },
})

const [quantity] = defineField('quantity')
const [reason] = defineField('reason')
const [reference_id] = defineField('reference_id')
const [note] = defineField('note')

onMounted(() => store.loadMovements(currentPage.value));

function changePage(page: number) {
  currentPage.value = page;
  store.loadMovements(page);
}

function openDrawer(type: "in" | "out") {
  movementType.value = type;
  selectedProductUuid.value = "";
  productError.value = "";
  drawerError.value = "";
  resetForm({ values: { quantity: undefined, reason: type === 'in' ? 'purchase' : 'sale', reference_id: '', note: '' } });
  drawerOpen.value = true;
}

watch(movementType, (type) => {
  setFieldValue('reason', type === 'in' ? 'purchase' : 'sale');
});

const save = handleSubmit(async (values) => {
  if (!selectedProductUuid.value) {
    productError.value = "Please select a product.";
    return;
  }
  productError.value = "";
  saving.value = true;
  drawerError.value = "";
  try {
    const delta = movementType.value === "in" ? values.quantity : -(values.quantity as number);
    await createStockMovement({
      product_uuid: selectedProductUuid.value,
      delta,
      reason: values.reason,
      reference_id: values.reference_id || undefined,
      note: values.note || undefined,
    });
    drawerOpen.value = false;
    ui.showToast(
      movementType.value === "in" ? "Stock added successfully" : "Stock deducted successfully",
      "success",
    );
    store.loadMovements(currentPage.value);
  } catch (e: unknown) {
    drawerError.value = e instanceof Error ? e.message : "Failed to save movement.";
  } finally {
    saving.value = false;
  }
});
</script>
