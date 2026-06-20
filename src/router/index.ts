import { createRouter, createWebHistory } from 'vue-router'
import { useSessionStore } from '../stores/session'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', redirect: '/admin' },
    { path: '/admin/login', component: () => import('../views/admin/Login.vue'), meta: { public: true } },
    { path: '/admin',               component: () => import('../views/admin/Dashboard.vue'),  meta: { layout: 'admin' } },
    { path: '/admin/orders',        component: () => import('../views/admin/Orders.vue'),     meta: { layout: 'admin' } },
    { path: '/admin/discounts',     component: () => import('../views/admin/Discounts.vue'),  meta: { layout: 'admin' } },
    { path: '/admin/customers',     component: () => import('../views/admin/Customers.vue'),  meta: { layout: 'admin' } },
    { path: '/admin/reports',       component: () => import('../views/admin/Reports.vue'),    meta: { layout: 'admin' } },
    { path: '/admin/products',      component: () => import('../views/admin/Products.vue'),   meta: { layout: 'admin' } },
    { path: '/admin/models',        component: () => import('../views/admin/Models.vue'),     meta: { layout: 'admin' } },
    { path: '/admin/stock',         component: () => import('../views/admin/Stock.vue'),      meta: { layout: 'admin' } },
    { path: '/admin/users',         component: () => import('../views/admin/Users.vue'),      meta: { layout: 'admin' } },
    { path: '/admin/roles',         component: () => import('../views/admin/Roles.vue'),      meta: { layout: 'admin' } },
    { path: '/admin/permissions',   component: () => import('../views/admin/Permissions.vue'),meta: { layout: 'admin' } },
    { path: '/admin/activity/:type?', component: () => import('../views/admin/ActivityLog.vue'), meta: { layout: 'admin' } },
    { path: '/admin/settings/:section?', component: () => import('../views/admin/Settings.vue'), meta: { layout: 'admin' } },
    { path: '/admin/payroll',       component: () => import('../views/admin/Payroll.vue'),    meta: { layout: 'admin' } },
  ],
})

router.beforeEach((to) => {
  const session = useSessionStore()
  if (!to.meta.public && !session.user) {
    return '/admin/login'
  }
})

export default router
