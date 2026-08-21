import { defineStore } from 'pinia'
import { ref } from 'vue'
import { fetchAuditLogs, type AuditLogResponse, type AuditLogListData } from '@/api/audit_logs'
import type { PageMeta } from '@/api/users'

export const useAuditLogsStore = defineStore('auditLogs', () => {
  const logs = ref<AuditLogResponse[]>([])
  const meta = ref<PageMeta | null>(null)
  const loading = ref(false)
  const error = ref('')

  async function loadLogs(page = 1) {
    loading.value = true
    error.value = ''
    try {
      const data: AuditLogListData = await fetchAuditLogs(page)
      logs.value = data.audit_logs
      meta.value = data.meta
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : 'Failed to load audit logs'
    } finally {
      loading.value = false
    }
  }

  return { logs, meta, loading, error, loadLogs }
})
