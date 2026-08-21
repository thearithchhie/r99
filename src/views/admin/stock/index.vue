<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ store.meta ? store.meta.total + " items" : "" }}
        </p>
      </div>

      <!-- Error -->
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
              <TableHead class="text-right">Quantity</TableHead>
              <TableHead>Last updated</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <!-- Loading skeleton -->
            <TableRow v-if="store.loading" v-for="n in 8" :key="'skel-' + n">
              <TableCell colspan="3">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <template v-if="!store.loading">
              <TableRow v-for="item in store.stockLevels" :key="item.id">
                <TableCell>
                  <div class="flex flex-col">
                    <span class="font-medium">{{ item.product_name }}</span>
                    <span
                      class="text-muted-foreground font-mono text-[11.5px]"
                      >{{ item.product_code }}</span
                    >
                  </div>
                </TableCell>
                <TableCell class="text-right">
                  <span
                    class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="quantityStyle(item.quantity)"
                  >
                    {{ item.quantity }} units
                  </span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">
                  {{ fmtDate(item.updated_at) }}
                </TableCell>
              </TableRow>

              <TableRow v-if="store.stockLevels.length === 0 && !store.error">
                <TableCell
                  colspan="3"
                  class="text-center text-muted-foreground py-12 text-sm"
                >
                  No stock records found.
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <!-- Pagination -->
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
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { AlertTriangle } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import Pagination from "@/components/admin/Pagination.vue";
import { Card } from "@/components/ui/card";
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from "@/components/ui/table";
import { fmtDate } from "@/utils/format";
import { useStockStore } from "@/stores/stock";

const store = useStockStore();
const currentPage = ref(1);

onMounted(() => store.loadStockLevels(currentPage.value));

function changePage(page: number) {
  currentPage.value = page;
  store.loadStockLevels(page);
}

function quantityStyle(qty: number): string {
  if (qty === 0) return "background:var(--red-bg);color:var(--red)";
  if (qty <= 10) return "background:var(--amber-bg);color:var(--amber)";
  return "background:var(--green-bg);color:var(--green)";
}
</script>
