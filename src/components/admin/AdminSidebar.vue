<template>
  <aside class="hidden md:flex flex-col w-[244px] shrink-0 border-r border-border bg-sidebar sticky top-0 h-screen">
    <!-- Logo -->
    <div class="flex items-center gap-2.5 px-4 py-[18px]">
      <div class="w-8 h-8 rounded-lg bg-primary text-primary-foreground grid place-items-center font-bold text-[15px] tracking-tight shrink-0">R</div>
      <div class="leading-tight">
        <div class="font-semibold text-[14px] whitespace-nowrap">R99 Studio</div>
        <div class="text-muted-foreground text-[12px]">Commerce</div>
      </div>
    </div>

    <!-- Nav -->
    <nav class="flex flex-col gap-0.5 px-2.5 py-1.5 flex-1 overflow-y-auto">
      <template v-for="item in NAV_GROUPS" :key="item.key">
        <div v-if="canSee(item)">
          <!-- Group toggle -->
          <button
            v-if="item.children"
            class="flex items-center gap-2.5 w-full px-2.5 py-2 rounded-[7px] text-[13.5px] font-medium text-muted-foreground hover:bg-accent/50 transition-colors"
            :class="isGroupActive(item) ? 'text-foreground font-semibold bg-card shadow-sm' : ''"
            @click="toggleGroup(item.key)"
          >
            <span class="w-[26px] h-[26px] rounded-[6px] grid place-items-center shrink-0 transition-colors"
              :class="isGroupActive(item) ? 'bg-primary text-primary-foreground' : 'bg-transparent'">
              <component :is="item.icon" :size="15" />
            </span>
            <span class="flex-1 text-left" :class="isGroupActive(item) ? 'text-foreground' : ''">{{ item.label }}</span>
            <ChevronDown :size="14" class="text-muted-foreground transition-transform duration-200"
              :style="{ transform: openGroups[item.key] ? 'rotate(180deg)' : 'rotate(0)' }" />
          </button>

          <!-- Leaf link -->
          <RouterLink
            v-else
            :to="navPath(item.key)"
            class="flex items-center gap-2.5 w-full px-2.5 py-2 rounded-[7px] text-[13.5px] font-medium text-muted-foreground hover:bg-accent/50 transition-colors no-underline"
            :class="isActive(item.key) ? 'bg-card text-foreground font-semibold shadow-sm' : ''"
          >
            <span class="w-[26px] h-[26px] rounded-[6px] grid place-items-center shrink-0 transition-colors"
              :class="isActive(item.key) ? 'bg-primary text-primary-foreground' : ''">
              <component :is="item.icon" :size="15" />
            </span>
            <span class="flex-1">{{ item.label }}</span>
            <span v-if="item.badge" class="inline-flex items-center rounded-md bg-secondary text-secondary-foreground px-1.5 py-0.5 text-[11px] font-semibold h-[19px]">{{ item.badge }}</span>
          </RouterLink>

          <!-- Children -->
          <Transition name="expand">
            <div v-if="item.children && openGroups[item.key]" class="overflow-hidden">
              <template v-for="child in item.children" :key="child.key">
                <RouterLink
                  v-if="navPerms[child.key] !== false"
                  :to="navPath(child.key)"
                  class="flex items-center gap-2.5 w-full pl-9 pr-2.5 py-[7px] rounded-[7px] text-[13px] font-medium text-muted-foreground hover:bg-accent/50 transition-colors no-underline"
                  :class="isActive(child.key) ? 'text-foreground font-semibold' : ''"
                >
                  <span class="w-1.5 h-1.5 rounded-full shrink-0 ml-0.5 transition-colors"
                    :class="isActive(child.key) ? 'bg-primary' : 'bg-muted-foreground'" />
                  {{ child.label }}
                </RouterLink>
              </template>
            </div>
          </Transition>
        </div>
      </template>
    </nav>

    <!-- Footer -->
    <div class="p-3 border-t border-border shrink-0">
      <div class="flex items-center gap-2 px-1.5 py-2">
        <UserAvatar :name="session.user!.name" :size="30" />
        <div class="leading-tight flex-1 min-w-0">
          <div class="text-[13px] font-semibold whitespace-nowrap overflow-hidden text-ellipsis">{{ session.user!.name }}</div>
          <div class="text-muted-foreground text-[11.5px]">{{ session.user!.role }}</div>
        </div>
        <Button variant="ghost" size="icon" class="h-8 w-8" title="Sign out" @click="handleLogout">
          <LogOut :size="15" />
        </Button>
      </div>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  LayoutDashboard, ShoppingBag, Tag, Users, BarChart2, Package,
  Shield, Clock, Settings, ChevronDown, LogOut,
} from '@lucide/vue'
import { Button } from '@/components/ui/button'
import { useSessionStore } from '@/stores/session'
import { ROLE_NAV_PERMISSIONS } from '@/data/permissions'
import UserAvatar from './UserAvatar.vue'

const route = useRoute()
const router = useRouter()
const session = useSessionStore()

const navPerms = computed(() => {
  const role = session.user?.role ?? 'Viewer'
  return session.user?.customPerms ?? ROLE_NAV_PERMISSIONS[role] ?? {}
})

const NAV_GROUPS = [
  { key: 'dashboard',   label: 'Dashboard',        icon: LayoutDashboard },
  { key: 'orders',      label: 'Orders',           icon: ShoppingBag, badge: 3 },
  { key: 'promotional', label: 'Promotional Deals',icon: Tag, children: [{ key: 'discounts', label: 'Discounts' }] },
  { key: 'customers',   label: 'Customers',        icon: Users },
  { key: 'reports',     label: 'Reports',          icon: BarChart2 },
  { key: 'catalogue',   label: 'Catalogue',        icon: Package, children: [
    { key: 'products', label: 'Products' },
    { key: 'models', label: 'Models' },
    { key: 'stock', label: 'Stock' },
  ]},
  { key: 'team',        label: 'User Management',  icon: Shield, children: [
    { key: 'users', label: 'Users' },
    { key: 'roles', label: 'Roles' },
    { key: 'permissions', label: 'Permissions' },
  ]},
  { key: 'activity',    label: 'Activity',         icon: Clock, children: [
    { key: 'act-users', label: 'Users' },
    { key: 'act-orders', label: 'Orders' },
    { key: 'act-products', label: 'Products' },
    { key: 'act-stock', label: 'Stocks' },
    { key: 'act-log', label: 'Log' },
    { key: 'act-discounts', label: 'Discounts' },
  ]},
  { key: 'settings',    label: 'Settings',         icon: Settings },
]

const NAV_PATH_MAP: Record<string, string> = {
  dashboard: '/admin', orders: '/admin/orders', discounts: '/admin/discounts',
  customers: '/admin/customers', reports: '/admin/reports', products: '/admin/products',
  models: '/admin/models', stock: '/admin/stock', users: '/admin/users',
  roles: '/admin/roles', permissions: '/admin/permissions',
  'act-users': '/admin/activity/users', 'act-orders': '/admin/activity/orders',
  'act-products': '/admin/activity/products', 'act-stock': '/admin/activity/stock',
  'act-log': '/admin/activity/log', 'act-discounts': '/admin/activity/discounts',
  settings: '/admin/settings',
}

function navPath(key: string): string { return NAV_PATH_MAP[key] ?? '/admin' }

function currentKey(): string {
  const path = route.path
  if (path === '/admin') return 'dashboard'
  const entries = Object.entries(NAV_PATH_MAP).sort((a, b) => b[1].length - a[1].length)
  for (const [key, p] of entries) { if (path.startsWith(p)) return key }
  return 'dashboard'
}

function isActive(key: string) { return currentKey() === key }
function isGroupActive(item: typeof NAV_GROUPS[0]) {
  return !!(item.children?.some(c => isActive(c.key)))
}
function canSee(item: typeof NAV_GROUPS[0]) {
  return item.children
    ? item.children.some(c => navPerms.value[c.key] !== false)
    : navPerms.value[item.key] !== false
}

const openGroups = ref<Record<string, boolean>>({})
function autoOpen() {
  const key = currentKey()
  for (const g of NAV_GROUPS) {
    if (g.children?.some(c => c.key === key)) openGroups.value[g.key] = true
  }
}
autoOpen()
watch(() => route.path, autoOpen)
function toggleGroup(key: string) { openGroups.value[key] = !openGroups.value[key] }

async function handleLogout() {
  session.logout()
  await router.push('/admin/login')
}
</script>

<style scoped>
.expand-enter-active, .expand-leave-active { transition: opacity 0.15s ease; }
.expand-enter-from, .expand-leave-to { opacity: 0; }
</style>
