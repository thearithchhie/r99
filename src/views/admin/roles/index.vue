<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ store.meta ? store.meta.total + " roles" : "" }}
        </p>
        <Button size="sm" @click="openCreate"><Plus :size="14" /> New role</Button>
      </div>

      <!-- Error -->
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
              <TableHead>Description</TableHead>
              <TableHead>Users</TableHead>
              <TableHead>Permissions</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Created at</TableHead>
              <TableHead class="text-right">Action</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <!-- Loading skeleton -->
            <TableRow v-if="store.loading" v-for="n in 5" :key="'skel-' + n">
              <TableCell colspan="7">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <!-- Data rows -->
            <template v-if="!store.loading">
              <TableRow
                v-for="role in store.roles"
                :key="role.uuid"
                class="cursor-pointer hover:bg-muted/40 transition-colors"
                @click="goToDetail(role.uuid)"
              >
                <TableCell>
                  <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-full bg-primary/10 grid place-items-center shrink-0">
                      <Shield :size="14" class="text-primary" />
                    </div>
                    <span class="font-medium">{{ role.name }}</span>
                  </div>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px] max-w-[260px]">
                  <span class="line-clamp-1">{{ role.description || '—' }}</span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ role.user_count }}</TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ role.permission_count }}</TableCell>
                <TableCell>
                  <span
                    class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
                    :style="role.status?.toUpperCase() === 'ACTIVE'
                      ? 'background:var(--green-bg);color:var(--green)'
                      : 'background:var(--red-bg);color:var(--red)'"
                  ><span class="status-dot" />{{ role.status?.toUpperCase() }}</span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(role.created_at) }}</TableCell>
                <TableCell class="text-right" @click.stop>
                  <div class="flex items-center justify-end gap-1">
                    <Button
                      variant="ghost"
                      size="icon"
                      class="h-8 w-8 text-muted-foreground hover:text-foreground"
                      @click="goToDetail(role.uuid)"
                    >
                      <Pencil :size="14" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>

              <TableRow v-if="store.roles.length === 0 && !store.error">
                <TableCell colspan="7" class="text-center text-muted-foreground py-10 text-sm">
                  No roles found.
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <!-- Pagination -->
      <div v-if="store.meta && store.meta.total_pages > 1" class="flex flex-col items-center gap-2 mt-4">
        <Pagination :page="currentPage" :total-pages="store.meta.total_pages" @change="changePage" />
      </div>
    </div>

    <!-- Create drawer -->
    <Sheet :open="drawerOpen" @update:open="(v) => !v && (drawerOpen = false)">
      <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
        <div class="flex flex-col h-full">
          <div class="flex items-center justify-between px-5 py-4 border-b sticky top-0 bg-background">
            <span class="text-[15px] font-semibold">New role</span>
            <Button variant="ghost" size="icon" class="h-8 w-8" @click="drawerOpen = false">
              <X :size="18" />
            </Button>
          </div>
          <div class="p-5 flex flex-col gap-4 flex-1">
            <div class="flex flex-col gap-1.5">
              <Label>Role name</Label>
              <Input v-model="form.name" placeholder="e.g. Warehouse Staff" />
            </div>
            <div class="flex flex-col gap-1.5">
              <Label>Description <span class="text-muted-foreground font-normal">(optional)</span></Label>
              <Input v-model="form.description" placeholder="What can this role do?" />
            </div>
            <div
              v-if="drawerError"
              class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-3.5 py-2.5 text-[13px] text-red-600"
            >
              <AlertTriangle :size="14" class="shrink-0" />{{ drawerError }}
            </div>
            <Button class="w-full mt-1" :disabled="saving" @click="saveRole">
              <Loader2 v-if="saving" :size="14" class="animate-spin" />
              {{ saving ? "Creating…" : "Create role" }}
            </Button>
          </div>
        </div>
      </SheetContent>
    </Sheet>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { Plus, X, Pencil, Shield, AlertTriangle, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import Pagination from "@/components/admin/Pagination.vue";
import { fmtDate } from "@/utils/format";
import { useUIStore } from "@/stores/ui";
import { useRolesStore } from "@/stores/roles";
import { createRole } from "@/api/roles";
import { ADMIN_ROUTES } from "@/router/admin-routes";

const router = useRouter();
const ui = useUIStore();
const store = useRolesStore();

const drawerOpen = ref(false);
const saving = ref(false);
const drawerError = ref("");
const currentPage = ref(1);
const form = reactive({ name: "", description: "" });

onMounted(() => store.loadRoles(currentPage.value));

function goToDetail(uuid: string) {
  router.push(ADMIN_ROUTES.roles.detail(uuid));
}

function changePage(page: number) {
  currentPage.value = page;
  store.loadRoles(page);
}

function openCreate() {
  Object.assign(form, { name: "", description: "" });
  drawerError.value = "";
  drawerOpen.value = true;
}

async function saveRole() {
  if (!form.name.trim()) {
    drawerError.value = "Role name is required.";
    return;
  }
  saving.value = true;
  drawerError.value = "";
  try {
    await createRole({ name: form.name, description: form.description || undefined });
    drawerOpen.value = false;
    ui.showToast("Role created successfully", "success");
    store.loadRoles(currentPage.value);
  } catch (e: unknown) {
    drawerError.value = e instanceof Error ? e.message : "Failed to create role.";
  } finally {
    saving.value = false;
  }
}
</script>
