<template>
  <AdminLayout>
    <DataNotFound
      v-if="store.error && !store.detailLoading"
      :message="store.error"
      :back-to="ADMIN_ROUTES.users.list"
      back-label="Back to users"
    />

    <div v-else class="p-6 max-w-2xl mx-auto">
      <button
        class="flex items-center gap-1.5 text-[13px] text-muted-foreground hover:text-foreground transition-colors mb-4"
        @click="router.back()"
      >
        <ArrowLeft :size="14" /> Back to users
      </button>

      <div class="flex items-center justify-between mb-5">
        <h1 class="text-[20px] font-semibold">User Detail</h1>
        <Button size="sm" @click="router.push(ADMIN_ROUTES.users.edit(route.params.uuid as string))">
          <Pencil :size="13" /> Edit
        </Button>
      </div>

      <!-- Loading skeleton -->
      <Card v-if="store.detailLoading">
        <div class="flex items-center gap-3 px-8 py-5 border-b border-border/40">
          <div class="w-11 h-11 rounded-full bg-muted animate-pulse shrink-0" />
          <div class="flex flex-col gap-2">
            <div class="h-4 w-36 rounded bg-muted animate-pulse" />
            <div class="h-3 w-20 rounded bg-muted animate-pulse" />
          </div>
        </div>
        <div v-for="n in 7" :key="n" class="flex items-center px-8 py-4 gap-8 border-b border-border/40 last:border-0">
          <div class="h-4 w-24 rounded bg-muted animate-pulse shrink-0" />
          <div class="h-4 rounded bg-muted animate-pulse" :style="`width:${50+n*6}%`" />
        </div>
      </Card>

      <Card v-else-if="store.selectedUser">
        <!-- Header -->
        <div class="flex items-center gap-3 px-8 py-5 border-b border-border/40">
          <UserAvatar :name="store.selectedUser.name" :size="44" />
          <div>
            <p class="text-[14px] font-semibold">{{ store.selectedUser.name }}</p>
            <span
              class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold mt-0.5"
              :style="store.selectedUser.status?.toUpperCase() === 'ACTIVE'
                ? 'background:var(--green-bg);color:var(--green)'
                : 'background:var(--red-bg);color:var(--red)'"
            ><span class="status-dot" />{{ store.selectedUser.status?.toUpperCase() }}</span>
          </div>
        </div>

        <!-- Info rows -->
        <div
          v-for="row in infoRows"
          :key="row.label"
          class="flex items-center px-8 py-4 border-b border-border/40 last:border-0"
        >
          <span class="w-36 text-[13px] text-muted-foreground shrink-0">{{ row.label }}</span>
          <div class="flex-1 flex items-center">
            <span :class="['text-[13px]', row.mono ? 'font-mono text-[12px]' : '']">{{ row.value }}</span>
          </div>
        </div>
      </Card>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { computed, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ArrowLeft, Pencil } from "@lucide/vue";
import AdminLayout from "@/components/admin/AdminLayout.vue";
import UserAvatar from "@/components/admin/UserAvatar.vue";
import DataNotFound from "@/components/admin/DataNotFound.vue";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { fmtDate } from "@/utils/format";
import { useUsersStore } from "@/stores/users";
import { ADMIN_ROUTES } from "@/router/admin-routes";

const route = useRoute();
const router = useRouter();
const store = useUsersStore();

onMounted(() => store.loadUser(route.params.uuid as string));

const infoRows = computed(() => {
  const u = store.selectedUser;
  if (!u) return [];
  return [
    { label: "UUID",       value: u.uuid,                mono: true  },
    { label: "Phone",      value: u.phone,               mono: false },
    { label: "Status",     value: u.status?.toUpperCase() ?? u.status, mono: false },
    { label: "Created at", value: fmtDate(u.created_at), mono: false },
    { label: "Created by", value: u.created_by ?? "—",   mono: false },
    { label: "Updated at", value: fmtDate(u.updated_at), mono: false },
    { label: "Updated by", value: u.updated_by ?? "—",   mono: false },
  ];
});
</script>
