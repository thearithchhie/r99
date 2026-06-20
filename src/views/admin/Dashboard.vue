<template>
  <AdminLayout>
    <div class="fade p-5 flex flex-col gap-4">
      <!-- KPI cards -->
      <div class="kpi-grid grid grid-cols-4 gap-4">
        <Card v-for="k in KPIS" :key="k.key">
          <CardContent class="pt-5">
            <div class="flex justify-between items-center mb-2.5">
              <span class="text-muted-foreground text-[13px] font-medium">{{ k.label }}</span>
              <component :is="iconMap[k.icon]" :size="16" class="text-muted-foreground" />
            </div>
            <div class="text-[26px] font-semibold tracking-tight">{{ k.value }}</div>
            <div class="flex items-center gap-1.5 mt-2 text-[12.5px]">
              <span class="inline-flex items-center gap-0.5 font-semibold" :class="k.up ? 'text-green-600' : 'text-red-600'">
                <TrendingUp v-if="k.up" :size="13" /><TrendingDown v-else :size="13" />{{ k.delta }}%
              </span>
              <span class="text-muted-foreground">{{ k.sub }}</span>
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Revenue + Low stock -->
      <div class="dash-2col grid gap-4" style="grid-template-columns: 1.7fr 1fr">
        <Card>
          <CardHeader>
            <div class="flex justify-between items-start">
              <div>
                <CardTitle>Revenue</CardTitle>
                <CardDescription class="mt-0.5">Last 12 weeks</CardDescription>
              </div>
              <span class="inline-flex items-center rounded-md border px-2 py-0.5 text-xs font-semibold text-muted-foreground">Weekly</span>
            </div>
          </CardHeader>
          <CardContent>
            <div class="flex items-end gap-[2.4%] h-40">
              <div v-for="(v, i) in REVENUE_SERIES" :key="i"
                class="flex flex-col items-center gap-1.5 h-full justify-end flex-1">
                <div :title="'$' + v + 'k'"
                  class="w-full rounded-t-sm transition-colors duration-150 cursor-pointer"
                  :class="i === REVENUE_SERIES.length - 1 ? 'bg-primary' : 'bg-muted hover:bg-muted-foreground/40'"
                  :style="{ height: (v / maxRevenue * 100) + '%', minHeight: '6px' }" />
                <span class="text-muted-foreground text-[10.5px]">W{{ i + 1 }}</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Low stock</CardTitle>
            <CardDescription>Needs reordering soon</CardDescription>
          </CardHeader>
          <CardContent>
            <div class="flex flex-col gap-3">
              <div v-for="p in lowStock" :key="p.id" class="flex items-center gap-2.5">
                <PlaceholderThumb :tone="p.tone" :size="36" />
                <div class="flex-1 min-w-0">
                  <div class="text-[13px] font-medium truncate">{{ p.name }}</div>
                  <div class="text-muted-foreground mono text-[11.5px]">{{ p.sku }}</div>
                </div>
                <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold"
                  style="background: var(--amber-bg); color: var(--amber)">{{ p.stock }} left</span>
              </div>
              <RouterLink to="/admin/products" class="inline-flex items-center gap-1 text-[13px] text-muted-foreground hover:text-foreground transition-colors mt-1">
                View all products <ChevronRight :size="14" />
              </RouterLink>
            </div>
          </CardContent>
        </Card>
      </div>

      <!-- Recent orders -->
      <Card>
        <CardHeader>
          <div class="flex justify-between items-center">
            <div>
              <CardTitle>Recent orders</CardTitle>
              <CardDescription>Latest activity across the store</CardDescription>
            </div>
            <RouterLink to="/admin/orders">
              <Button variant="outline" size="sm">View all</Button>
            </RouterLink>
          </div>
        </CardHeader>
        <CardContent class="pt-0 px-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Order</TableHead>
                <TableHead>Customer</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Items</TableHead>
                <TableHead class="text-right">Total</TableHead>
                <TableHead>Date</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="o in recentOrders" :key="o.id" class="cursor-pointer" @click="selectedOrder = o">
                <TableCell class="mono font-medium">{{ o.id }}</TableCell>
                <TableCell>
                  <div class="flex items-center gap-2.5">
                    <UserAvatar :name="o.customer" :size="28" />{{ o.customer }}
                  </div>
                </TableCell>
                <TableCell><StatusBadge :status="o.status" /></TableCell>
                <TableCell class="text-muted-foreground">{{ o.items.reduce((s, i) => s + i.qty, 0) }}</TableCell>
                <TableCell class="text-right font-medium">{{ money(o.total) }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(o.date) }}</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
    <OrderDrawer :order="selectedOrder" @close="selectedOrder = null" />
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { TrendingUp, TrendingDown, ChevronRight, DollarSign, ShoppingCart, Percent } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import StatusBadge from '@/components/admin/StatusBadge.vue'
import UserAvatar from '@/components/admin/UserAvatar.vue'
import PlaceholderThumb from '@/components/admin/PlaceholderThumb.vue'
import OrderDrawer from './partials/OrderDrawer.vue'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { ORDERS, REVENUE_SERIES, KPIS } from '@/data/orders'
import { PRODUCTS } from '@/data/products'
import { money, fmtDate } from '@/utils/format'

const iconMap: Record<string, unknown> = { DollarSign, ShoppingCart, TrendingUp, Percent }
const maxRevenue = Math.max(...REVENUE_SERIES)
const recentOrders = ORDERS.slice(0, 6)
const lowStock = computed(() => PRODUCTS.filter(p => p.stock > 0 && p.stock <= 10))
const selectedOrder = ref<typeof ORDERS[0] | null>(null)
</script>
