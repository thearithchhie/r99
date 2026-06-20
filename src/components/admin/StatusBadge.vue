<template>
  <span
    class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
    :style="{ background: colors.bg, color: colors.color }"
  >
    <span class="status-dot" />{{ status }}
  </span>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { STATUS_COLORS } from '@/data/orders'

const props = defineProps<{ status: string }>()
const colors = computed(() => STATUS_COLORS[props.status] || { color: 'hsl(var(--muted-foreground))', bg: 'hsl(var(--muted))' })
</script>
