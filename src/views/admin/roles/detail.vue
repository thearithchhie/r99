<template>
  <AdminLayout>
    <DataNotFound
      v-if="store.error && !loading"
      :message="store.error"
      :back-to="ADMIN_ROUTES.roles.list"
      back-label="Back to roles"
    />

    <div v-else class="p-6 max-w-4xl mx-auto">
      <button
        class="flex items-center gap-1.5 text-[13px] text-muted-foreground hover:text-foreground transition-colors mb-4"
        @click="router.back()"
      >
        <ArrowLeft :size="14" /> Back to roles
      </button>

      <h1 class="text-[20px] font-semibold mb-5">Edit Role</h1>

      <!-- Loading skeleton -->
      <Card v-if="loading">
        <div
          v-for="n in 3"
          :key="n"
          class="flex items-center px-8 py-5 gap-8 border-b border-border/40 last:border-0"
        >
          <div class="h-4 w-24 rounded bg-muted animate-pulse shrink-0" />
          <div class="h-9 rounded bg-muted animate-pulse flex-1 max-w-xs" />
        </div>
        <div class="px-8 py-6">
          <div class="flex gap-5 mb-5">
            <div class="h-4 w-20 rounded bg-muted animate-pulse" />
            <div class="h-4 w-28 rounded bg-muted animate-pulse" />
          </div>
          <div class="grid grid-cols-4 gap-6">
            <div v-for="g in 4" :key="g" class="flex flex-col gap-2">
              <div class="h-4 w-16 rounded bg-muted animate-pulse mb-1" />
              <div
                v-for="r in 4"
                :key="r"
                class="h-4 rounded bg-muted animate-pulse"
                :style="`width:${55 + r * 8}%`"
              />
            </div>
          </div>
        </div>
      </Card>

      <Card v-else-if="store.selectedRole">
        <!-- Name -->
        <div class="flex items-center px-8 py-5 border-b border-border/40">
          <span class="w-36 text-[13px] text-muted-foreground shrink-0"
            >Name</span
          >
          <div class="flex-1 flex items-center">
            <Input v-model="form.name" class="max-w-xs h-9 text-[13.5px]" />
          </div>
        </div>

        <!-- Description -->
        <div class="flex items-center px-8 py-5 border-b border-border/40">
          <span class="w-36 text-[13px] text-muted-foreground shrink-0"
            >Description</span
          >
          <div class="flex-1 flex items-center">
            <Input
              v-model="form.description"
              placeholder="—"
              class="max-w-xs h-9 text-[13.5px]"
            />
          </div>
        </div>

        <!-- Permissions -->
        <div class="flex px-8 py-7">
          <span class="w-36 text-[13px] text-muted-foreground shrink-0 pt-0.5"
            >Permissions</span
          >
          <div class="flex-1 min-w-0">
            <!-- Select all / None -->
            <div
              class="flex items-center gap-5 mb-6 pb-4 border-b border-border/40"
            >
              <button
                class="text-[13px] font-semibold leading-none hover:opacity-70 transition-opacity"
                @click="selectAll"
              >
                Select all
              </button>
              <span class="text-border text-xs select-none">|</span>
              <button
                class="text-[13px] text-muted-foreground leading-none hover:text-foreground transition-colors"
                @click="clearAll"
              >
                Do not select any
              </button>
            </div>

            <!-- Permission groups grid -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-x-8 gap-y-7">
              <div v-for="(perms, group) in groupedPerms" :key="group">
                <p
                  class="text-[11.5px] font-semibold text-muted-foreground uppercase tracking-wider mb-3"
                >
                  {{ group }}
                </p>
                <div
                  v-for="perm in perms"
                  :key="perm.uuid"
                  class="flex items-center gap-2.5 mb-2.5"
                >
                  <input
                    :id="perm.uuid"
                    type="checkbox"
                    :checked="selectedSet.has(perm.uuid)"
                    class="w-3.75 h-3.75 accent-blue-600 cursor-pointer shrink-0"
                    @change="togglePerm(perm.uuid)"
                  />
                  <label
                    :for="perm.uuid"
                    class="text-[12.5px] cursor-pointer leading-snug"
                  >
                    {{ humanize(perm.action) }}
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="flex items-center justify-end gap-2.5 px-8 py-4 border-t border-border/40">
          <Button variant="outline" :disabled="saving" @click="router.back()">Cancel</Button>
          <Button :disabled="saving" class="bg-blue-600 hover:bg-blue-700 text-white" @click="save">
            <Loader2 v-if="saving" :size="13" class="animate-spin mr-1" />
            Save
          </Button>
        </div>
      </Card>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, reactive } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ArrowLeft, Loader2 } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import DataNotFound from "@/components/admin/DataNotFound.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useRolesStore } from "@/stores/roles";
import { useUIStore } from "@/stores/ui";
import { fetchAllPermissions } from "@/api/permissions";
import { updateRolePermissions } from "@/api/roles";
import { ADMIN_ROUTES } from "@/router/admin-routes";
import type { PermissionItem } from "@/api/permissions";

const route = useRoute();
const router = useRouter();
const store = useRolesStore();
const ui = useUIStore();

const allPerms = ref<PermissionItem[]>([]);
const loading = ref(true);
const saving = ref(false);

const selectedUuids = ref<string[]>([]);
const selectedSet = computed(() => new Set(selectedUuids.value));

const form = reactive({ name: "", description: "" });

onMounted(async () => {
  loading.value = true;
  try {
    const [, permsData] = await Promise.all([
      store.loadRole(route.params.uuid as string),
      fetchAllPermissions(),
    ]);

    allPerms.value = permsData.permissions;

    const role = store.selectedRole;
    if (role) {
      form.name = role.name;
      form.description = role.description ?? "";
      selectedUuids.value = role.permissions.map((p) => p.uuid);
    }
  } finally {
    loading.value = false;
  }
});

const groupedPerms = computed(() => {
  const groups: Record<string, PermissionItem[]> = {};
  for (const perm of allPerms.value) {
    const group = perm.module.charAt(0).toUpperCase() + perm.module.slice(1);
    (groups[group] ??= []).push(perm);
  }
  return Object.fromEntries(
    Object.entries(groups).sort(([a], [b]) => a.localeCompare(b)),
  );
});

function humanize(str: string): string {
  return str.replace(/_/g, " ").replace(/^./, (c) => c.toUpperCase());
}

function togglePerm(uuid: string) {
  if (selectedUuids.value.includes(uuid)) {
    selectedUuids.value = selectedUuids.value.filter((id) => id !== uuid);
  } else {
    selectedUuids.value = [...selectedUuids.value, uuid];
  }
}

function selectAll() {
  selectedUuids.value = allPerms.value.map((p) => p.uuid);
}

function clearAll() {
  selectedUuids.value = [];
}

async function save() {
  saving.value = true;
  try {
    const uuid = route.params.uuid as string;
    await updateRolePermissions(uuid, selectedUuids.value);
    await store.loadRole(uuid);
    ui.showToast("Permissions updated", "success");
    router.push(ADMIN_ROUTES.roles.list);
  } catch (e: unknown) {
    ui.showToast(e instanceof Error ? e.message : "Failed to update permissions", "danger");
  } finally {
    saving.value = false;
  }
}
</script>
