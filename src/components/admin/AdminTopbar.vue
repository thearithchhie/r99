<template>
  <header class="flex items-center gap-4 h-[60px] border-b border-border px-5 sticky top-0 bg-background/80 backdrop-blur-sm z-20 shrink-0">
    <Button variant="ghost" size="icon" class="md:hidden" aria-label="Menu" @click="ui.openSidebar()">
      <Menu :size="20" />
    </Button>
    <h1 class="text-[16px] font-semibold">{{ title }}</h1>
    <div class="flex-1" />
    <div class="relative w-[min(280px,32vw)] hidden md:block">
      <Search :size="15" class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none" />
      <Input v-model="searchModel" class="pl-8 h-8 text-sm" placeholder="Search orders, products…" />
    </div>
    <ModeToggle />
    <Button variant="outline" size="icon" class="relative h-8 w-8" aria-label="Notifications">
      <Bell :size="16" />
      <span class="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full bg-destructive border border-card" />
    </Button>
    <slot name="actions" />
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { Menu, Search, Bell } from '@lucide/vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { useUIStore } from '@/stores/ui'
import ModeToggle from '@/components/admin/ModeToggle.vue'

const props = defineProps<{ search?: string }>()
const emit = defineEmits<{ 'update:search': [v: string] }>()
const ui = useUIStore()
const route = useRoute()

const searchModel = computed({
  get: () => props.search ?? '',
  set: (v) => emit('update:search', v),
})

const TITLES: Record<string, string> = {
  '/admin': 'Dashboard', '/admin/orders': 'Orders', '/admin/discounts': 'Discounts',
  '/admin/customers': 'Customers', '/admin/reports': 'Reports', '/admin/products': 'Products',
  '/admin/models': 'Models', '/admin/stock': 'Stock', '/admin/users': 'Users',
  '/admin/roles': 'Roles', '/admin/permissions': 'Permissions',
  '/admin/settings': 'Settings', '/admin/payroll': 'Payroll',
}

const title = computed(() => {
  const path = route.path
  if (path.startsWith('/admin/activity')) {
    const type = route.params.type as string
    const map: Record<string, string> = {
      users: 'Activity · Users', orders: 'Activity · Orders', products: 'Activity · Products',
      stock: 'Activity · Stocks', log: 'Activity · Log', discounts: 'Activity · Discounts',
    }
    return map[type] ?? 'Activity'
  }
  if (path.startsWith('/admin/settings')) return 'Settings'
  return TITLES[path] ?? 'Admin'
})
</script>
