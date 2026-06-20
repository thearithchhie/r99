<template>
  <AdminLayout>
    <div class="fade p-5 flex flex-col gap-4">
      <div class="kpi-grid grid grid-cols-4 gap-4">
        <Card v-for="k in kpiCards" :key="k.label">
          <CardContent class="pt-5">
            <div class="text-muted-foreground text-[12.5px] mb-1.5">{{ k.label }}</div>
            <div class="text-2xl font-semibold">{{ k.value }}</div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div class="flex justify-between items-start">
            <div><CardTitle>Revenue over time</CardTitle><CardDescription class="mt-0.5">Last 12 weeks</CardDescription></div>
            <div class="flex gap-2 items-center">
              <select class="flex h-8 rounded-md border border-input bg-transparent px-2 py-1 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring">
                <option>This week</option><option selected>This month</option><option>This year</option>
              </select>
              <Button variant="outline" size="sm"><Download :size="13" /> Export CSV</Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div class="flex items-end gap-[2.4%] h-48">
            <div v-for="(v, i) in REVENUE_SERIES" :key="i" class="flex flex-col items-center gap-1.5 h-full justify-end flex-1">
              <div :title="'$' + v + 'k'"
                class="w-full rounded-t-sm min-h-[6px] cursor-pointer transition-colors"
                :class="i === REVENUE_SERIES.length - 1 ? 'bg-primary' : 'bg-muted hover:bg-muted-foreground/40'"
                :style="{ height: (v / maxRevenue * 100) + '%' }" />
              <span class="text-muted-foreground text-[10.5px]">W{{ i + 1 }}</span>
            </div>
          </div>
        </CardContent>
      </Card>

      <div class="dash-2col grid gap-4" style="grid-template-columns: 1.4fr 1fr">
        <Card>
          <CardHeader><CardTitle>Best sellers</CardTitle></CardHeader>
          <CardContent>
            <div class="flex flex-col gap-3.5">
              <div v-for="(p, i) in bestSellers" :key="p.id" class="flex items-center gap-3">
                <span class="text-muted-foreground text-[12px] font-semibold w-4 text-right shrink-0">{{ i + 1 }}</span>
                <PlaceholderThumb :tone="p.tone" :size="36" />
                <div class="flex-1 min-w-0">
                  <div class="text-[13px] font-medium truncate">{{ p.name }}</div>
                  <div class="mt-1 h-1 rounded-full bg-border"><div class="h-full rounded-full bg-primary" :style="{ width: (p.stock / 240 * 100) + '%' }" /></div>
                </div>
                <div class="text-right shrink-0">
                  <div class="text-[13px] font-semibold">${{ (p.price * Math.floor(p.stock * 0.7)).toLocaleString() }}</div>
                  <div class="text-muted-foreground text-[11.5px]">{{ Math.floor(p.stock * 0.7) }} sold</div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>By category</CardTitle></CardHeader>
          <CardContent>
            <div class="flex flex-col gap-3.5">
              <div v-for="cat in categories" :key="cat.name">
                <div class="flex justify-between text-[13px] mb-1"><span class="font-medium">{{ cat.name }}</span><span class="text-muted-foreground">{{ cat.pct }}%</span></div>
                <div class="h-1.5 rounded-full bg-border"><div class="h-full rounded-full bg-primary transition-all duration-500" :style="{ width: cat.pct + '%' }" /></div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Download } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import PlaceholderThumb from '@/components/admin/PlaceholderThumb.vue'
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { PRODUCTS } from '@/data/products'
import { REVENUE_SERIES } from '@/data/orders'

const maxRevenue = Math.max(...REVENUE_SERIES)
const kpiCards = [{ label: 'Revenue', value: '$84,219' }, { label: 'Orders', value: '1,284' }, { label: 'Avg order value', value: '$172' }, { label: 'Top category', value: 'Women' }]
const bestSellers = computed(() => [...PRODUCTS].sort((a, b) => b.price - a.price).slice(0, 5))
const categories = computed(() => {
  const total = PRODUCTS.reduce((s, p) => s + p.stock, 0)
  const grouped = PRODUCTS.reduce<Record<string, number>>((acc, p) => { acc[p.cat] = (acc[p.cat] ?? 0) + p.stock; return acc }, {})
  return Object.entries(grouped).map(([name, stock]) => ({ name, pct: Math.round(stock / total * 100) })).sort((a, b) => b.pct - a.pct)
})
</script>
