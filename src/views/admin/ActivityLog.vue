<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex gap-3 mb-4 flex-wrap items-center">
        <Tabs v-model="typeFilter">
          <TabsList>
            <TabsTrigger v-for="type in TYPE_FILTERS" :key="type.value" :value="type.value">{{ type.label }}</TabsTrigger>
          </TabsList>
        </Tabs>
        <div class="flex-1" />
        <div class="relative w-60">
          <Search :size="14" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
          <Input v-model="query" class="pl-8 h-8" placeholder="Search…" />
        </div>
      </div>

      <div class="flex flex-col gap-5">
        <div v-for="(entries, date) in grouped" :key="date">
          <div class="text-[12px] font-semibold text-muted-foreground uppercase tracking-widest mb-2.5">{{ date }}</div>
          <Card>
            <div v-for="(entry, i) in entries" :key="entry.id"
              class="flex items-start gap-3 px-4 py-3"
              :class="i < entries.length - 1 ? 'border-b border-border' : ''">
              <UserAvatar :name="entry.user" :size="30" class="mt-0.5 shrink-0" />
              <div class="flex-1 min-w-0">
                <div class="text-[13.5px]">
                  <strong>{{ entry.user }}</strong>
                  <span class="text-muted-foreground"> {{ entry.text }}</span>
                </div>
                <div class="flex items-center gap-2 mt-1">
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-[11px] font-semibold" :style="typeBadge(entry.type)">{{ entry.type }}</span>
                  <span class="text-muted-foreground text-[11.5px]">{{ timeAgo(entry.time) }}</span>
                  <span class="text-muted-foreground text-[11.5px]">· {{ fmtDate(entry.time) }}</span>
                </div>
              </div>
            </div>
          </Card>
        </div>
        <div v-if="filtered.length === 0" class="text-center text-muted-foreground py-12 text-[13.5px]">No activity matches your filters.</div>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { Search } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import UserAvatar from '@/components/admin/UserAvatar.vue'
import { Card } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { ACTIVITY_LOG } from '@/data/permissions'
import { fmtDate, fmtDateShort, timeAgo } from '@/utils/format'

const route = useRoute()
const typeFilter = ref((route.params.type as string) || 'all')
const query = ref('')

const TYPE_FILTERS = [
  { value: 'all', label: 'All' }, { value: 'order', label: 'Orders' }, { value: 'product', label: 'Products' },
  { value: 'stock', label: 'Stock' }, { value: 'user', label: 'Users' }, { value: 'login', label: 'Login' }, { value: 'discount', label: 'Discounts' },
]

const ROUTE_TYPE_MAP: Record<string, string> = { users: 'user', orders: 'order', products: 'product', stock: 'stock', log: 'all', discounts: 'discount' }

const filtered = computed(() => {
  const routeType = ROUTE_TYPE_MAP[route.params.type as string]
  const type = routeType || typeFilter.value
  let r = ACTIVITY_LOG
  if (type && type !== 'all') r = r.filter(e => e.type === type)
  const q = query.value.toLowerCase()
  if (q) r = r.filter(e => e.user.toLowerCase().includes(q) || e.text.toLowerCase().includes(q))
  return r
})

const grouped = computed(() => {
  const groups: Record<string, typeof ACTIVITY_LOG> = {}
  for (const entry of filtered.value) {
    const key = isToday(entry.time) ? 'Today' : isYesterday(entry.time) ? 'Yesterday' : fmtDateShort(entry.time)
    if (!groups[key]) groups[key] = []
    groups[key].push(entry)
  }
  return groups
})

function isToday(d: Date) { const n = new Date(); return d.getDate() === n.getDate() && d.getMonth() === n.getMonth() && d.getFullYear() === n.getFullYear() }
function isYesterday(d: Date) { const n = new Date(); n.setDate(n.getDate() - 1); return d.getDate() === n.getDate() && d.getMonth() === n.getMonth() && d.getFullYear() === n.getFullYear() }

function typeBadge(type: string) {
  const m: Record<string, string> = { order: 'background: var(--blue-bg); color: var(--blue)', product: 'background: var(--violet-bg); color: var(--violet)', stock: 'background: var(--amber-bg); color: var(--amber)', user: 'background: var(--green-bg); color: var(--green)', login: 'background: hsl(var(--muted)); color: hsl(var(--muted-foreground))', discount: 'background: var(--red-bg); color: var(--red)' }
  return m[type] ?? 'background: hsl(var(--muted)); color: hsl(var(--muted-foreground))'
}
</script>
