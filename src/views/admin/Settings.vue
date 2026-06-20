<template>
  <AdminLayout>
    <div class="fade flex min-h-[calc(100vh-60px)]">
      <!-- Left accordion sidebar -->
      <aside class="w-[220px] shrink-0 border-r border-border p-3">
        <div v-for="sec in SECTIONS" :key="sec.key">
          <button class="w-full flex justify-between items-center px-2.5 py-2 rounded-[7px] text-[13.5px] font-semibold hover:bg-muted/50 transition-colors"
            @click="toggleSection(sec.key)">
            <span>{{ sec.label }}</span>
            <ChevronDown :size="14" class="text-muted-foreground transition-transform duration-200"
              :style="{ transform: openSections[sec.key] ? 'rotate(180deg)' : 'rotate(0)' }" />
          </button>
          <Transition name="expand">
            <div v-if="openSections[sec.key]" class="pl-2 py-1">
              <button v-for="item in sec.items" :key="item.key"
                class="block w-full text-left px-3 py-1.5 rounded-[7px] text-[13px] font-medium text-muted-foreground hover:bg-muted/50 transition-colors"
                :class="activeItem === item.key ? 'text-foreground font-semibold bg-muted' : ''"
                @click="activeItem = item.key">{{ item.label }}</button>
            </div>
          </Transition>
        </div>
      </aside>

      <!-- Content -->
      <div class="flex-1 p-8 max-w-[600px]">
        <!-- General -->
        <template v-if="activeItem === 'general'">
          <h2 class="text-[18px] font-bold mb-6">General</h2>
          <div class="flex flex-col gap-4">
            <div class="flex flex-col gap-1.5"><Label>Store name</Label><Input v-model="store.name" /></div>
            <div class="flex flex-col gap-1.5"><Label>Support email</Label><Input v-model="store.email" type="email" /></div>
            <div class="flex flex-col gap-1.5">
              <Label>Currency</Label>
              <select class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" v-model="store.currency">
                <option value="USD">USD ($)</option><option value="EUR">EUR (€)</option><option value="GBP">GBP (£)</option>
              </select>
            </div>
            <Button size="sm" class="self-start" @click="saveStore">Save changes</Button>
          </div>
        </template>

        <!-- Shipping -->
        <template v-else-if="activeItem === 'shipping'">
          <h2 class="text-[18px] font-bold mb-6">Shipping & Tax</h2>
          <div class="flex flex-col gap-4">
            <div class="flex flex-col gap-1.5"><Label>Free shipping threshold ($)</Label><Input v-model.number="store.freeShippingThreshold" type="number" min="0" /></div>
            <div class="flex flex-col gap-1.5"><Label>Tax rate (%)</Label><Input v-model.number="store.taxRate" type="number" min="0" max="100" step="0.1" /></div>
            <Button size="sm" class="self-start" @click="saveStore">Save changes</Button>
          </div>
        </template>

        <!-- Feature flags -->
        <template v-else-if="activeItem === 'storefront' || activeItem === 'commerce' || activeItem === 'admin-ff'">
          <h2 class="text-[18px] font-bold mb-6">{{ sectionTitle }}</h2>
          <div class="flex flex-col divide-y divide-border">
            <div v-for="(flag, key) in filteredFlags" :key="key" class="flex items-center gap-4 py-3.5">
              <div class="flex-1">
                <div class="text-[14px] font-medium">{{ flag.label }}</div>
                <div class="text-muted-foreground text-[13px] mt-0.5">{{ flag.desc }}</div>
              </div>
              <Switch :model-value="flag.on" @update:model-value="flag.on = $event; persistFlags()" />
            </div>
          </div>
        </template>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ChevronDown } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Switch } from '@/components/ui/switch'
import { loadFlags, saveFlags } from '@/utils/features'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()

const SECTIONS = [
  { key: 'store', label: 'Store', items: [{ key: 'general', label: 'General' }, { key: 'shipping', label: 'Shipping & Tax' }] },
  { key: 'features', label: 'Features', items: [{ key: 'storefront', label: 'Storefront' }, { key: 'commerce', label: 'Commerce' }, { key: 'admin-ff', label: 'Admin' }] },
]

const FLAG_GROUPS: Record<string, string> = { storefront: 'Storefront', commerce: 'Commerce', 'admin-ff': 'Admin' }
const SECTION_TITLES: Record<string, string> = { storefront: 'Storefront features', commerce: 'Commerce features', 'admin-ff': 'Admin features' }

const openSections = reactive<Record<string, boolean>>({ store: true, features: true })
const activeItem = ref('general')
const flags = reactive(loadFlags())
const store = reactive({ name: 'R99 Studio', email: 'support@r99.studio', currency: 'USD', freeShippingThreshold: 150, taxRate: 8 })

function toggleSection(key: string) { openSections[key] = !openSections[key] }

const filteredFlags = computed(() => {
  const group = FLAG_GROUPS[activeItem.value]
  if (!group) return {}
  return Object.fromEntries(Object.entries(flags).filter(([, f]) => f.group === group))
})

const sectionTitle = computed(() => SECTION_TITLES[activeItem.value] ?? '')
function persistFlags() { saveFlags(flags) }
function saveStore() { ui.showToast('Settings saved') }
</script>

<style scoped>
.expand-enter-active, .expand-leave-active { transition: opacity 0.15s ease; }
.expand-enter-from, .expand-leave-to { opacity: 0; }
</style>
