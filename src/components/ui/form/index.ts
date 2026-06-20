import type { InjectionKey, Ref } from 'vue'

export interface FormFieldContext {
  name: Ref<string>
  valid: Ref<boolean>
  isDirty: Ref<boolean>
  isTouched: Ref<boolean>
  error: Ref<string | undefined>
}

export const FORM_ITEM_INJECTION_KEY: InjectionKey<FormFieldContext> = Symbol('FormField')

export { default as FormField }       from './FormField.vue'
export { default as FormItem }        from './FormItem.vue'
export { default as FormLabel }       from './FormLabel.vue'
export { default as FormControl }     from './FormControl.vue'
export { default as FormDescription } from './FormDescription.vue'
export { default as FormMessage }     from './FormMessage.vue'
