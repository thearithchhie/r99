<template>
  <AdminLayout>
    <div class="fade p-5">
      <div class="flex justify-between items-center mb-4">
        <p class="text-muted-foreground text-[13.5px]">
          {{ store.meta ? store.meta.total + ' entries' : '' }}
        </p>
      </div>

      <!-- Error -->
      <div
        v-if="store.error"
        class="flex items-center gap-2 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-[13px] text-red-600 mb-4"
      >
        <AlertTriangle :size="14" class="shrink-0" />{{ store.error }}
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Context</TableHead>
              <TableHead>Description</TableHead>
              <TableHead>User</TableHead>
              <TableHead>Operator</TableHead>
              <TableHead>IP</TableHead>
              <TableHead>Created at</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <!-- Loading skeleton -->
            <TableRow v-if="store.loading" v-for="n in 8" :key="'skel-' + n">
              <TableCell colspan="6">
                <div class="h-4 rounded bg-muted animate-pulse w-full" />
              </TableCell>
            </TableRow>

            <!-- Data rows -->
            <template v-if="!store.loading">
              <TableRow v-for="log in store.logs" :key="log.id">
                <TableCell>
                  <span class="inline-flex items-center rounded-md px-2 py-0.5 text-[11.5px] font-semibold bg-secondary text-secondary-foreground">
                    {{ log.context }}
                  </span>
                </TableCell>
                <TableCell class="text-[13px] max-w-[300px]">
                  <span class="line-clamp-2">{{ log.description }}</span>
                </TableCell>
                <TableCell class="text-[13px]">
                  <div v-if="log.user_name" class="flex items-center gap-2">
                    <UserAvatar :name="log.user_name" :size="26" />
                    <span>{{ log.user_name }}</span>
                  </div>
                  <span v-else class="text-muted-foreground">—</span>
                </TableCell>
                <TableCell class="text-muted-foreground text-[13px]">{{ log.operator }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px] font-mono">{{ log.ip }}</TableCell>
                <TableCell class="text-muted-foreground text-[12.5px]">{{ fmtDate(log.created_at) }}</TableCell>
              </TableRow>

              <TableRow v-if="!store.loading && store.logs.length === 0 && !store.error">
                <TableCell colspan="6" class="text-center text-muted-foreground py-10 text-sm">
                  No audit logs found.
                </TableCell>
              </TableRow>
            </template>
          </TableBody>
        </Table>
      </Card>

      <!-- Pagination -->
      <div v-if="store.meta && store.meta.total_pages > 1" class="flex flex-col items-center gap-2 mt-4">
        <Pagination :page="currentPage" :total-pages="store.meta.total_pages" @change="changePage" />
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { AlertTriangle } from '@lucide/vue'
import AdminLayout from '@/components/admin/AdminLayout.vue'
import UserAvatar from '@/components/admin/UserAvatar.vue'
import { Card } from '@/components/ui/card'
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '@/components/ui/table'
import Pagination from '@/components/admin/Pagination.vue'
import { fmtDate } from '@/utils/format'
import { useAuditLogsStore } from '@/stores/auditLogs'

const store = useAuditLogsStore()
const currentPage = ref(1)

onMounted(() => store.loadLogs(currentPage.value))

function changePage(page: number) {
  currentPage.value = page
  store.loadLogs(page)
}
</script>
