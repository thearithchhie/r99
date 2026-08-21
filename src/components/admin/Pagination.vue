<template>
  <div class="flex items-center gap-1">
    <!-- Prev -->
    <button
      class="pagination-btn"
      :disabled="page <= 1"
      @click="emit('change', page - 1)"
    >
      <ChevronLeft :size="14" />
    </button>

    <!-- Page numbers -->
    <template v-for="(p, i) in pages" :key="i">
      <span
        v-if="p === '...'"
        class="px-1 text-[13px] text-muted-foreground select-none"
        >…</span
      >
      <button
        v-else
        class="pagination-btn"
        :class="p === page ? 'pagination-btn--active' : ''"
        @click="emit('change', p as number)"
      >
        {{ p }}
      </button>
    </template>

    <!-- Next -->
    <button
      class="pagination-btn"
      :disabled="page >= totalPages"
      @click="emit('change', page + 1)"
    >
      <ChevronRight :size="14" />
    </button>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { ChevronLeft, ChevronRight } from "@lucide/vue";

const props = defineProps<{
  page: number;
  totalPages: number;
}>();

const emit = defineEmits<{
  change: [page: number];
}>();

const pages = computed(() => getPages(props.page, props.totalPages));

function getPages(current: number, total: number): (number | "...")[] {
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);

  const result: (number | "...")[] = [];
  const left = Math.max(2, current - 2);
  const right = Math.min(total - 1, current + 2);

  result.push(1);
  if (left > 2) result.push("...");
  for (let i = left; i <= right; i++) result.push(i);
  if (right < total - 1) result.push("...");
  result.push(total);

  return result;
}
</script>

<style scoped>
.pagination-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  height: 32px;
  padding: 0 6px;
  border-radius: 6px;
  border: 1px solid hsl(var(--border));
  background: hsl(var(--card));
  color: hsl(var(--foreground));
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition:
    background 0.15s,
    border-color 0.15s;
}
.pagination-btn:hover:not(:disabled):not(.pagination-btn--active) {
  background: hsl(var(--muted));
}
.pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
.pagination-btn--active {
  background: hsl(var(--primary));
  border-color: hsl(var(--primary));
  color: hsl(var(--primary-foreground));
  cursor: default;
}
</style>
