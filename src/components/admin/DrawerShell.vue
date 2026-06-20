<template>
  <Sheet :open="open" @update:open="(v) => !v && $emit('close')">
    <SheetContent class="overflow-y-auto p-0 w-[440px] sm:max-w-[440px]">
      <slot />
    </SheetContent>
  </Sheet>
</template>

<script setup lang="ts">
import { Sheet, SheetContent } from '@/components/ui/sheet'

defineProps<{ open: boolean }>()
defineEmits<{ close: [] }>()
</script>
