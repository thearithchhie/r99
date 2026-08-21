import { defineStore } from "pinia";
import { ref } from "vue";
import { useDialog } from "@/composables/useDialog";

export type ToastType = "info" | "success" | "warning" | "danger";

export interface ToastState {
  msg: string;
  type: ToastType;
}

export const useUIStore = defineStore("ui", () => {
  const toast = ref<ToastState | null>(null);
  const sidebarOpen = ref(false);
  let toastTimer = 0;

  function showToast(msg: string, type: ToastType = "success", duration = 2500) {
    if (type === "danger") {
      useDialog().open({
        type: "danger",
        title: "Something went wrong",
        message: msg,
        confirmLabel: "OK",
        noCancel: true,
      });
      return;
    }
    toast.value = { msg, type };
    clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => {
      toast.value = null;
    }, duration);
  }

  function openSidebar() { sidebarOpen.value = true; }
  function closeSidebar() { sidebarOpen.value = false; }

  return { toast, sidebarOpen, showToast, openSidebar, closeSidebar };
});
