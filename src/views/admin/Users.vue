<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">{{ SYSTEM_USERS.length }} users</p>
        <Button size="sm" @click="openNew"><Plus :size="14" /> New user</Button>
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead><TableHead>Email</TableHead><TableHead>Role</TableHead>
              <TableHead>Status</TableHead><TableHead>Last login</TableHead><TableHead />
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="u in SYSTEM_USERS" :key="u.id">
              <TableCell>
                <div class="flex items-center gap-2.5">
                  <UserAvatar :name="u.name" :size="32" />
                  <span class="font-medium">{{ u.name }}</span>
                </div>
              </TableCell>
              <TableCell class="text-muted-foreground">{{ u.email }}</TableCell>
              <TableCell>
                <span class="inline-flex items-center rounded-md px-2 py-0.5 text-xs font-semibold" :style="roleBadge(u.role)">{{ u.role }}</span>
              </TableCell>
              <TableCell>
                <span class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                  :style="u.status === 'Active' ? 'background: var(--green-bg); color: var(--green)' : 'background: var(--red-bg); color: var(--red)'">
                  <span class="status-dot" />{{ u.status }}
                </span>
              </TableCell>
              <TableCell class="text-muted-foreground text-[12.5px]">{{ u.lastLogin ? fmtDate(u.lastLogin) : 'Never' }}</TableCell>
              <TableCell>
                <div class="flex gap-1">
                  <Button variant="ghost" size="icon" class="h-8 w-8" @click="openEdit(u)"><Pencil :size="13" /></Button>
                  <Button variant="ghost" size="icon" class="h-8 w-8 text-destructive hover:text-destructive" @click="confirmDelete(u)"><Trash2 :size="13" /></Button>
                </div>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </Card>
    </div>

    <!-- User drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">{{ editingUser ? 'Edit user' : 'New user' }}</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false"><X :size="18" /></Button>
          </div>
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5"><Label>Full name</Label><Input v-model="form.name" placeholder="Jordan Lee" /></div>
            <div class="flex flex-col gap-1.5"><Label>Email</Label><Input v-model="form.email" type="email" placeholder="user@r99.studio" /></div>
            <div class="flex flex-col gap-1.5">
              <Label>Password</Label>
              <div class="relative">
                <Input v-model="form.password" :type="showPw ? 'text' : 'password'" placeholder="••••••••" class="pr-12" />
                <button class="absolute right-3 top-1/2 -translate-y-1/2 text-[12px] font-medium text-muted-foreground" @click="showPw = !showPw">{{ showPw ? 'Hide' : 'Show' }}</button>
              </div>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Role</Label>
              <select class="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring" v-model="form.role">
                <option>Owner</option><option>Manager</option><option>Staff</option><option>Viewer</option>
              </select>
            </div>

            <div>
              <div class="flex justify-between items-center mb-2">
                <Label>Page access</Label>
                <button class="text-[12px] text-muted-foreground hover:text-foreground transition-colors" @click="resetPerms">Reset to role defaults</button>
              </div>
              <div class="grid grid-cols-2 gap-1.5">
                <button v-for="(label, key) in PAGE_LABELS" :key="key"
                  class="px-2.5 py-1.5 rounded-[6px] border text-[12.5px] font-medium text-left transition-all"
                  :class="form.perms[key] ? 'bg-primary border-primary text-primary-foreground' : 'bg-card border-border text-muted-foreground hover:bg-muted'"
                  @click="form.perms[key] = !form.perms[key]">{{ label }}</button>
              </div>
            </div>

            <Button class="w-full mt-1" @click="saveUser">{{ editingUser ? 'Save changes' : 'Create user' }}</Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>

    <!-- Delete confirm -->
    <Dialog :open="!!deleteTarget" @update:open="(v) => !v && (deleteTarget = null)">
      <DialogContent class="max-w-md">
      <DialogHeader>
        <DialogTitle>Delete user?</DialogTitle>
        <DialogDescription>This will permanently remove <strong>{{ deleteTarget?.name }}</strong>. This action cannot be undone.</DialogDescription>
      </DialogHeader>
      <DialogFooter>
        <Button variant="outline" size="sm" @click="deleteTarget = null">Cancel</Button>
        <Button variant="destructive" size="sm" @click="doDelete">Delete</Button>
      </DialogFooter>
      </DialogContent>
    </Dialog>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { Plus, Pencil, Trash2, X } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import UserAvatar from '@/components/admin/UserAvatar.vue'
import { Card } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Sheet, SheetContent } from '@/components/ui/sheet'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from '@/components/ui/dialog'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import { SYSTEM_USERS } from '@/data/users'
import type { SystemUser, UserRole } from '@/data/users'
import { ROLE_NAV_PERMISSIONS } from '@/data/permissions'
import { fmtDate } from '@/utils/format'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()
const drawerOpen = ref(false)
const showPw = ref(false)
const editingUser = ref<SystemUser | null>(null)
const deleteTarget = ref<SystemUser | null>(null)

const PAGE_LABELS: Record<string, string> = {
  dashboard: 'Dashboard', orders: 'Orders', discounts: 'Discounts', customers: 'Customers',
  reports: 'Reports', products: 'Products', models: 'Models', stock: 'Stock',
  users: 'Users', roles: 'Roles', permissions: 'Permissions', activity: 'Activity', settings: 'Settings',
}

const form = reactive({
  name: '', email: '', password: '', role: 'Staff' as UserRole,
  perms: Object.fromEntries(Object.keys(PAGE_LABELS).map(k => [k, false])),
})

function roleBadge(role: UserRole) {
  const m: Record<UserRole, string> = {
    Owner: 'background: var(--violet-bg); color: var(--violet)',
    Manager: 'background: var(--blue-bg); color: var(--blue)',
    Staff: 'background: var(--amber-bg); color: var(--amber)',
    Viewer: 'background: hsl(var(--muted)); color: hsl(var(--muted-foreground))',
  }
  return m[role]
}

function resetPerms() {
  const defaults = ROLE_NAV_PERMISSIONS[form.role] ?? {}
  for (const k of Object.keys(form.perms)) form.perms[k] = defaults[k] ?? false
}

function openNew() { editingUser.value = null; showPw.value = false; Object.assign(form, { name:'',email:'',password:'',role:'Staff' }); resetPerms(); drawerOpen.value = true }
function openEdit(u: SystemUser) { editingUser.value = u; showPw.value = false; Object.assign(form, { name:u.name,email:u.email,password:u.password,role:u.role }); const d = ROLE_NAV_PERMISSIONS[u.role] ?? {}; for (const k of Object.keys(form.perms)) form.perms[k] = u.customPerms?.[k] ?? d[k] ?? false; drawerOpen.value = true }
function saveUser() { ui.showToast(editingUser.value ? 'User updated' : 'User created'); drawerOpen.value = false }
function confirmDelete(u: SystemUser) { deleteTarget.value = u }
function doDelete() { ui.showToast('User deleted'); deleteTarget.value = null }
</script>
