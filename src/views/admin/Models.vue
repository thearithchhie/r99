<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">{{ MODELS.length }} models</p>
        <Button size="sm"><Plus :size="14" /> New model</Button>
      </div>

      <div class="flex flex-col gap-4">
        <Card v-for="m in MODELS" :key="m.id">
          <CardHeader>
            <div class="flex justify-between items-center">
              <div>
                <div class="flex items-center gap-2.5">
                  <span class="mono text-[18px] font-bold">{{ m.code }}</span>
                  <span class="text-[15px] font-medium">{{ m.name }}</span>
                </div>
                <div class="text-muted-foreground text-[12.5px] mt-0.5">
                  Total stock: {{ totalStock(m) }} units across {{ m.sizes.length }} sizes
                </div>
              </div>
              <Button variant="outline" size="sm" @click="toggleModel(m.id)">
                {{ openModels[m.id] ? 'Collapse' : 'Expand' }}
              </Button>
            </div>
          </CardHeader>
          <Transition name="expand">
            <CardContent v-if="openModels[m.id]" class="pt-0 px-0">
              <Separator />
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Size</TableHead><TableHead>Color</TableHead><TableHead>Hex</TableHead>
                    <TableHead class="text-right">Stock</TableHead><TableHead />
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <template v-for="sv in m.sizes" :key="sv.size">
                    <TableRow v-for="(cv, ci) in sv.colors" :key="sv.size + cv.color">
                      <TableCell v-if="ci === 0" :rowspan="sv.colors.length" class="align-top pt-4 font-semibold">{{ sv.size }}</TableCell>
                      <TableCell>
                        <div class="flex items-center gap-2">
                          <div class="w-3.5 h-3.5 rounded-full shrink-0 border border-border/50" :style="{ background: cv.hex }" />
                          {{ cv.color }}
                        </div>
                      </TableCell>
                      <TableCell class="mono text-muted-foreground text-[12px]">{{ cv.hex }}</TableCell>
                      <TableCell class="text-right">
                        <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                          :style="cv.stock === 0 ? 'background: var(--red-bg); color: var(--red)' : cv.stock < 10 ? 'background: var(--amber-bg); color: var(--amber)' : 'background: var(--green-bg); color: var(--green)'">
                          {{ cv.stock }}
                        </span>
                      </TableCell>
                      <TableCell>
                        <Button variant="ghost" size="icon" class="h-8 w-8"><Pencil :size="13" /></Button>
                      </TableCell>
                    </TableRow>
                  </template>
                </TableBody>
              </Table>
            </CardContent>
          </Transition>
        </Card>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { Plus, Pencil } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Card, CardHeader, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Separator } from '@/components/ui/separator'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { MODELS } from '@/data/models'
import type { StockModel } from '@/data/models'

const openModels = reactive<Record<string, boolean>>({})
function toggleModel(id: string) { openModels[id] = !openModels[id] }
function totalStock(m: StockModel) { return m.sizes.reduce((s, sv) => s + sv.colors.reduce((cs, cv) => cs + cv.stock, 0), 0) }
</script>

<style scoped>
.expand-enter-active, .expand-leave-active { transition: opacity 0.2s ease; }
.expand-enter-from, .expand-leave-to { opacity: 0; }
</style>
