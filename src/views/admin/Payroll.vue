<template>
  <AdminLayout>
    <div class="fade" style="padding: 22px">
      <div class="card" style="padding: 32px; text-align: center; max-width: 480px; margin: 60px auto">
        <div style="font-size: 32px; margin-bottom: 16px">🧾</div>
        <h2 style="font-size: 20px; font-weight: 600; margin-bottom: 8px">FB Chat Payroll</h2>
        <p class="muted" style="font-size: 14px; line-height: 1.6; margin-bottom: 20px">
          The payroll tool is a standalone module. Open it in a new tab to manage staff payroll, hours, and disbursements.
        </p>
        <a class="btn btn-primary" href="/FB Chat Payroll.html" target="_blank" rel="noopener" style="display: inline-flex; gap: 8px">
          <ExternalLink :size="15" /> Open Payroll Tool
        </a>
      </div>
    </div>
  </AdminLayout>
</template>

<script setup lang="ts">
import { ExternalLink } from '@lucide/vue'
import AdminLayout from '../../components/admin/AdminLayout.vue'
</script>
