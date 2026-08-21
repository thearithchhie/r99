<template>
  <div ref="containerRef" class="relative">
    <!-- Trigger -->
    <div
      class="flex min-h-9 w-full flex-wrap gap-1.5 items-center rounded-md border border-input bg-background px-3 py-1.5 text-sm cursor-pointer transition-colors"
      :class="[
        disabled ? 'opacity-50 pointer-events-none' : 'hover:border-muted-foreground/40',
        open ? 'ring-1 ring-ring border-ring' : '',
        errorMessage ? 'border-red-500 ring-1 ring-red-500' : '',
        decoration,
      ]"
      @click="openDropdown"
    >
      <!-- Multiple: chips -->
      <template v-if="multiple">
        <span
          v-for="opt in selectedOptions"
          :key="opt.value"
          class="inline-flex items-center gap-1 rounded-md bg-muted px-2 py-0.5 text-[12px] font-medium"
        >
          {{ opt.label }}
          <button class="text-muted-foreground hover:text-foreground leading-none" @click.stop="deselect(opt.value)">
            <X :size="11" />
          </button>
        </span>
        <span v-if="!selectedOptions.length" class="text-muted-foreground text-[13px] leading-5 select-none">{{ placeholder }}</span>
      </template>

      <!-- Single -->
      <template v-else>
        <span v-if="selectedOptions[0]" class="leading-5 text-[13.5px] flex-1 truncate">{{ selectedOptions[0].label }}</span>
        <span v-else class="text-muted-foreground leading-5 text-[13.5px] flex-1 select-none">{{ placeholder }}</span>
      </template>

      <ChevronDown
        :size="14"
        class="shrink-0 text-muted-foreground transition-transform duration-150 ml-1"
        :class="open ? 'rotate-180' : ''"
      />
    </div>

    <!-- Validation error -->
    <p v-if="errorMessage" class="mt-1 text-[12px] text-red-500">{{ errorMessage }}</p>

    <!-- Dropdown — fixed position escapes overflow:auto clipping -->
    <div
      v-if="open"
      :style="dropdownStyle"
      class="fixed z-[9999] rounded-md border border-border bg-background shadow-lg overflow-hidden"
    >
      <!-- Search input — only shown when searchFn is provided -->
      <div v-if="searchFn" class="flex items-center gap-2 px-3 py-2 border-b border-border">
        <Search :size="13" class="text-muted-foreground shrink-0" />
        <input
          ref="searchRef"
          v-model="query"
          class="flex-1 bg-transparent text-[13px] outline-none placeholder:text-muted-foreground"
          :placeholder="searchPlaceholder"
          @input="onSearch"
          @keydown.escape="open = false"
          @keydown.down.prevent="focusResult(0)"
        />
        <Loader2 v-if="searching" :size="13" class="text-muted-foreground animate-spin shrink-0" />
      </div>

      <!-- Results -->
      <ul class="max-h-52 overflow-y-auto py-1" role="listbox">
        <!-- loadFn: loading spinner -->
        <li v-if="loadFn && searching" class="px-3 py-3 text-[13px] text-muted-foreground text-center flex items-center justify-center gap-2">
          <Loader2 :size="13" class="animate-spin" /> Loading…
        </li>

        <template v-else>
          <!-- Search mode: empty states -->
          <template v-if="searchFn">
            <li
              v-if="!searching && results.length === 0 && query.length === 0"
              class="px-3 py-3 text-[13px] text-muted-foreground text-center"
            >
              Type to search…
            </li>
            <li
              v-if="!searching && results.length === 0 && query.length > 0"
              class="px-3 py-3 text-[13px] text-muted-foreground text-center"
            >
              No results for "{{ query }}".
            </li>
          </template>

          <!-- Static / loadFn mode: empty state -->
          <li
            v-if="!searchFn && displayOptions.length === 0"
            class="px-3 py-3 text-[13px] text-muted-foreground text-center"
          >
            No options available.
          </li>

          <!-- Option rows -->
          <li
            v-for="(opt, i) in displayOptions"
            :key="opt.value"
            :ref="(el) => { if (el) resultRefs[i] = el as HTMLElement }"
            role="option"
            :aria-selected="isSelected(opt.value)"
            class="flex items-center gap-2.5 px-3 py-2.5 cursor-pointer hover:bg-muted/60 transition-colors outline-none"
            :class="isSelected(opt.value) ? 'bg-muted/40' : ''"
            tabindex="-1"
            @mousedown.prevent="select(opt)"
            @keydown.enter.prevent="select(opt)"
            @keydown.down.prevent="focusResult(i + 1)"
            @keydown.up.prevent="focusResult(i - 1)"
          >
            <Check
              :size="13"
              class="shrink-0 transition-opacity"
              :class="isSelected(opt.value) ? 'text-primary opacity-100' : 'opacity-0'"
            />
            <div class="flex-1 min-w-0">
              <div class="text-[13px] font-medium truncate">{{ opt.label }}</div>
              <div v-if="opt.sublabel" class="text-muted-foreground font-mono text-[11px]">{{ opt.sublabel }}</div>
            </div>
          </li>
        </template>
      </ul>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick, onMounted, onUnmounted, reactive } from 'vue'
import { Search, X, Check, ChevronDown, Loader2 } from '@lucide/vue'

export interface DropdownOption {
  value: string
  label: string
  sublabel?: string
}

const props = withDefaults(defineProps<{
  modelValue?: string | string[]
  searchFn?: (q: string) => Promise<DropdownOption[]>
  loadFn?: () => Promise<DropdownOption[]>
  options?: DropdownOption[]
  multiple?: boolean
  placeholder?: string
  searchPlaceholder?: string
  disabled?: boolean
  initialItem?: DropdownOption | DropdownOption[]
  validator?: (value: string | string[]) => string | null
  decoration?: string
}>(), {
  multiple: false,
  placeholder: 'Select…',
  searchPlaceholder: 'Search…',
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: string | string[]]
  'change': [value: string | string[], option: DropdownOption | DropdownOption[]]
}>()

const containerRef = ref<HTMLElement>()
const searchRef = ref<HTMLInputElement>()
const open = ref(false)
const query = ref('')
const results = ref<DropdownOption[]>([])
const searching = ref(false)
const resultRefs = ref<HTMLElement[]>([])
const dropdownStyle = reactive({ top: '0px', left: '0px', width: '0px' })

const optionCache = ref<Map<string, DropdownOption>>(new Map())
const errorMessage = ref<string | null>(null)

const displayOptions = computed(() => {
  if (props.searchFn || props.loadFn) return results.value
  return props.options ?? []
})

function runValidator(value: string | string[]) {
  errorMessage.value = props.validator ? props.validator(value) : null
}

function validate(): boolean {
  const value = props.multiple
    ? (Array.isArray(props.modelValue) ? props.modelValue : [])
    : (props.modelValue ?? '')
  runValidator(value)
  return errorMessage.value === null
}

defineExpose({ validate })

const selectedValues = computed<string[]>(() => {
  if (!props.modelValue) return []
  return Array.isArray(props.modelValue) ? props.modelValue : [props.modelValue]
})

const selectedOptions = computed<DropdownOption[]>(() =>
  selectedValues.value.flatMap(v => {
    const opt = optionCache.value.get(v)
    return opt ? [opt] : []
  })
)

function isSelected(value: string) {
  return selectedValues.value.includes(value)
}

function select(opt: DropdownOption) {
  optionCache.value.set(opt.value, opt)
  if (props.multiple) {
    const current = [...selectedValues.value]
    const idx = current.indexOf(opt.value)
    if (idx === -1) current.push(opt.value)
    else current.splice(idx, 1)
    const selectedOpts = current.flatMap(v => { const o = optionCache.value.get(v); return o ? [o] : [] })
    emit('update:modelValue', current)
    emit('change', current, selectedOpts)
    runValidator(current)
  } else {
    emit('update:modelValue', opt.value)
    emit('change', opt.value, opt)
    runValidator(opt.value)
    open.value = false
  }
}

function deselect(value: string) {
  const next = selectedValues.value.filter(v => v !== value)
  emit('update:modelValue', next)
  runValidator(next)
}

function updateDropdownPosition() {
  if (!containerRef.value) return
  const rect = containerRef.value.getBoundingClientRect()
  dropdownStyle.top = `${rect.bottom + 4}px`
  dropdownStyle.left = `${rect.left}px`
  dropdownStyle.width = `${rect.width}px`
}

async function openDropdown() {
  updateDropdownPosition()
  open.value = true
  await nextTick()
  if (props.searchFn) searchRef.value?.focus()
  // loadFn: fetch once and cache — skip if already loaded
  if (props.loadFn && results.value.length === 0) {
    searching.value = true
    try {
      const data = await props.loadFn()
      results.value = data
      for (const opt of data) optionCache.value.set(opt.value, opt)
    } catch {
      results.value = []
    } finally {
      searching.value = false
    }
  }
}

let debounceTimer: ReturnType<typeof setTimeout> | null = null

function onSearch() {
  if (debounceTimer) clearTimeout(debounceTimer)
  if (!query.value.trim()) { results.value = []; return }
  debounceTimer = setTimeout(doSearch, 300)
}

async function doSearch() {
  if (!props.searchFn) return
  searching.value = true
  try {
    const data = await props.searchFn(query.value.trim())
    results.value = data
    for (const opt of data) optionCache.value.set(opt.value, opt)
  } catch {
    results.value = []
  } finally {
    searching.value = false
  }
}

function focusResult(index: number) {
  const el = resultRefs.value[Math.max(0, Math.min(index, resultRefs.value.length - 1))]
  el?.focus()
}

function onClickOutside(e: MouseEvent) {
  if (containerRef.value && !containerRef.value.contains(e.target as Node)) {
    open.value = false
  }
}

watch(open, (val) => {
  if (!val) {
    query.value = ''
    resultRefs.value = []
    // keep loadFn results cached — only clear search results
    if (!props.loadFn) results.value = []
  }
})

onMounted(() => {
  if (props.options) {
    for (const opt of props.options) optionCache.value.set(opt.value, opt)
  }
  if (props.initialItem) {
    const items = Array.isArray(props.initialItem) ? props.initialItem : [props.initialItem]
    for (const item of items) optionCache.value.set(item.value, item)
  }
  document.addEventListener('mousedown', onClickOutside)
  window.addEventListener('scroll', updateDropdownPosition, true)
  window.addEventListener('resize', updateDropdownPosition)
})
onUnmounted(() => {
  document.removeEventListener('mousedown', onClickOutside)
  window.removeEventListener('scroll', updateDropdownPosition, true)
  window.removeEventListener('resize', updateDropdownPosition)
})
</script>
