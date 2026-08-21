<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ store.meta ? store.meta.total + " users" : "" }}
        </p>
        <Button size="sm" @click="openNew"><Plus :size="14" /> New user</Button>
      </div>

      <!-- Error state -->
      <div
        v-if="store.error"
        class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4"
      >
        <AlertTriangle :size="14" class="shrink-0" />{{ store.error }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Phone</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Created at</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-if="store.loading" v-for="n in 5" :key="'skel-' + n">
              <TableCell colspan="5">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <template v-if="!store.loading">
              <TableRow
                v-for="u in store.users"
                :key="u.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="goToDetail(u.uuid)"
              >
                <TableCell>
                  <div class="flex items-center gap-2.5">
                    <UserAvatar :name="u.name" :size="32" />
                    <span class="font-medium">{{ u.name }}</span>
                  </div>
                </TableCell>
                <TableCell class="text-muted-foreground">{{ u.phone }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="u.status?.toUpperCase() === 'ACTIVE' ? 'background:var(--green-bg);color:var(--green)' : 'background:var(--red-bg);color:var(--red)'"
                  ><span class="status-dot" />{{ u.status?.toUpperCase() }}</span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(u.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <div class="flex items-center justify-end gap-1">
                    <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-foreground" @click="goToDetail(u.uuid)">
                      <Eye :size="15" />
                    </Button>
                    <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-foreground" @click="goToEdit(u.uuid)">
                      <Pencil :size="14" />
                    </Button>
                    <Button variant="ghost" size="icon" class="h-8 w-8 text-muted-foreground hover:text-red-500" @click="confirmDelete(u.uuid, u.name)">
                      <Trash2 :size="14" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>

              <TableRow v-if="!store.loading && store.users.length === 0 && !store.error">
                <TableCell colspan="5" class="text-center text-muted-foreground py-10 text-sm">No users found.</TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <div
        v-if="store.meta && store.meta.total_pages > 1"
        class="flex flex-col items-center gap-2 mt-4"
      >
        <Pagination :page="currentPage" :total-pages="store.meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- New user drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">New user</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false">
              <X :size="18" />
            </Button>
          </div>
          <div class="p-5 flex flex-col gap-4 overflow-y-auto flex-1">
            <div class="flex flex-col gap-1.5">
              <Label>Full name <span class="text-red-500">*</span></Label>
              <Input v-model="name" :error="errors.name" placeholder="Jordan Lee" />
              <p v-if="errors.name" class="text-[12px] text-red-500">{{ errors.name }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Phone <span class="text-red-500">*</span></Label>
              <Input v-model="phone" type="tel" :error="errors.phone" placeholder="+855 12 345 678" />
              <p v-if="errors.phone" class="text-[12px] text-red-500">{{ errors.phone }}</p>
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Password <span class="text-red-500">*</span></Label>
              <div class="relative">
                <Input
                  v-model="password"
                  :type="showPw ? 'text' : 'password'"
                  :error="errors.password"
                  placeholder="••••••••"
                  class="pr-12"
                />
                <button
                  class="absolute right-3 top-1/2 -translate-y-1/2 text-[12px] font-medium text-muted-foreground"
                  @click="showPw = !showPw"
                >
                  {{ showPw ? "Hide" : "Show" }}
                </button>
              </div>
              <p v-if="errors.password" class="text-[12px] text-red-500">{{ errors.password }}</p>
            </div>
            <div
              v-if="drawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ drawerError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="saveUser">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Creating…" : "Create user" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import { z } from "zod";
import { useDialog } from "@/composables/useDialog";
import { Plus, X, Eye, Pencil, Trash2, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import UserAvatar from "@/components/admin/UserAvatar.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import {
  Table, TableHeader, TableBody, TableRow, TableHead, TableCell,
} from "@/components/ui/table";
import { fmtDate } from "@/utils/format";
import { useUIStore } from "@/stores/ui";
import { useUsersStore } from "@/stores/users";
import Pagination from "@/components/admin/Pagination.vue";
import { createUser, deleteUser } from "@/api/users";
import { ADMIN_ROUTES } from "@/router/admin-routes";

const UserSchema = z.object({
  name: z.string().min(1, 'Full name is required'),
  phone: z.string().min(1, 'Phone is required'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
})

const router = useRouter();
const ui = useUIStore();
const store = useUsersStore();
const { open: openDialog } = useDialog();

const drawerOpen = ref(false);
const showPw = ref(false);
const saving = ref(false);
const drawerError = ref("");
const currentPage = ref(1);

const { defineField, handleSubmit, errors, resetForm } = useForm({
  validationSchema: toTypedSchema(UserSchema),
  initialValues: { name: '', phone: '', password: '' },
})

const [name] = defineField('name')
const [phone] = defineField('phone')
const [password] = defineField('password')

onMounted(() => store.loadUsers(currentPage.value));

function goToDetail(uuid: string) { router.push(ADMIN_ROUTES.users.detail(uuid)); }
function goToEdit(uuid: string) { router.push(ADMIN_ROUTES.users.edit(uuid)); }

function confirmDelete(uuid: string, uname: string) {
  openDialog({
    type: "danger",
    title: "Delete User",
    message: `Are you sure you want to delete "${uname}"? This action cannot be undone.`,
    confirmLabel: "Delete",
    onConfirm: async () => {
      try {
        await deleteUser(uuid);
        ui.showToast(`"${uname}" deleted`, 'success');
        store.loadUsers(currentPage.value);
      } catch (e: unknown) {
        ui.showToast(e instanceof Error ? e.message : 'Failed to delete user', 'danger');
      }
    },
  });
}

function changePage(page: number) {
  currentPage.value = page;
  store.loadUsers(page);
}

function openNew() {
  resetForm();
  showPw.value = false;
  drawerError.value = "";
  drawerOpen.value = true;
}

const saveUser = handleSubmit(async (values) => {
  saving.value = true;
  drawerError.value = "";
  try {
    await createUser({ name: values.name, phone: values.phone, password: values.password });
    drawerOpen.value = false;
    ui.showToast("User created successfully", "success");
    store.loadUsers(currentPage.value);
  } catch (e: unknown) {
    drawerError.value = e instanceof Error ? e.message : "Failed to create user.";
  } finally {
    saving.value = false;
  }
});
</script>
