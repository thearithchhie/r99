import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUIStore = defineStore('ui', () => {
  const toast = ref('')
  const sidebarOpen = ref(false)
  let toastTimer = 0

  function showToast(msg: string, duration = 2500) {
    toast.value = msg
    clearTimeout(toastTimer)
    toastTimer = window.setTimeout(() => { toast.value = '' }, duration)
  }

  function openSidebar()  { sidebarOpen.value = true }
  function closeSidebar() { sidebarOpen.value = false }

  return { toast, sidebarOpen, showToast, openSidebar, closeSidebar }
})
