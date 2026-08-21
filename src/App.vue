<template>
  <RouterView />
  <Teleport to="body">
    <Transition name="toast">
      <div
        v-if="ui.toast"
        class="fixed top-5 right-5 z-[9999] flex items-center gap-3 bg-background border border-border/60 rounded-lg px-4 py-3 shadow-xl max-w-xs"
        :class="cfg.borderLeft"
      >
        <div :class="['w-7 h-7 rounded-full flex items-center justify-center shrink-0', cfg.iconBg]">
          <component :is="cfg.icon" :size="14" :class="cfg.iconColor" />
        </div>
        <p class="text-[13px] font-medium leading-snug">{{ ui.toast.msg }}</p>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Info, CheckCircle2, AlertTriangle, AlertCircle } from '@lucide/vue'
import { useUIStore } from '@/stores/ui'

const ui = useUIStore()

const TYPE_CONFIG = {
  info: {
    icon: Info,
    iconBg: 'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600',
    borderLeft: 'border-l-[3px] border-l-blue-500',
  },
  success: {
    icon: CheckCircle2,
    iconBg: 'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600',
    borderLeft: 'border-l-[3px] border-l-green-500',
  },
  warning: {
    icon: AlertTriangle,
    iconBg: 'bg-amber-100 dark:bg-amber-900/30',
    iconColor: 'text-amber-foreground',
    borderLeft: 'border-l-[3px] border-l-amber-500',
  },
  danger: {
    icon: AlertCircle,
    iconBg: 'bg-red-100 dark:bg-red-900/30',
    iconColor: 'text-red-600',
    borderLeft: 'border-l-[3px] border-l-red-500',
  },
} as const

const cfg = computed(() => TYPE_CONFIG[ui.toast?.type ?? 'info'])
</script>

<style>
.toast-enter-active, .toast-leave-active { transition: all 0.2s ease; }
.toast-enter-from, .toast-leave-to { opacity: 0; transform: translateY(-8px); }
</style>
