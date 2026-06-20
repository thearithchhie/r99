<template>
  <span
    :class="
      cn(
        'relative flex shrink-0 overflow-hidden rounded-full',
        $attrs.class as string,
      )
    "
  >
    <slot />
  </span>
</template>
<script setup lang="ts">
import { cn } from "@/lib/utils";
defineOptions({ inheritAttrs: false });
</script>
