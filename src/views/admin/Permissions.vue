<template>
  <AdminLayout>
    <div class="fade p-5">
      <Card class="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead class="min-w-[200px]">Permission</TableHead>
              <TableHead v-for="role in ROLES" :key="role" class="text-center">
                <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="roleBadge(role)">{{ role }}</span>
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <template v-for="group in permGroupsWithPerms" :key="group.name">
              <TableRow class="bg-muted/40 hover:bg-muted/40">
                <TableCell colspan="5" class="text-[11px] font-bold uppercase tracking-widest text-muted-foreground py-2.5">{{ group.name }}</TableCell>
              </TableRow>
              <TableRow v-for="perm in group.perms" :key="perm.key">
                <TableCell class="text-[13.5px]">{{ perm.label }}</TableCell>
                <TableCell v-for="role in ROLES" :key="role" class="text-center">
                  <Check v-if="ROLE_PERMISSIONS[role][perm.key]" :size="16" class="text-green-600 mx-auto" />
                  <X v-else :size="16" class="text-border mx-auto" />
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Check, X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import { Card } from '@/components/ui/card'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { PERMISSIONS, ROLE_PERMISSIONS } from '@/data/permissions'
import type { UserRole } from '@/data/users'

const ROLES: UserRole[] = ['Owner', 'Manager', 'Staff', 'Viewer']
const permGroupsWithPerms = computed(() => {
  const groups = [...new Set(PERMISSIONS.map(p => p.group))]
  return groups.map(name => ({ name, perms: PERMISSIONS.filter(p => p.group === name) }))
})
function roleBadge(role: UserRole) {
  const m: Record<UserRole, string> = { Owner: 'background: var(--violet-bg); color: var(--violet)', Manager: 'background: var(--blue-bg); color: var(--blue)', Staff: 'background: var(--amber-bg); color: var(--amber)', Viewer: 'background: hsl(var(--muted)); color: hsl(var(--muted-foreground))' }
  return m[role]
}
</script>
