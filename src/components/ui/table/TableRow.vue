<script setup lang="ts">
import type { HTMLAttributes } from "vue";
import { cn } from "@/lib/utils";
defineProps<{ class?: HTMLAttributes["class"] }>();
</script>
<template>
  <tr
    :class="
      cn(
        'border-b border-border/50 transition-colors hover:bg-muted/30 data-[state=selected]:bg-muted [&:last-child]:border-0',
        $props.class,
      )
    "
  >
    <slot />
  </tr>
</template>
