<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { inject } from 'vue'
import { Label } from '@/components/ui/label'
import { cn } from '@/lib/utils'
import { FORM_ITEM_INJECTION_KEY } from '.'

defineProps<{ class?: HTMLAttributes['class'] }>()
const field = inject(FORM_ITEM_INJECTION_KEY)
</script>
<template>
  <Label
    :class="cn(field?.error?.value ? 'text-destructive' : '', $props.class)"
    :for="String(field?.name?.value)"
  >
    <slot />
  </Label>
</template>
