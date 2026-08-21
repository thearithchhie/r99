import { ref } from 'vue'

export type DialogType = 'info' | 'success' | 'warning' | 'danger' | 'confirm'

export interface DialogOptions {
  type?: DialogType
  title: string
  message?: string
  confirmLabel?: string
  cancelLabel?: string
  noCancel?: boolean
  onConfirm?: () => void | Promise<void>
  onCancel?: () => void
}

// Module-level singleton — shared across all callers
const isOpen = ref(false)
const confirming = ref(false)
const opts = ref<DialogOptions>({ title: '' })

export function useDialog() {
  function open(options: DialogOptions) {
    opts.value = { type: 'info', ...options }
    isOpen.value = true
  }

  function close() {
    isOpen.value = false
    confirming.value = false
  }

  async function handleConfirm() {
    confirming.value = true
    try {
      await opts.value.onConfirm?.()
    } finally {
      confirming.value = false
      close()
    }
  }

  function handleCancel() {
    opts.value.onCancel?.()
    close()
  }

  return { isOpen, confirming, opts, open, close, handleConfirm, handleCancel }
}
