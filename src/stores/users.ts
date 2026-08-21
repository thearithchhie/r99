import { defineStore } from 'pinia'
import { ref } from 'vue'
import { fetchUsers, fetchUser } from '@/api/users'
import type { UserResponse, PageMeta } from '@/api/users'

export const useUsersStore = defineStore('users', () => {
  const users = ref<UserResponse[]>([])
  const meta = ref<PageMeta | null>(null)
  const selectedUser = ref<UserResponse | null>(null)
  const loading = ref(false)
  const detailLoading = ref(false)
  const error = ref<string | null>(null)

  async function loadUsers(page = 1) {
    loading.value = true
    error.value = null
    try {
      const data = await fetchUsers(page)
      users.value = data.users
      meta.value = data.meta
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Failed to load users'
    } finally {
      loading.value = false
    }
  }

  async function loadUser(uuid: string) {
    detailLoading.value = true
    error.value = null
    selectedUser.value = null
    try {
      selectedUser.value = await fetchUser(uuid)
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Failed to load user'
    } finally {
      detailLoading.value = false
    }
  }

  return { users, meta, selectedUser, loading, detailLoading, error, loadUsers, loadUser }
})