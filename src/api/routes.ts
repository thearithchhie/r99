export const ROUTES = {
  auth: {
    login: "/api/v1/auth/login",
    register: "/api/v1/auth/register",
  },
  users: {
    me: "/api/v1/users/me",
    list: "/api/v1/users",
    create: "/api/v1/users",
    detail: (uuid: string) => `/api/v1/users/${uuid}`,
    update: (uuid: string) => `/api/v1/users/${uuid}`,
    delete: (uuid: string) => `/api/v1/users/${uuid}`,
  },
  roles: {
    list: "/api/v1/roles",
    create: "/api/v1/roles",
    detail: (uuid: string) => `/api/v1/roles/${uuid}`,
    update: (uuid: string) => `/api/v1/roles/${uuid}`,
    updatePermissions: (uuid: string) => `/api/v1/roles/${uuid}/permissions`,
  },
  permissions: {
    list: "/api/v1/permissions",
  },
  categories: {
    list: "/api/v1/product-categories",
  },
  lines: {
    list: "/api/v1/product-lines",
    create: "/api/v1/product-lines",
  },
  models: {
    list: "/api/v1/product-models",
    detail: (uuid: string) => `/api/v1/product-models/${uuid}`,
    variants: (id: number) => `/api/v1/product-models/${id}/variants`,
  },
  products: {
    list: "/api/v1/products",
    create: "/api/v1/products",
    detail: (uuid: string) => `/api/v1/products/${uuid}`,
    search: "/api/v1/products/search",
    images: (uuid: string) => `/api/v1/products/${uuid}/images`,
  },
  stocks: {
    list: "/api/v1/stock",
    movements: "/api/v1/stock/movements",
  },
  customers: {
    list: "/api/v1/customers",
    search: "/api/v1/customers/search",
    create: "/api/v1/customers",
    detail: (uuid: string) => `/api/v1/customers/${uuid}`,
    update: (uuid: string) => `/api/v1/customers/${uuid}`,
    delete: (uuid: string) => `/api/v1/customers/${uuid}`,
  },
  drivers: {
    list: "/api/v1/drivers",
    create: "/api/v1/drivers",
    detail: (uuid: string) => `/api/v1/drivers/${uuid}`,
    delete: (uuid: string) => `/api/v1/drivers/${uuid}`,
  },
  orders: {
    list: "/api/v1/orders",
    create: "/api/v1/orders",
    detail: (uuid: string) => `/api/v1/orders/${uuid}`,
    updateStatus: (uuid: string) => `/api/v1/orders/${uuid}/status`,
    partialReturn: (uuid: string) => `/api/v1/orders/${uuid}/partial-return`,
  },
  deliveries: {
    list: "/api/v1/deliveries",
    create: "/api/v1/deliveries",
    detail: (uuid: string) => `/api/v1/deliveries/${uuid}`,
    updateStatus: (uuid: string) => `/api/v1/deliveries/${uuid}/status`,
  },
  payrolls: {
    list: "/api/v1/payrolls",
    generate: "/api/v1/payrolls/generate",
    detail: (uuid: string) => `/api/v1/payrolls/${uuid}`,
    markPaid: (uuid: string) => `/api/v1/payrolls/${uuid}/paid`,
  },
} as const;
