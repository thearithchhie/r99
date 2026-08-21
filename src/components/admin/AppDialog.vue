<template>
  <Dialog :open="isOpen" @update:open="(v) => !v && handleCancel()">
    <DialogContent class="max-w-[360px] p-0 overflow-hidden gap-0 [&>button]:hidden">
      <!-- Top accent bar -->
      <div :class="['h-1 w-full', cfg.accent]" />

      <!-- Body -->
      <div class="flex flex-col items-center text-center px-7 pt-7 pb-6 gap-4">
        <!-- Icon circle -->
        <div :class="['w-[60px] h-[60px] rounded-full flex items-center justify-center', cfg.iconBg]">
          <component :is="cfg.icon" :size="28" :class="cfg.iconColor" />
        </div>

        <!-- Text -->
        <div class="flex flex-col gap-1.5">
          <p class="text-[15px] font-semibold tracking-tight">{{ opts.title }}</p>
          <p v-if="opts.message" class="text-[13px] text-muted-foreground leading-relaxed">
            {{ opts.message }}
          </p>
        </div>
      </div>

      <!-- Footer -->
      <div :class="['flex gap-2.5 px-7 pb-6', showCancel ? '' : 'justify-center']">
        <Button
          v-if="showCancel"
          variant="outline"
          class="flex-1 h-9 text-[13px]"
          :disabled="confirming"
          @click="handleCancel"
        >{{ opts.cancelLabel ?? 'Cancel' }}</Button>
        <Button
          :class="['h-9 text-[13px]', showCancel ? 'flex-1' : 'px-8', cfg.btnClass]"
          :disabled="confirming"
          @click="handleConfirm"
        >
          <Loader2 v-if="confirming" :size="13" class="animate-spin mr-1.5" />
          {{ opts.confirmLabel ?? cfg.defaultLabel }}
        </Button>
      </div>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Info, CheckCircle2, AlertTriangle, AlertCircle, HelpCircle, Loader2 } from '@lucide/vue'
import { Dialog, DialogContent } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { useDialog } from '@/composables/useDialog'

const { isOpen, confirming, opts, handleConfirm, handleCancel } = useDialog()

const TYPE_CONFIG = {
  info: {
    icon: Info,
    iconBg:    'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600',
    accent:    'bg-blue-500',
    btnClass:  'bg-blue-600 hover:bg-blue-700 text-white',
    defaultLabel: 'OK',
    hasCancel: false,
  },
  success: {
    icon: CheckCircle2,
    iconBg:    'bg-green-100 dark:bg-green-900/30',
    iconColor: 'text-green-600',
    accent:    'bg-green-500',
    btnClass:  'bg-green-600 hover:bg-green-700 text-white',
    defaultLabel: 'OK',
    hasCancel: false,
  },
  warning: {
    icon: AlertTriangle,
    iconBg:    'bg-amber-100 dark:bg-amber-900/30',
    iconColor: 'text-amber-600',
    accent:    'bg-amber-500',
    btnClass:  'bg-amber-600 hover:bg-amber-700 text-white',
    defaultLabel: 'Confirm',
    hasCancel: true,
  },
  danger: {
    icon: AlertCircle,
    iconBg:    'bg-red-100 dark:bg-red-900/30',
    iconColor: 'text-red-600',
    accent:    'bg-red-500',
    btnClass:  'bg-red-600 hover:bg-red-700 text-white',
    defaultLabel: 'Delete',
    hasCancel: true,
  },
  confirm: {
    icon: HelpCircle,
    iconBg:    'bg-blue-100 dark:bg-blue-900/30',
    iconColor: 'text-blue-600',
    accent:    'bg-blue-500',
    btnClass:  'bg-blue-600 hover:bg-blue-700 text-white',
    defaultLabel: 'Confirm',
    hasCancel: true,
  },
} as const

const cfg = computed(() => TYPE_CONFIG[opts.value.type ?? 'info'])
const showCancel = computed(() => (cfg.value.hasCancel || opts.value.cancelLabel !== undefined) && !opts.value.noCancel)
</script>
