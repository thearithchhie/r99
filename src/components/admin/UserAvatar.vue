<template>
  <Avatar :class="cn('border border-border', sizeClass)">
    <AvatarFallback class="text-xs font-semibold bg-muted text-foreground">{{ initials(name) }}</AvatarFallback>
  </Avatar>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { cn } from '@/lib/utils'
import { initials } from '@/utils/format'

const props = withDefaults(defineProps<{ name: string; size?: number }>(), { size: 32 })

const sizeClass = computed(() => {
  if (props.size <= 28) return 'h-7 w-7'
  if (props.size <= 32) return 'h-8 w-8'
  if (props.size <= 36) return 'h-9 w-9'
  if (props.size <= 40) return 'h-10 w-10'
  if (props.size <= 48) return 'h-12 w-12'
  return 'h-14 w-14'
})
</script>
