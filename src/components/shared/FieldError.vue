<template>
  <p v-if="message || $slots.default" class="text-[12px] text-red-500 mt-0.5">
    <slot>{{ message }}</slot>
  </p>
</template>

<script setup lang="ts">
defineProps<{ message?: string }>()
</script>
