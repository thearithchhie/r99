<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4 flex-wrap gap-3">
        <Tabs v-model="tab">
          <TabsList>
            <TabsTrigger v-for="t in TABS" :key="t" :value="t">{{ t }}</TabsTrigger>
          </TabsList>
        </Tabs>
        <Button variant="outline" size="sm"><Filter :size="14" /> Filter</Button>
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Order</TableHead>
              <TableHead>Customer</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Fulfilment</TableHead>
              <TableHead>Items</TableHead>
              <TableHead class="text-right">Total</TableHead>
              <TableHead>Date</TableHead>
              <TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="o in filtered" :key="o.id" class="cursor-pointer" @click="selectedOrder = o">
              <TableCell class="mono font-medium">{{ o.id }}</TableCell>
              <TableCell>
                <div class="flex items-center gap-2.5">
                  <UserAvatar :name="o.customer" :size="28" />
                  <div class="leading-tight">
                    <div>{{ o.customer }}</div>
                    <div class="text-muted-foreground text-[11.5px]">{{ o.city }}</div>
                  </div>
                </div>
              </TableCell>
              <TableCell><StatusBadge :status="o.status" /></TableCell>
              <TableCell class="text-muted-foreground">
                <span class="inline-flex items-center gap-1.5"><Truck :size="14" />{{ o.ship }}</span>
              </TableCell>
              <TableCell class="text-muted-foreground">{{ o.items.reduce((s, i) => s + i.qty, 0) }}</TableCell>
              <TableCell class="text-right font-medium">{{ money(o.total) }}</TableCell>
              <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(o.date) }}</TableCell>
              <TableCell><ChevronRight :size="15" class="text-muted-foreground" /></TableCell>
            </TableRow>
          </TableBody>
        </Table>
        <div v-if="filtered.length === 0" class="text-center text-muted-foreground py-12 text-[13.5px]">
          No orders match your filters.
        </div>
      </Card>
    </div>
    <OrderDrawer :order="selectedOrder" @close="selectedOrder = null" />
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Filter, Truck, ChevronRight } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import StatusBadge from '@/components/admin/StatusBadge.vue'
import UserAvatar from '@/components/admin/UserAvatar.vue'
import OrderDrawer from './partials/OrderDrawer.vue'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { ORDERS } from '@/data/orders'
import { money, fmtDate } from '@/utils/format'

const TABS = ['All', 'Processing', 'Shipped', 'Delivered', 'Refunded']
const tab = ref('All')
const selectedOrder = ref<typeof ORDERS[0] | null>(null)

const filtered = computed(() => {
  if (tab.value === 'All') return ORDERS
  return ORDERS.filter(o => o.status === tab.value)
})
</script>
