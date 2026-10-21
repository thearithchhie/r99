<template>
  <div class="flex flex-col items-center justify-center w-full h-[calc(100vh-120px)] select-none">
    <!-- Icon badge -->
    <div class="relative mb-7">
      <div class="w-20 h-20 rounded-2xl bg-gradient-to-br from-primary/10 to-primary/5 border border-primary/15 flex items-center justify-center shadow-sm">
        <Sparkles :size="36" class="text-primary/70" />
      </div>
      <!-- Floating dot -->
      <span class="absolute -top-1.5 -right-1.5 w-4 h-4 rounded-full bg-primary flex items-center justify-center">
        <span class="w-2 h-2 rounded-full bg-white dark:bg-background animate-ping opacity-75" />
      </span>
    </div>

    <!-- Text -->
    <h2 class="text-[22px] font-bold tracking-tight text-foreground mb-2">Coming Soon</h2>
    <p v-if="feature" class="text-[13px] font-semibold text-primary/80 mb-3 uppercase tracking-widest">
      {{ feature }}
    </p>
    <p class="text-[13.5px] text-muted-foreground text-center max-w-xs leading-relaxed">
      {{ description }}
    </p>

    <!-- Decorative dots -->
    <div class="flex gap-1.5 mt-8">
      <span class="w-1.5 h-1.5 rounded-full bg-primary/40" />
      <span class="w-1.5 h-1.5 rounded-full bg-primary/20" />
      <span class="w-1.5 h-1.5 rounded-full bg-primary/10" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { Sparkles } from "@lucide/vue";

withDefaults(
  defineProps<{
    feature?: string;
    description?: string;
  }>(),
  {
    description: "We're working hard to bring this to you. Stay tuned for updates.",
  },
);
</script>
