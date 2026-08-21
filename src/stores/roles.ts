import { defineStore } from "pinia";
import { ref } from "vue";
import { fetchRoles, fetchRole } from "@/api/roles";
import type { RoleResponse, RoleDetailResponse } from "@/api/roles";
import type { PageMeta } from "@/api/users";

export const useRolesStore = defineStore("roles", () => {
  const roles = ref<RoleResponse[]>([]);
  const meta = ref<PageMeta | null>(null);
  const selectedRole = ref<RoleDetailResponse | null>(null);
  const loading = ref(false);
  const detailLoading = ref(false);
  const error = ref<string | null>(null);

  async function loadRoles(page = 1) {
    loading.value = true;
    error.value = null;
    try {
      const data = await fetchRoles(page);
      roles.value = data.roles;
      meta.value = data.meta;
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : "Failed to load roles";
    } finally {
      loading.value = false;
    }
  }

  async function loadRole(uuid: string) {
    detailLoading.value = true;
    error.value = null;
    selectedRole.value = null;
    try {
      selectedRole.value = await fetchRole(uuid);
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : "Failed to load role";
    } finally {
      detailLoading.value = false;
    }
  }

  return { roles, meta, selectedRole, loading, detailLoading, error, loadRoles, loadRole };
});
