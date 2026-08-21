<template>
  <header
    class="flex items-center gap-4 h-[60px] border-b border-border px-5 sticky top-0 bg-background/80 backdrop-blur-sm z-20 shrink-0"
  >
    <Button
      variant="ghost"
      size="icon"
      class="md:hidden"
      aria-label="Menu"
      @click="ui.openSidebar()"
    >
      <Menu :size="20" />
    </Button>
    <h1 class="text-[16px] font-semibold">{{ title }}</h1>
    <div class="flex-1" />
    <div class="relative w-[min(280px,32vw)] hidden md:block">
      <Search
        :size="15"
        class="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted-foreground pointer-events-none"
      />
      <Input
        v-model="searchModel"
        class="pl-8 h-8 text-sm"
        placeholder="Search orders, products…"
      />
    </div>
    <ModeToggle />
    <Button
      variant="outline"
      size="icon"
      class="relative h-8 w-8"
      aria-label="Notifications"
    >
      <Bell :size="16" />
      <span
        class="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full bg-destructive border border-card"
      />
    </Button>
    <slot name="actions" />
  </header>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { Menu, Search, Bell } from "@lucide/vue";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useUIStore } from "@/stores/ui";
import { ADMIN_ROUTES } from "@/router/admin-routes";
import ModeToggle from "@/components/admin/ModeToggle.vue";

const props = defineProps<{ search?: string }>();
const emit = defineEmits<{ "update:search": [v: string] }>();
const ui = useUIStore();
const route = useRoute();

const searchModel = computed({
  get: () => props.search ?? "",
  set: (v) => emit("update:search", v),
});

const R = ADMIN_ROUTES
const TITLES: Record<string, string> = {
  [R.dashboard]:   "Dashboard",
  [R.orders]:      "Orders",
  [R.discounts]:   "Discounts",
  [R.customers]:   "Customers",
  [R.reports]:     "Reports",
  [R.products.list]:    "Products",
  [R.models]:      "Models",
  [R.stock]:       "Stock",
  [R.users.list]:  "Users",
  [R.roles.list]:  "Roles",
  [R.permissions]: "Permissions",
  [R.auditLogs]:   "Activity",
  [R.payroll]:     "Payroll",
  [R.deliveries]:  "Deliveries",
  [R.drivers]:     "Drivers",
  [R.settings]:    "Settings",
};

const title = computed(() => {
  const path = route.path;
  if (path.startsWith(R.settings)) return "Settings";
  if (path.startsWith(R.users.list)) return "Users";
  if (path.startsWith(R.roles.list)) return "Roles";
  return TITLES[path] ?? "Admin";
});
</script>
