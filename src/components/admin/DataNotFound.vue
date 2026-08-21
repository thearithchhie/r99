<template>
  <div
    class="flex flex-col items-center justify-center gap-4 w-full h-[calc(100vh-60px)]"
  >
    <img
      src="@/assets/images/data-not-found.webp"
      alt="Not found"
      class="w-full max-h-[65vh] object-contain opacity-90"
    />
    <p class="text-[13.5px] text-muted-foreground">{{ message }}</p>
    <button
      v-if="backTo"
      class="text-[13px] font-medium text-primary hover:underline"
      @click="router.push(backTo)"
    >
      {{ backLabel }}
    </button>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";

withDefaults(
  defineProps<{
    message?: string;
    backTo?: string;
    backLabel?: string;
  }>(),
  {
    message: "Data not found.",
    backLabel: "Go back",
  },
);

const router = useRouter();
</script>
