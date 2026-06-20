import type { UserRole } from './users'

export interface Permission {
  key: string
  label: string
  group: string
}

export const PERMISSIONS: Permission[] = [
  { key: 'view_dashboard',   label: 'View dashboard',    group: 'Dashboard' },
  { key: 'view_orders',      label: 'View orders',       group: 'Orders' },
  { key: 'manage_orders',    label: 'Manage orders',     group: 'Orders' },
  { key: 'refund_orders',    label: 'Refund orders',     group: 'Orders' },
  { key: 'view_products',    label: 'View products',     group: 'Products' },
  { key: 'manage_products',  label: 'Manage products',   group: 'Products' },
  { key: 'view_catalogue',   label: 'View catalogue',    group: 'Catalogue' },
  { key: 'manage_catalogue', label: 'Manage catalogue',  group: 'Catalogue' },
  { key: 'view_stock',       label: 'View stock',        group: 'Catalogue' },
  { key: 'edit_stock',       label: 'Edit stock',        group: 'Catalogue' },
  { key: 'view_customers',   label: 'View customers',    group: 'Customers' },
  { key: 'view_reports',     label: 'View reports',      group: 'Reports' },
  { key: 'export_reports',   label: 'Export reports',    group: 'Reports' },
  { key: 'manage_discounts', label: 'Manage discounts',  group: 'Marketing' },
  { key: 'manage_users',     label: 'Manage users',      group: 'Team' },
  { key: 'view_activity',    label: 'View activity log', group: 'Team' },
  { key: 'view_settings',    label: 'View settings',     group: 'Settings' },
  { key: 'edit_settings',    label: 'Edit settings',     group: 'Settings' },
]

const ALL = PERMISSIONS.map(p => p.key)

export const ROLE_PERMISSIONS: Record<UserRole, Record<string, boolean>> = {
  Owner:   Object.fromEntries(ALL.map(k => [k, true])),
  Manager: Object.fromEntries(ALL.map(k => [k, ['view_dashboard','view_orders','manage_orders','refund_orders','view_products','manage_products','view_catalogue','manage_catalogue','view_stock','edit_stock','view_customers','view_reports','export_reports','manage_discounts','view_activity','view_settings'].includes(k)])),
  Staff:   Object.fromEntries(ALL.map(k => [k, ['view_dashboard','view_orders','manage_orders','view_customers'].includes(k)])),
  Viewer:  Object.fromEntries(ALL.map(k => [k, ['view_dashboard','view_reports'].includes(k)])),
}

export const ROLE_NAV_PERMISSIONS: Record<UserRole, Record<string, boolean>> = {
  Owner:   { dashboard: true, orders: true, discounts: true, products: true, models: true, stock: true, customers: true, reports: true, users: true, activity: true, 'act-users': true, 'act-orders': true, 'act-products': true, 'act-stock': true, 'act-log': true, 'act-discounts': true, settings: true },
  Manager: { dashboard: true, orders: true, discounts: true, products: true, models: true, stock: true, customers: true, reports: true, users: false, activity: true, 'act-users': true, 'act-orders': true, 'act-products': true, 'act-stock': true, 'act-log': true, 'act-discounts': true, settings: false },
  Staff:   { dashboard: true, orders: true, discounts: false, products: false, models: false, stock: false, customers: true, reports: false, users: false, activity: false, 'act-users': false, 'act-orders': false, 'act-products': false, 'act-stock': false, 'act-log': false, 'act-discounts': false, settings: false },
  Viewer:  { dashboard: true, orders: false, discounts: false, products: false, models: false, stock: false, customers: false, reports: true, users: false, activity: false, 'act-users': false, 'act-orders': false, 'act-products': false, 'act-stock': false, 'act-log': false, 'act-discounts': false, settings: false },
}

export const ROLE_DESCRIPTIONS: Record<UserRole, string> = {
  Owner:   'Full access to all features and settings. Cannot be modified.',
  Manager: 'Can manage products, orders, and discounts. Cannot manage users or settings.',
  Staff:   'Can view and process orders and view customers.',
  Viewer:  'Read-only access to dashboard and reports.',
}

export const ACTIVITY_LOG = [
  { id: 'a1',  user: 'Avery Quinn',  type: 'order',   text: 'Marked order R99-104820 as Shipped',             time: new Date(Date.now() - 5   * 60000) },
  { id: 'a2',  user: 'Jordan Lee',   type: 'order',   text: 'Added note to order R99-104799',                 time: new Date(Date.now() - 18  * 60000) },
  { id: 'a3',  user: 'Avery Quinn',  type: 'product', text: 'Created product "Summer Linen Shirt"',           time: new Date(Date.now() - 42  * 60000) },
  { id: 'a4',  user: 'Mia Thornton', type: 'stock',   text: 'Updated stock: Code 282 / M / Black → 45',      time: new Date(Date.now() - 67  * 60000) },
  { id: 'a5',  user: 'Avery Quinn',  type: 'user',    text: 'Created user kai@r99.studio (Staff)',            time: new Date(Date.now() - 110 * 60000) },
  { id: 'a6',  user: 'Jordan Lee',   type: 'login',   text: 'Signed in from Chrome / Windows',               time: new Date(Date.now() - 145 * 60000) },
  { id: 'a7',  user: 'Mia Thornton', type: 'order',   text: 'Refunded order R99-104785 · $195.00',           time: new Date(Date.now() - 200 * 60000) },
  { id: 'a8',  user: 'Avery Quinn',  type: 'discount',text: 'Created discount code SUMMER25 (25% off)',       time: new Date(Date.now() - 310 * 60000) },
  { id: 'a9',  user: 'Jordan Lee',   type: 'stock',   text: 'Updated stock: Code 92 / S / Ecru → 14',        time: new Date(Date.now() - 420 * 60000) },
  { id: 'a10', user: 'Avery Quinn',  type: 'product', text: 'Edited product "Pleated Wool Trouser" — price', time: new Date(Date.now() - 580 * 60000) },
  { id: 'a11', user: 'Sam Rivera',   type: 'login',   text: 'Signed in from Safari / iPhone',               time: new Date(Date.now() - 720 * 60000) },
  { id: 'a12', user: 'Avery Quinn',  type: 'user',    text: 'Updated permissions for Jordan Lee',            time: new Date(Date.now() - 900 * 60000) },
  { id: 'a13', user: 'Mia Thornton', type: 'product', text: 'Deleted product "Silk Bandana"',               time: new Date(Date.now() - 1100 * 60000) },
  { id: 'a14', user: 'Jordan Lee',   type: 'order',   text: 'Fulfilled order R99-104763 · 2 items',         time: new Date(Date.now() - 1440 * 60000) },
  { id: 'a15', user: 'Avery Quinn',  type: 'discount',text: 'Deactivated code FLAT20 (expired)',            time: new Date(Date.now() - 2100 * 60000) },
]
