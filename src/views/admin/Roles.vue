<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="grid grid-cols-[repeat(auto-fill,minmax(260px,1fr))] gap-4 mb-6">
        <Card v-for="role in ROLES" :key="role" class="cursor-pointer transition-all hover:shadow-md"
          :class="selectedRole === role ? 'ring-2 ring-primary' : ''" @click="selectedRole = role">
          <CardHeader>
            <div class="flex justify-between items-start">
              <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="roleBadge(role)">{{ role }}</span>
              <span class="text-muted-foreground text-[12px]">{{ permCount(role) }} permissions</span>
            </div>
          </CardHeader>
          <CardContent>
            <p class="text-muted-foreground text-[13px] leading-relaxed mb-4">{{ ROLE_DESCRIPTIONS[role] }}</p>
            <div class="flex flex-col gap-1.5">
              <div v-for="group in permGroups" :key="group">
                <div class="flex justify-between text-[11.5px] mb-1">
                  <span class="text-muted-foreground">{{ group }}</span>
                  <span class="text-muted-foreground">{{ groupPercent(role, group) }}%</span>
                </div>
                <div class="h-1 rounded-full bg-border">
                  <div class="h-full rounded-full" :class="role === 'Owner' ? 'bg-primary' : 'bg-blue-500'" :style="{ width: groupPercent(role, group) + '%' }" />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>

    <Sheet :open="!!selectedRole" @update:open="(v) => !v && (selectedRole = null)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div v-if="selectedRole" class="flex flex-col h-full">
          <div class="flex items-start justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <div>
              <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="roleBadge(selectedRole)">{{ selectedRole }}</span>
              <div class="font-semibold text-[15px] mt-1">Edit permissions</div>
            </div>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="selectedRole = null"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-5 flex-1 overflow-y-auto">
            <div v-if="selectedRole === 'Owner'" class="text-muted-foreground text-[13px] rounded-lg bg-muted p-3">
              Owner permissions cannot be modified.
            </div>
            <template v-else>
              <div v-for="group in permGroupsWithPerms" :key="group.name">
                <div class="flex items-center gap-2 mb-2">
                  <input type="checkbox" :ref="(el) => setGroupRef(group.name, el as HTMLInputElement)"
                    :checked="groupAllChecked(group.perms)"
                    @change="toggleGroup(group.perms, ($event.target as HTMLInputElement).checked)" />
                  <span class="text-[12px] font-semibold uppercase tracking-widest text-muted-foreground">{{ group.name }}</span>
                </div>
                <div class="flex flex-col gap-1.5 pl-2">
                  <label v-for="perm in group.perms" :key="perm.key" class="flex items-center gap-2.5 cursor-pointer text-[13.5px]">
                    <input type="checkbox" v-model="localPerms[perm.key]" @change="updateIndeterminate()" />
                    {{ perm.label }}
                  </label>
                </div>
              </div>
              <Button class="w-full" @click="savePerms">Save permissions</Button>
            </template>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, computed, reactive, watch, nextTick } from 'vue'
import { X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Card, CardHeader, CardContent } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { PERMISSIONS, ROLE_PERMISSIONS, ROLE_DESCRIPTIONS } from '@/data/permissions'
import type { UserRole } from '@/data/users'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()
const ROLES: UserRole[] = ['Owner', 'Manager', 'Staff', 'Viewer']
const selectedRole = ref<UserRole | null>(null)
const localPerms = reactive<Record<string, boolean>>({})
const groupRefs = reactive<Record<string, HTMLInputElement | null>>({})
function setGroupRef(name: string, el: HTMLInputElement | null) { groupRefs[name] = el }

watch(selectedRole, (role) => {
  if (!role) return
  for (const p of PERMISSIONS) localPerms[p.key] = ROLE_PERMISSIONS[role][p.key] ?? false
})

const permGroups = computed(() => [...new Set(PERMISSIONS.map(p => p.group))])
const permGroupsWithPerms = computed(() => permGroups.value.map(name => ({ name, perms: PERMISSIONS.filter(p => p.group === name) })))

function groupAllChecked(perms: typeof PERMISSIONS) { return perms.every(p => localPerms[p.key]) }
function toggleGroup(perms: typeof PERMISSIONS, checked: boolean) { for (const p of perms) localPerms[p.key] = checked; updateIndeterminate() }
function updateIndeterminate() {
  nextTick(() => {
    for (const g of permGroupsWithPerms.value) {
      const el = groupRefs[g.name]; if (!el) continue
      const all = g.perms.every(p => localPerms[p.key])
      const none = g.perms.every(p => !localPerms[p.key])
      el.indeterminate = !all && !none
    }
  })
}
function permCount(role: UserRole) { return Object.values(ROLE_PERMISSIONS[role]).filter(Boolean).length }
function groupPercent(role: UserRole, group: string) {
  const perms = PERMISSIONS.filter(p => p.group === group)
  return Math.round(perms.filter(p => ROLE_PERMISSIONS[role][p.key]).length / perms.length * 100)
}
function roleBadge(role: UserRole) {
  const m: Record<UserRole, string> = { Owner: 'background: var(--violet-bg); color: var(--violet)', Manager: 'background: var(--blue-bg); color: var(--blue)', Staff: 'background: var(--amber-bg); color: var(--amber)', Viewer: 'background: hsl(var(--muted)); color: hsl(var(--muted-foreground))' }
  return m[role]
}
function savePerms() { ui.showToast('Permissions saved'); selectedRole.value = null }
</script>
