<template>
  <span :class="cn('flex h-full w-full items-center justify-center rounded-full bg-muted text-xs font-semibold', $attrs.class as string)">
    <slot />
  </span>
</template>
<script setup lang="ts">
import { cn } from '@/lib/utils'
defineOptions({ inheritAttrs: false })
</script>
