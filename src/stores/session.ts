import { defineStore } from 'pinia'
import { ref } from 'vue'

export type AppRole = 'ADMIN' | 'STAFF'

export interface SessionUser {
  uuid: string
  name: string
  phone: string
  role: AppRole
  loginAt: number
  permissions: Record<string, string[]>
}

const TOKEN_KEY = 'access_token'
const USER_KEY = 'current_user'

export const useSessionStore = defineStore('session', () => {
  const user = ref<SessionUser | null>(null)
  const token = ref<string | null>(null)

  function init() {
    token.value = localStorage.getItem(TOKEN_KEY)
    const raw = localStorage.getItem(USER_KEY)
    if (raw) {
      try { user.value = JSON.parse(raw) } catch {}
    }
  }

  function login(accessToken: string, userData: SessionUser) {
    token.value = accessToken
    user.value = userData
    localStorage.setItem(TOKEN_KEY, accessToken)
    localStorage.setItem(USER_KEY, JSON.stringify(userData))
  }

  function setUser(userData: SessionUser) {
    user.value = userData
    localStorage.setItem(USER_KEY, JSON.stringify(userData))
  }

  function logout() {
    token.value = null
    user.value = null
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_KEY)
  }

  function can(module: string, action: string): boolean {
    return user.value?.permissions?.[module]?.includes(action) ?? false
  }

  return { user, token, init, login, setUser, logout, can }
})
