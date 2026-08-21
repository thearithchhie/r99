/**
 * Centralised admin route paths.
 * Import ADMIN_ROUTES wherever you need to navigate or check permissions,
 * so every path is defined in one place and easy to gate per role/module.
 */
export const ADMIN_ROUTES = {
  login: "/admin/login",
  dashboard: "/admin",

  orders: "/admin/orders",
  discounts: "/admin/discounts",
  customers: "/admin/customers",
  reports: {
    list: "/admin/reports",
  },

  products: {
    list: "/admin/products",
    detail: (uuid: string) => `/admin/products/${uuid}`,
  },
  models: {
    list: "/admin/models",
    detail: (uuid: string) => `/admin/models/${uuid}`,
  },
  stock: {
    list:      "/admin/stock",
    movements: "/admin/stock/movements",
  },

  users: {
    list: "/admin/users",
    detail: (uuid: string) => `/admin/users/${uuid}`,
    edit: (uuid: string) => `/admin/users/${uuid}/edit`,
  },

  roles: {
    list: "/admin/roles",
    detail: (uuid: string) => `/admin/roles/${uuid}`,
  },

  permissions: "/admin/permissions",
  auditLogs: "/admin/audit-logs",

  deliveries: "/admin/deliveries",
  drivers: "/admin/drivers",
  payroll: "/admin/payroll",
  settings: "/admin/settings",
} as const;
