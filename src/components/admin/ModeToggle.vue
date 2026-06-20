<template>
  <Button variant="ghost" size="icon" class="h-8 w-8" aria-label="Toggle theme" @click="toggle">
    <Sun v-if="isDark" :size="16" />
    <Moon v-else :size="16" />
  </Button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useColorMode } from '@vueuse/core'
import { Sun, Moon } from '@lucide/vue'
import { Button } from '@/components/ui/button'

const mode = useColorMode({ attribute: 'class', initialValue: 'light' })
const isDark = computed(() => mode.store.value === 'dark')

function toggle() {
  mode.store.value = isDark.value ? 'light' : 'dark'
}
</script>
