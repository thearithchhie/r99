import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { UserRole } from '../data/users'

export interface SessionUser {
  id: string
  name: string
  email: string
  role: UserRole
  loginAt: number
  customPerms?: Record<string, boolean>
}

const KEY = 'r99-session'

export const useSessionStore = defineStore('session', () => {
  const user = ref<SessionUser | null>(null)

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

  return { user, init, login, logout }
})
