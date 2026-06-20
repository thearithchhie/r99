<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { cn } from '@/lib/utils'
defineProps<{ class?: HTMLAttributes['class'] }>()
</script>
<template>
  <th :class="cn('h-10 px-4 text-left align-middle text-xs font-semibold text-muted-foreground/70 uppercase tracking-wider [&:has([role=checkbox])]:pr-0', $props.class)"><slot /></th>
</template>
