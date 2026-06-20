<script setup lang="ts">
import type { HTMLAttributes } from 'vue'
import { inject, computed } from 'vue'
import { cn } from '@/lib/utils'
import { FORM_ITEM_INJECTION_KEY } from '.'

defineProps<{ class?: HTMLAttributes['class'] }>()
const field = inject(FORM_ITEM_INJECTION_KEY)
const body = computed(() => field?.error?.value)
</script>
<template>
  <p
    v-if="body"
    :id="field?.name?.value ? `${field.name.value}-error` : undefined"
    :class="cn('text-[13px] font-medium text-destructive', $props.class)"
  >
    {{ body }}
  </p>
</template>
