import { getCurrentUserApi } from '@/api/auth'
import { useSessionStore } from '@/stores/session'

export async function syncCurrentUser(): Promise<void> {
  const session = useSessionStore()
  const t = session.token
  if (!t) return
  try {
    const me = await getCurrentUserApi(t)
    session.setUser({ ...me, loginAt: session.user?.loginAt ?? Date.now() })
  } catch {
    // 401 is handled by the http interceptor — clears session and redirects to login
  }
}
