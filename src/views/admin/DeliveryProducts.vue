<template>
  <AdminLayout>
    <div class="fade p-5 flex flex-col gap-5">

      <!-- Header -->
      <div class="flex items-center justify-between">
        <div>
          <h2 class="font-semibold text-[16px]">Delivery Products</h2>
          <p class="text-muted-foreground text-[13px] mt-0.5">{{ store.products.length }} products in catalog</p>
        </div>
        <Button size="sm" class="h-8 gap-1.5" @click="openAdd"><Plus :size="13" /> Add product</Button>
      </div>

      <!-- Empty state -->
      <div v-if="store.products.length === 0" class="flex flex-col items-center justify-center py-20 gap-4">
        <div class="w-14 h-14 rounded-full bg-muted flex items-center justify-center">
          <Package :size="24" class="text-muted-foreground" />
        </div>
        <div class="text-center">
          <p class="font-medium">No products yet</p>
          <p class="text-muted-foreground text-[13px] mt-1">Add products to link them to delivery orders</p>
        </div>
        <Button @click="openAdd"><Plus :size="14" /> Add product</Button>
      </div>

      <!-- Table -->
      <Card v-else>
        <div class="overflow-x-auto">
          <table class="w-full text-[13px]">
            <thead>
              <tr class="border-b border-border">
                <th class="px-4 py-2.5 text-left text-[11px] font-semibold text-muted-foreground/70 uppercase tracking-wider">Product</th>
                <th class="px-4 py-2.5 text-left text-[11px] font-semibold text-muted-foreground/70 uppercase tracking-wider">Size</th>
                <th class="px-4 py-2.5 text-right text-[11px] font-semibold text-muted-foreground/70 uppercase tracking-wider">Price</th>
                <th class="px-4 py-2.5 text-right text-[11px] font-semibold text-muted-foreground/70 uppercase tracking-wider">Stock</th>
                <th class="px-4 py-2.5 text-right text-[11px] font-semibold text-muted-foreground/70 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="p in store.products" :key="p.id"
                class="border-b border-border/50 last:border-0 hover:bg-muted/20 transition-colors">
                <td class="px-4 py-3 font-medium">{{ p.name }}</td>
                <td class="px-4 py-3">
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-[11.5px] font-semibold bg-muted text-muted-foreground">{{ p.size }}</span>
                </td>
                <td class="px-4 py-3 text-right font-medium">${{ p.price.toFixed(2) }}</td>
                <td class="px-4 py-3 text-right">
                  <span class="font-semibold text-[13px]"
                    :class="p.stock === 0 ? 'text-red-600' : p.stock <= 5 ? 'text-amber-600' : 'text-green-600'">
                    {{ p.stock }}
                  </span>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex gap-1 justify-end">
                    <Button variant="ghost" size="icon" class="h-8 w-8" @click="openEdit(p)"><Pencil :size="13" /></Button>
                    <Button variant="ghost" size="icon" class="h-8 w-8 text-destructive hover:text-destructive" @click="store.remove(p.id)"><Trash2 :size="13" /></Button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </Card>
    </div>

    <!-- Add / Edit drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="p-0 w-[400px] sm:max-w-[400px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="font-semibold text-[15px]">{{ editing ? 'Edit product' : 'New product' }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4">
            <div class="flex flex-col gap-1.5">
              <label class="text-sm font-medium">Product name</label>
              <input v-model="form.name" type="text" placeholder="e.g. Shirt"
                class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" />
            </div>
            <div class="flex flex-col gap-1.5">
              <label class="text-sm font-medium">Size</label>
              <input v-model="form.size" type="text" placeholder="e.g. XL"
                class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" />
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div class="flex flex-col gap-1.5">
                <label class="text-sm font-medium">Price ($)</label>
                <input v-model.number="form.price" type="number" min="0" step="0.5" placeholder="0.00"
                  class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" />
              </div>
              <div class="flex flex-col gap-1.5">
                <label class="text-sm font-medium">Stock</label>
                <input v-model.number="form.stock" type="number" min="0" placeholder="0"
                  class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" />
              </div>
            </div>
            <Button class="w-full mt-1" :disabled="!form.name.trim() || !form.size.trim()" @click="save">
              {{ editing ? 'Save changes' : 'Add product' }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Plus, Package, Pencil, Trash2, X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { useDeliveryProductStore, type DeliveryProduct } from '@/stores/deliveryProducts'
import { useUIStore } from '@/stores/ui'

const store = useDeliveryProductStore()
const ui    = useUIStore()

const drawerOpen = ref(false)
const editing    = ref<DeliveryProduct | null>(null)
const form       = reactive({ name: '', size: '', price: 0, stock: 0 })

function openAdd() {
  editing.value = null
  Object.assign(form, { name: '', size: '', price: 0, stock: 0 })
  drawerOpen.value = true
}

function openEdit(p: DeliveryProduct) {
  editing.value = p
  Object.assign(form, { name: p.name, size: p.size, price: p.price, stock: p.stock })
  drawerOpen.value = true
}

function save() {
  if (!form.name.trim() || !form.size.trim()) return
  if (editing.value) {
    store.update(editing.value.id, { name: form.name.trim(), size: form.size.trim(), price: form.price, stock: form.stock })
    ui.showToast('Product updated')
  } else {
    store.add({ name: form.name.trim(), size: form.size.trim(), price: form.price, stock: form.stock })
    ui.showToast('Product added')
  }
  drawerOpen.value = false
}
</script>
