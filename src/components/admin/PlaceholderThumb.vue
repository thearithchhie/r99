<template>
  <div class="thumb" :style="{ width: size + 'px', height: size + 'px', background: bg }" />
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{ tone?: number; size?: number }>(), { tone: 0, size: 38 })

const TONES = [
  ['#e9e1d4','#ded2bf'],
  ['#e6dccb','#d9cab2'],
  ['#efe7d8','#e4d8c4'],
  ['#dfd0b8','#d3bfa0'],
  ['#e6e4cf','#dcd8bd'],
  ['#dfd5c2','#d2c4ab'],
]

const bg = computed(() => {
  const [a, b] = TONES[props.tone % TONES.length]
  return `repeating-linear-gradient(135deg, ${a} 0 7px, ${b} 7px 14px)`
})
</script>

<style scoped>
.thumb {
  border-radius: 7px;
  flex-shrink: 0;
  border: 1px solid var(--border);
}
</style>
