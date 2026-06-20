<template>
  <div class="flex min-h-screen bg-background">
    <AdminSidebar />

    <Teleport to="body">
      <div
        v-if="ui.sidebarOpen"
        class="fixed inset-0 z-100 bg-black/50"
        @click="ui.closeSidebar()"
      />
      <div
        class="fixed top-0 left-0 bottom-0 z-101 transition-transform duration-300 ease-in-out"
        :class="ui.sidebarOpen ? 'translate-x-0' : '-translate-x-full'"
      >
        <AdminSidebar :mobile="true" @click="ui.closeSidebar()" />
      </div>
    </Teleport>

    <div class="flex flex-col flex-1 min-w-0 overflow-hidden">
      <AdminTopbar :search="search" @update:search="search = $event">
        <template #actions><slot name="topbar-actions" /></template>
      </AdminTopbar>
      <main class="flex-1 overflow-auto">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { useRoute } from "vue-router";
import AdminSidebar from "./AdminSidebar.vue";
import AdminTopbar from "./AdminTopbar.vue";
import { useUIStore } from "@/stores/ui";

const ui = useUIStore();
const search = ref("");
defineExpose({ search });

watch(useRoute(), () => { ui.closeSidebar() })
</script>
