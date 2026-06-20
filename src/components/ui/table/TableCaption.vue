<template><caption :class="cn('mt-4 text-sm text-muted-foreground', $attrs.class as string)"><slot /></caption></template>
<script setup lang="ts">
import { cn } from '@/lib/utils'
defineOptions({ inheritAttrs: false })
</script>
