<template>
  <AdminLayout>
    <div class="fade p-5 flex flex-col gap-4">
      <div class="kpi-grid grid grid-cols-3 gap-4">
        <Card v-for="k in kpiCards" :key="k.label">
          <CardContent class="pt-5">
            <div class="text-muted-foreground text-[12.5px] mb-1.5">{{ k.label }}</div>
            <div class="text-2xl font-semibold">{{ k.value }}</div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div class="flex justify-between items-center">
            <CardTitle>Discount codes</CardTitle>
            <Button size="sm" @click="drawerOpen = true"><Plus :size="14" /> New code</Button>
          </div>
        </CardHeader>
        <CardContent class="pt-0 px-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Code</TableHead><TableHead>Type</TableHead><TableHead>Used</TableHead>
                <TableHead>Min order</TableHead><TableHead>Expiry</TableHead><TableHead>Status</TableHead><TableHead />
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="d in discounts" :key="d.id">
                <TableCell>
                  <div class="flex items-center gap-2">
                    <span class="mono text-[13px] font-medium">{{ d.code }}</span>
                    <Button variant="ghost" size="icon" class="h-6 w-6" @click="copyCode(d.code)"><Copy :size="12" /></Button>
                  </div>
                  <div class="text-muted-foreground text-[11.5px]">{{ d.desc }}</div>
                </TableCell>
                <TableCell>
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="typeBadge(d.type)">{{ typeLabel(d) }}</span>
                </TableCell>
                <TableCell>
                  <div>{{ d.uses }}{{ d.limit ? ' / ' + d.limit : '' }}</div>
                  <div v-if="d.limit" class="mt-1 h-1 rounded-full bg-border w-20">
                    <div class="h-full rounded-full bg-primary" :style="{ width: Math.min(d.uses / d.limit * 100, 100) + '%' }" />
                  </div>
                </TableCell>
                <TableCell class="text-muted-foreground">{{ d.minOrder ? '$' + d.minOrder : '—' }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(d.expiry) }}</TableCell>
                <TableCell>
                  <span class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="d.status === 'Active' ? 'background: var(--green-bg); color: var(--green)' : d.status === 'Expired' ? 'background: var(--red-bg); color: var(--red)' : 'background: var(--amber-bg); color: var(--amber)'">
                    <span class="status-dot" />{{ d.status }}
                  </span>
                </TableCell>
                <TableCell>
                  <div class="flex gap-1">
                    <Button variant="ghost" size="icon" class="h-8 w-8" @click="editDiscount(d)"><Pencil :size="13" /></Button>
                    <Button variant="ghost" size="icon" class="h-8 w-8 text-destructive hover:text-destructive"><Trash2 :size="13" /></Button>
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>

    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="font-semibold text-[15px]">{{ editingDiscount ? 'Edit code' : 'New discount code' }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1 overflow-y-auto">
            <div class="flex flex-col gap-1.5">
              <Label>Code</Label>
              <div class="flex gap-2">
                <Input v-model="form.code" placeholder="SUMMER25" class="uppercase" />
                <Button variant="outline" size="sm" @click="form.code = generateCode()">Generate</Button>
              </div>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Type</Label>
              <select class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" v-model="form.type">
                <option value="percent">Percentage off</option><option value="fixed">Fixed amount off</option><option value="shipping">Free shipping</option>
              </select>
            </div>
            <div v-if="form.type !== 'shipping'" class="flex flex-col gap-1.5">
              <Label>Value</Label>
              <Input v-model.number="form.value" type="number" min="1" :placeholder="form.type === 'percent' ? '10' : '20'" />
            </div>
            <div class="flex flex-col gap-1.5"><Label>Minimum order ($)</Label><Input v-model.number="form.minOrder" type="number" min="0" /></div>
            <div class="flex flex-col gap-1.5"><Label>Usage limit (0 = unlimited)</Label><Input v-model.number="form.limit" type="number" min="0" /></div>
            <div class="flex flex-col gap-1.5"><Label>Expiry date</Label><Input v-model="form.expiry" type="date" /></div>
            <div class="flex flex-col gap-1.5"><Label>Internal note</Label><Input v-model="form.desc" placeholder="VIP customers only" /></div>
            <Button class="w-full mt-1" @click="saveDiscount">{{ editingDiscount ? 'Save changes' : 'Create code' }}</Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'
import { Plus, Copy, Pencil, Trash2, X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { DISCOUNTS } from '@/data/users'
import type { Discount } from '@/data/users'
import { fmtDateShort } from '@/utils/format'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()
const discounts = ref([...DISCOUNTS])
const drawerOpen = ref(false)
const editingDiscount = ref<Discount | null>(null)
const form = reactive({ code: '', type: 'percent' as Discount['type'], value: 10, minOrder: 0, limit: 0, expiry: '', desc: '' })

const now = new Date()
const kpiCards = computed(() => [
  { label: 'Active codes', value: discounts.value.filter(d => d.status === 'Active').length },
  { label: 'Total redemptions', value: discounts.value.reduce((s, d) => s + d.uses, 0) },
  { label: 'Expiring this month', value: discounts.value.filter(d => d.expiry.getFullYear() === now.getFullYear() && d.expiry.getMonth() === now.getMonth() && d.status === 'Active').length },
])

function typeBadge(type: string) {
  if (type === 'percent') return 'background: var(--blue-bg); color: var(--blue)'
  if (type === 'fixed')   return 'background: var(--violet-bg); color: var(--violet)'
  return 'background: var(--green-bg); color: var(--green)'
}
function typeLabel(d: Discount) {
  if (d.type === 'percent') return d.value + '% off'
  if (d.type === 'fixed')   return '$' + d.value + ' off'
  return 'Free shipping'
}
function copyCode(code: string) { navigator.clipboard.writeText(code).catch(() => {}); ui.showToast('Code copied: ' + code) }
function generateCode() { return Array.from({ length: 8 }, () => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[Math.floor(Math.random() * 36)]).join('') }
function editDiscount(d: Discount) { editingDiscount.value = d; Object.assign(form, { ...d, expiry: d.expiry.toISOString().slice(0, 10) }); drawerOpen.value = true }
function saveDiscount() { ui.showToast(editingDiscount.value ? 'Discount updated' : 'Discount created'); drawerOpen.value = false; editingDiscount.value = null }
</script>
