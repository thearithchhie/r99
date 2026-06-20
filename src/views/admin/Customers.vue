<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="relative max-w-xs mb-4">
        <Search :size="15" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
        <Input v-model="query" class="pl-8" placeholder="Search customers…" />
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Email</TableHead>
              <TableHead>Orders</TableHead>
              <TableHead>Total spent</TableHead>
              <TableHead>Last order</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="c in filtered" :key="c.id" class="cursor-pointer" @click="selected = c">
              <TableCell>
                <div class="flex items-center gap-2.5">
                  <UserAvatar :name="c.name" :size="30" />
                  <span class="font-medium">{{ c.name }}</span>
                </div>
              </TableCell>
              <TableCell class="text-muted-foreground">{{ c.email }}</TableCell>
              <TableCell>{{ c.orders }}</TableCell>
              <TableCell class="font-medium">{{ money(c.spent) }}</TableCell>
              <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDateShort(c.lastOrder) }}</TableCell>
              <TableCell>
                <span class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                  :style="c.status === 'Active' ? 'background: var(--green-bg); color: var(--green)' : 'background: var(--red-bg); color: var(--red)'">
                  <span class="status-dot" />{{ c.status }}
                </span>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
        <div v-if="filtered.length === 0" class="text-center text-muted-foreground py-12 text-[13.5px]">No customers found.</div>
      </Card>
    </div>

    <Sheet :open="!!selected" @update:open="(v) => !v && (selected = null)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div v-if="selected" class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">Customer detail</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="selected = null"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-5">
            <div class="flex items-center gap-3.5">
              <UserAvatar :name="selected.name" :size="48" />
              <div>
                <div class="text-[17px] font-semibold">{{ selected.name }}</div>
                <div class="text-muted-foreground text-[13px]">{{ selected.email }}</div>
              </div>
            </div>
            <div class="grid grid-cols-2 gap-3">
              <div class="rounded-lg bg-muted p-3">
                <div class="text-muted-foreground text-[12px]">Orders</div>
                <div class="text-[20px] font-semibold mt-1">{{ selected.orders }}</div>
              </div>
              <div class="rounded-lg bg-muted p-3">
                <div class="text-muted-foreground text-[12px]">Total spent</div>
                <div class="text-[20px] font-semibold mt-1">{{ money(selected.spent) }}</div>
              </div>
            </div>
            <div>
              <div class="text-muted-foreground text-[12px] mb-1">Last order</div>
              <div>{{ fmtDateShort(selected.lastOrder) }}</div>
            </div>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { Search, X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import UserAvatar from '@/components/admin/UserAvatar.vue'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { CUSTOMERS } from '@/data/users'
import { money, fmtDateShort } from '@/utils/format'

const query = ref('')
const selected = ref<typeof CUSTOMERS[0] | null>(null)

const filtered = computed(() => {
  const q = query.value.toLowerCase()
  if (!q) return CUSTOMERS
  return CUSTOMERS.filter(c => c.name.toLowerCase().includes(q) || c.email.toLowerCase().includes(q))
})
</script>
