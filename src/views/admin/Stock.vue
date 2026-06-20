<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">Stock levels by model and variant</p>
        <Tabs v-model="filter">
          <TabsList>
            <TabsTrigger value="All">All stock</TabsTrigger>
            <TabsTrigger value="Low">Low stock</TabsTrigger>
            <TabsTrigger value="Out">Out of stock</TabsTrigger>
          </TabsList>
        </Tabs>
      </div>

      <div class="flex flex-col gap-4">
        <Card v-for="m in MODELS" :key="m.id">
          <div class="flex items-center gap-2.5 px-5 py-3.5 border-b border-border">
            <span class="mono font-bold text-[16px]">{{ m.code }}</span>
            <span class="font-medium">{{ m.name }}</span>
            <span class="text-muted-foreground text-[12.5px]">· {{ totalStock(m) }} total</span>
          </div>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Size</TableHead><TableHead>Color</TableHead>
                <TableHead class="text-right">Stock</TableHead><TableHead class="text-right w-32">Update</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <template v-for="sv in m.sizes" :key="sv.size">
                <TableRow v-for="cv in filteredColors(sv.colors)" :key="sv.size + cv.color"
                  :class="cv.stock === 0 ? 'bg-red-50' : cv.stock < 10 ? 'bg-amber-50' : ''">
                  <TableCell class="font-semibold">{{ sv.size }}</TableCell>
                  <TableCell>
                    <div class="flex items-center gap-2">
                      <div class="w-3 h-3 rounded-full shrink-0 border border-black/10" :style="{ background: cv.hex }" />
                      {{ cv.color }}
                    </div>
                  </TableCell>
                  <TableCell class="text-right">
                    <span :class="cv.stock === 0 ? 'text-red-600' : cv.stock < 10 ? 'text-amber-600' : 'text-green-600'" class="font-semibold text-[13px]">{{ cv.stock }}</span>
                  </TableCell>
                  <TableCell class="text-right">
                    <div class="flex items-center gap-1.5 justify-end">
                      <input type="number" class="h-7 w-16 rounded border border-input bg-transparent px-2 text-right text-[13px] focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring"
                        :value="cv.stock" min="0"
                        @change="updateStock(m.id, sv.size, cv.color, ($event.target as HTMLInputElement).valueAsNumber)" />
                      <Check :size="14" class="text-green-600 shrink-0" />
                    </div>
                  </TableCell>
                </TableRow>
              </template>
            </TableBody>
          </Table>
        </Card>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { Check } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Card } from '@/components/ui/card'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { MODELS } from '@/data/models'
import type { ModelColorVariant, StockModel } from '@/data/models'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()
const filter = ref('All')

function filteredColors(colors: ModelColorVariant[]) {
  if (filter.value === 'Low') return colors.filter(c => c.stock > 0 && c.stock < 10)
  if (filter.value === 'Out') return colors.filter(c => c.stock === 0)
  return colors
}
function totalStock(m: StockModel) { return m.sizes.reduce((s, sv) => s + sv.colors.reduce((cs, cv) => cs + cv.stock, 0), 0) }
function updateStock(_: string, __: string, ___: string, ____: number) { ui.showToast('Stock updated') }
</script>
