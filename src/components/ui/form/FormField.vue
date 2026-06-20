<script setup lang="ts" generic="TValue">
import { useField } from 'vee-validate'
import { computed, provide, reactive, toRef } from 'vue'
import { FORM_ITEM_INJECTION_KEY } from '.'

const props = defineProps<{ name: string }>()

const { value, errorMessage, handleChange, handleBlur, meta } = useField<TValue>(
  toRef(props, 'name'),
  undefined,
  { syncVModel: false, validateOnValueUpdate: false },
)

provide(FORM_ITEM_INJECTION_KEY, {
  name:      toRef(props, 'name') as any,
  valid:     computed(() => meta.valid) as any,
  isDirty:   computed(() => meta.dirty) as any,
  isTouched: computed(() => meta.touched) as any,
  error:     errorMessage,
})

const componentField = reactive({
  name: props.name,
  // modelValue is what shadcn <Input> expects as its v-model prop
  get modelValue() { return value.value as string | number | undefined },
  // update value without re-validating on every keystroke; validate on blur only
  onInput: (e: Event) => handleChange(e, false),
  onBlur:  handleBlur,
})
</script>

<template>
  <slot :component-field="componentField" :error-message="errorMessage" :meta="meta" />
</template>
