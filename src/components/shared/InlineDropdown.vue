<template>
  <div class="relative inline-block" @click.stop>
    <!-- Trigger -->
    <button
      v-if="options.length > 0"
      class="hover:opacity-75 transition-opacity"
      :disabled="disabled"
      @click="openMenu"
    >
      <slot />
    </button>
    <slot v-else />

    <!-- Options -->
    <div
      v-if="open"
      class="absolute z-50 left-0 top-full mt-1 bg-background border border-border rounded-lg shadow-lg overflow-hidden min-w-[180px]"
    >
      <button
        v-for="opt in options"
        :key="opt.value"
        class="w-full flex items-center gap-2.5 px-3 py-2.5 text-left hover:bg-muted transition-colors border-b border-border/50 last:border-0"
        :disabled="disabled"
        @click="onSelect(opt.value)"
      >
        <Loader2 v-if="disabled && loadingValue === opt.value" :size="12" class="animate-spin shrink-0" />
        <slot name="option" :option="opt">
          <span
            class="inline-flex items-center gap-1 rounded-md px-2 py-0.5 text-xs font-semibold"
            :style="opt.style"
          >{{ opt.label }}</span>
        </slot>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onBeforeUnmount } from "vue";
import { Loader2 } from "@lucide/vue";

export interface DropdownOption {
  value: string;
  label: string;
  style?: string;
}

defineProps<{
  options: DropdownOption[];
  disabled?: boolean;
  loadingValue?: string | null;
}>();

const emit = defineEmits<{ select: [value: string] }>();

const open = ref(false);

function close() { open.value = false; }

function openMenu() {
  open.value = true;
  setTimeout(() => document.addEventListener("click", close, { once: true }), 0);
}

function onSelect(value: string) {
  open.value = false;
  emit("select", value);
}

onBeforeUnmount(() => document.removeEventListener("click", close));
</script>
