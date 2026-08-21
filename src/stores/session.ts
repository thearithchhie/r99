import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export type AppRole = 'ADMIN' | 'STAFF'

export interface SessionUser {
  uuid: string
  name: string
  phone: string
  role: AppRole
  loginAt: number
  token?: string
  customPerms?: Record<string, boolean>
}

const KEY = 'r99-session'

export const useSessionStore = defineStore('session', () => {
  const user = ref<SessionUser | null>(null)

  const token = computed(() => user.value?.token ?? null)

  function init() {
    const raw = localStorage.getItem(KEY) || sessionStorage.getItem(KEY)
    if (raw) {
      try { user.value = JSON.parse(raw) } catch {}
    }
  }

  function login(u: SessionUser, remember = false) {
    user.value = u
    const json = JSON.stringify(u)
    if (remember) localStorage.setItem(KEY, json)
    else sessionStorage.setItem(KEY, json)
  }

  function logout() {
    user.value = null
    localStorage.removeItem(KEY)
    sessionStorage.removeItem(KEY)
  }

  return { user, token, init, login, logout }
})
