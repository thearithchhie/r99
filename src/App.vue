<template>
  <RouterView />
  <Teleport to="body">
    <Transition name="toast">
      <div v-if="ui.toast"
        class="fixed top-5 right-5 z-[9999] bg-foreground text-primary-foreground px-4 py-2.5 rounded-lg text-[13.5px] font-medium shadow-xl max-w-xs">
        {{ ui.toast }}
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { useUIStore } from '@/stores/ui'
const ui = useUIStore()
</script>

<style>
.toast-enter-active, .toast-leave-active { transition: all 0.2s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateY(-8px); }
</style>
