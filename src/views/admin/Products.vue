<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex gap-3 mb-4 flex-wrap items-center">
        <Tabs v-model="catFilter">
          <TabsList>
            <TabsTrigger v-for="c in ['All','Women','Men']" :key="c" :value="c">{{ c }}</TabsTrigger>
          </TabsList>
        </Tabs>
        <Tabs v-model="stockFilter">
          <TabsList>
            <TabsTrigger v-for="s in ['All','Active','Low stock','Out of stock']" :key="s" :value="s">{{ s }}</TabsTrigger>
          </TabsList>
        </Tabs>
        <div class="flex-1" />
        <Button size="sm" @click="openNew"><Plus :size="14" /> New product</Button>
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Product</TableHead>
              <TableHead>Category</TableHead>
              <TableHead class="text-right">Price</TableHead>
              <TableHead>Stock</TableHead>
              <TableHead>Status</TableHead>
              <TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="p in filtered" :key="p.id">
              <TableCell>
                <div class="flex items-center gap-2.5">
                  <PlaceholderThumb :tone="p.tone" :size="36" />
                  <div>
                    <div class="font-medium">{{ p.name }}</div>
                    <div class="text-muted-foreground mono text-[11.5px]">{{ p.sku }}</div>
                  </div>
                </div>
              </TableCell>
              <TableCell class="text-muted-foreground">{{ p.cat }} · {{ p.line }}</TableCell>
              <TableCell class="text-right font-medium">{{ money(p.price) }}</TableCell>
              <TableCell>
                <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                  :style="p.stock === 0 ? 'background: var(--red-bg); color: var(--red)' : p.stock <= 10 ? 'background: var(--amber-bg); color: var(--amber)' : 'background: var(--green-bg); color: var(--green)'">
                  {{ p.stock === 0 ? 'Out of stock' : p.stock + ' units' }}
                </span>
              </TableCell>
              <TableCell>
                <span class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                  :style="p.status === 'Active' ? 'background: var(--green-bg); color: var(--green)' : p.status === 'Out of stock' ? 'background: var(--red-bg); color: var(--red)' : 'background: var(--amber-bg); color: var(--amber)'">
                  <span class="status-dot" />{{ p.status }}
                </span>
              </TableCell>
              <TableCell>
                <div class="flex gap-1">
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="openEdit(p)"><Pencil :size="13" /></Button>
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-destructive hover:text-destructive"><Trash2 :size="13" /></Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
        <div v-if="filtered.length === 0" class="text-center text-muted-foreground py-12 text-[13.5px]">No products match filters.</div>
      </Card>
    </div>

    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">{{ editingProduct ? 'Edit product' : 'New product' }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5"><Label>Product name</Label><Input v-model="form.name" placeholder="Relaxed Linen Shirt" /></div>
            <div class="flex flex-col gap-1.5"><Label>SKU</Label><Input v-model="form.sku" placeholder="RW-LIN-01" /></div>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <Label>Category</Label>
                <select class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" v-model="form.cat">
                  <option>Women</option><option>Men</option><option>Accessories</option><option>Outerwear</option>
                </select>
              </div>
              <div class="flex flex-col gap-1.5"><Label>Line</Label><Input v-model="form.line" placeholder="Knitwear" /></div>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5"><Label>Price ($)</Label><Input v-model.number="form.price" type="number" min="0" /></div>
              <div class="flex flex-col gap-1.5"><Label>Cost ($)</Label><Input v-model.number="form.cost" type="number" min="0" /></div>
            </div>
            <div class="flex flex-col gap-1.5"><Label>Stock</Label><Input v-model.number="form.stock" type="number" min="0" /></div>
            <Button class="w-full mt-1" @click="saveProduct">{{ editingProduct ? 'Save changes' : 'Create product' }}</Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, reactive } from 'vue'
import { Plus, Pencil, Trash2, X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import PlaceholderThumb from '@/components/admin/PlaceholderThumb.vue'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { PRODUCTS } from '@/data/products'
import type { AdminProduct } from '@/data/products'
import { money } from '@/utils/format'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()
const catFilter = ref('All')
const stockFilter = ref('All')
const drawerOpen = ref(false)
const editingProduct = ref<AdminProduct | null>(null)
const form = reactive({ name: '', sku: '', cat: 'Women' as AdminProduct['cat'], line: '', price: 0, cost: 0, stock: 0 })

const filtered = computed(() => {
  let r = PRODUCTS
  if (catFilter.value !== 'All') r = r.filter(p => p.cat === catFilter.value)
  if (stockFilter.value === 'Low stock') r = r.filter(p => p.stock > 0 && p.stock <= 10)
  else if (stockFilter.value === 'Out of stock') r = r.filter(p => p.stock === 0)
  else if (stockFilter.value === 'Active') r = r.filter(p => p.status === 'Active')
  return r
})

function openNew() { editingProduct.value = null; Object.assign(form, { name:'',sku:'',cat:'Women',line:'',price:0,cost:0,stock:0 }); drawerOpen.value = true }
function openEdit(p: AdminProduct) { editingProduct.value = p; Object.assign(form, p); drawerOpen.value = true }
function saveProduct() { ui.showToast(editingProduct.value ? 'Product updated' : 'Product created'); drawerOpen.value = false }
</script>
