<template>
  <div ref="containerRef" class="relative">
    <!-- Trigger -->
    <div
      class="flex min-h-9 w-full flex-wrap gap-1.5 items-center rounded-md border border-input bg-background px-3 py-1.5 text-sm cursor-pointer transition-colors"
      :class="[
        disabled
          ? 'opacity-50 pointer-events-none'
          : 'hover:border-muted-foreground/40',
        open ? 'ring-1 ring-ring border-ring' : '',
      ]"
      @click="openDropdown"
    >
      <!-- Multiple: chips -->
      <template v-if="multiple">
        <span
          v-for="p in selectedProducts"
          :key="p.uuid"
          class="inline-flex items-center gap-1 rounded-md bg-muted px-2 py-0.5 text-[12px] font-medium"
        >
          {{ p.name }}
          <button
            class="text-muted-foreground hover:text-foreground leading-none"
            @click.stop="deselect(p.uuid)"
          >
            <X :size="11" />
          </button>
        </span>
        <span
          v-if="!selectedProducts.length"
          class="text-muted-foreground text-[13px] leading-5 select-none"
          >{{ placeholder }}</span
        >
      </template>

      <!-- Single -->
      <template v-else>
        <span
          v-if="selectedProducts[0]"
          class="leading-5 text-[13.5px] flex-1 truncate"
          >{{ selectedProducts[0].name }}</span
        >
        <span
          v-else
          class="text-muted-foreground leading-5 text-[13.5px] flex-1 select-none"
          >{{ placeholder }}</span
        >
      </template>

      <ChevronDown
        :size="14"
        class="shrink-0 text-muted-foreground transition-transform duration-150 ml-1"
        :class="open ? 'rotate-180' : ''"
      />
    </div>

    <!-- Dropdown — fixed position escapes overflow:auto clipping without Teleport -->
    <div
      v-if="open"
      :style="dropdownStyle"
      class="fixed z-[9999] rounded-md border border-border bg-background shadow-lg overflow-hidden"
    >
      <!-- Search -->
      <div class="flex items-center gap-2 px-3 py-2 border-b border-border">
        <Search :size="13" class="text-muted-foreground shrink-0" />
        <input
          ref="searchRef"
          v-model="query"
          class="flex-1 bg-transparent text-[13px] outline-none placeholder:text-muted-foreground"
          placeholder="Search products…"
          @input="onSearch"
          @keydown.escape="open = false"
          @keydown.down.prevent="focusResult(0)"
        />
        <Loader2
          v-if="searching"
          :size="13"
          class="text-muted-foreground animate-spin shrink-0"
        />
      </div>

      <!-- Results -->
      <ul class="max-h-52 overflow-y-auto py-1" role="listbox">
        <li
          v-if="!searching && results.length === 0 && query.length === 0"
          class="px-3 py-3 text-[13px] text-muted-foreground text-center"
        >
          Type to search products.
        </li>
        <li
          v-if="!searching && results.length === 0 && query.length > 0"
          class="px-3 py-3 text-[13px] text-muted-foreground text-center"
        >
          No products found for "{{ query }}".
        </li>
        <li
          v-for="(p, i) in results"
          :key="p.uuid"
          :ref="
            (el) => {
              if (el) resultRefs[i] = el as HTMLElement;
            }
          "
          role="option"
          :aria-selected="isSelected(p.uuid)"
          class="flex items-center gap-2.5 px-3 py-2.5 cursor-pointer hover:bg-muted/60 transition-colors outline-none"
          :class="isSelected(p.uuid) ? 'bg-muted/40' : ''"
          tabindex="-1"
          @mousedown.prevent="select(p)"
          @keydown.enter.prevent="select(p)"
          @keydown.down.prevent="focusResult(i + 1)"
          @keydown.up.prevent="focusResult(i - 1)"
        >
          <Check
            :size="13"
            class="shrink-0 transition-opacity"
            :class="
              isSelected(p.uuid) ? 'text-primary opacity-100' : 'opacity-0'
            "
          />
          <div class="flex-1 min-w-0">
            <div class="text-[13px] font-medium truncate">{{ p.name }}</div>
            <div class="text-muted-foreground font-mono text-[11px]">
              {{ p.code }}
            </div>
          </div>
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  ref,
  computed,
  watch,
  nextTick,
  onMounted,
  onUnmounted,
  reactive,
} from "vue";
import { Search, X, Check, ChevronDown, Loader2 } from "@lucide/vue";
import { searchProducts } from "@/api/products";
import type { ProductSearchResult } from "@/api/products";

const props = withDefaults(
  defineProps<{
    modelValue?: string | string[];
    multiple?: boolean;
    placeholder?: string;
    disabled?: boolean;
  }>(),
  {
    multiple: false,
    placeholder: "Select product…",
    disabled: false,
  },
);

const emit = defineEmits<{
  "update:modelValue": [value: string | string[]];
}>();

const containerRef = ref<HTMLElement>();
const searchRef = ref<HTMLInputElement>();
const open = ref(false);
const query = ref("");
const results = ref<ProductSearchResult[]>([]);
const searching = ref(false);
const resultRefs = ref<HTMLElement[]>([]);
const dropdownStyle = reactive({ top: "0px", left: "0px", width: "0px" });

const productCache = ref<Map<string, ProductSearchResult>>(new Map());

const selectedUuids = computed<string[]>(() => {
  if (!props.modelValue) return [];
  return Array.isArray(props.modelValue)
    ? props.modelValue
    : [props.modelValue];
});

const selectedProducts = computed<ProductSearchResult[]>(() =>
  selectedUuids.value.flatMap((uuid) => {
    const p = productCache.value.get(uuid);
    return p ? [p] : [];
  }),
);

function isSelected(uuid: string) {
  return selectedUuids.value.includes(uuid);
}

function select(product: ProductSearchResult) {
  productCache.value.set(product.uuid, product);
  if (props.multiple) {
    const current = [...selectedUuids.value];
    const idx = current.indexOf(product.uuid);
    if (idx === -1) current.push(product.uuid);
    else current.splice(idx, 1);
    emit("update:modelValue", current);
  } else {
    emit("update:modelValue", product.uuid);
    open.value = false;
  }
}

function deselect(uuid: string) {
  emit(
    "update:modelValue",
    selectedUuids.value.filter((id) => id !== uuid),
  );
}

function updateDropdownPosition() {
  if (!containerRef.value) return;
  const rect = containerRef.value.getBoundingClientRect();
  dropdownStyle.top = `${rect.bottom + 4}px`;
  dropdownStyle.left = `${rect.left}px`;
  dropdownStyle.width = `${rect.width}px`;
}

async function openDropdown() {
  updateDropdownPosition();
  open.value = true;
  await nextTick();
  searchRef.value?.focus();
}

let debounceTimer: ReturnType<typeof setTimeout> | null = null;

function onSearch() {
  if (debounceTimer) clearTimeout(debounceTimer);
  if (!query.value.trim()) {
    results.value = [];
    return;
  }
  debounceTimer = setTimeout(doSearch, 300);
}

async function doSearch() {
  searching.value = true;
  try {
    const data = await searchProducts(query.value.trim());
    results.value = data;
    for (const p of data) productCache.value.set(p.uuid, p);
  } catch {
    results.value = [];
  } finally {
    searching.value = false;
  }
}

function focusResult(index: number) {
  const el =
    resultRefs.value[Math.max(0, Math.min(index, resultRefs.value.length - 1))];
  el?.focus();
}

function onClickOutside(e: MouseEvent) {
  const target = e.target as Node;
  if (containerRef.value && !containerRef.value.contains(target)) {
    open.value = false;
  }
}

watch(open, (val) => {
  if (!val) {
    query.value = "";
    results.value = [];
    resultRefs.value = [];
  }
});

onMounted(() => {
  document.addEventListener("mousedown", onClickOutside);
  window.addEventListener("scroll", updateDropdownPosition, true);
  window.addEventListener("resize", updateDropdownPosition);
});
onUnmounted(() => {
  document.removeEventListener("mousedown", onClickOutside);
  window.removeEventListener("scroll", updateDropdownPosition, true);
  window.removeEventListener("resize", updateDropdownPosition);
});
</script>
