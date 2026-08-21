import { createRouter, createWebHistory } from 'vue-router'
import { useSessionStore } from '../stores/session'
import { ADMIN_ROUTES } from './admin-routes'

const R = ADMIN_ROUTES

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: R.dashboard },
    { path: R.login,       component: () => import('../views/admin/Login.vue'),                  meta: { public: true } },
    { path: R.dashboard,   component: () => import('../views/admin/Dashboard.vue'),              meta: { layout: 'admin' } },
    { path: R.orders,      component: () => import('../views/admin/Orders.vue'),                 meta: { layout: 'admin' } },
    { path: R.discounts,   component: () => import('../views/admin/Discounts.vue'),              meta: { layout: 'admin' } },
    { path: R.customers,   component: () => import('../views/admin/Customers.vue'),              meta: { layout: 'admin' } },
    { path: R.reports.list, component: () => import('../views/admin/reports/index.vue'),          meta: { layout: 'admin' } },
    { path: R.products.list,         component: () => import('../views/admin/products/index.vue'),       meta: { layout: 'admin' } },
    { path: `${R.products.list}/:uuid`, component: () => import('../views/admin/products/detail.vue'),    meta: { layout: 'admin' } },
    { path: R.models.list,     component: () => import('../views/admin/Models.vue'),              meta: { layout: 'admin' } },
    { path: `${R.models.list}/:uuid`, component: () => import('../views/admin/models/detail.vue'), meta: { layout: 'admin' } },
    { path: R.stock.list,      component: () => import('../views/admin/stock/index.vue'),         meta: { layout: 'admin' } },
    { path: R.stock.movements, component: () => import('../views/admin/stock/movements.vue'),     meta: { layout: 'admin' } },
    { path: R.users.list,              component: () => import('../views/admin/users/index.vue'),        meta: { layout: 'admin' } },
    { path: `${R.users.list}/:uuid`,   component: () => import('../views/admin/users/detail.vue'),       meta: { layout: 'admin' } },
    { path: `${R.users.list}/:uuid/edit`, component: () => import('../views/admin/users/edit.vue'),      meta: { layout: 'admin' } },
    { path: R.roles.list,              component: () => import('../views/admin/roles/index.vue'),        meta: { layout: 'admin' } },
    { path: `${R.roles.list}/:uuid`,   component: () => import('../views/admin/roles/detail.vue'),       meta: { layout: 'admin' } },
    { path: R.permissions, component: () => import('../views/admin/permissions/index.vue'),      meta: { layout: 'admin' } },
    { path: R.auditLogs,   component: () => import('../views/admin/audit_logs/index.vue'),       meta: { layout: 'admin' } },
    { path: R.deliveries,  component: () => import('../views/admin/Deliveries.vue'),             meta: { layout: 'admin' } },
    { path: R.drivers,     component: () => import('../views/admin/Drivers.vue'),                meta: { layout: 'admin' } },
    { path: R.payroll,     component: () => import('../views/admin/Payroll.vue'),                meta: { layout: 'admin' } },
    { path: `${R.settings}/:section?`, component: () => import('../views/admin/Settings.vue'),  meta: { layout: 'admin' } },
    { path: '/admin/activity/:type?',  component: () => import('../views/admin/ActivityLog.vue'), meta: { layout: 'admin' } },
  ],
})

router.beforeEach((to) => {
  const session = useSessionStore()
  if (!to.meta.public && !session.user) {
    return R.login
  }
})

export default router
