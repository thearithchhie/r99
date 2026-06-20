<script setup lang="ts">
import { inject } from 'vue'
import { FORM_ITEM_INJECTION_KEY } from '.'

const field = inject(FORM_ITEM_INJECTION_KEY)
</script>
<template>
  <slot
    :id="String(field?.name?.value)"
    :aria-describedby="field?.error?.value ? `${field.name.value}-error` : undefined"
    :aria-invalid="!!field?.error?.value"
  />
</template>
