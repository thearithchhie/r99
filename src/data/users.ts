export type UserRole = 'Owner' | 'Manager' | 'Staff' | 'Viewer'
export type UserStatus = 'Active' | 'Inactive'

export interface SystemUser {
  id: string
  name: string
  email: string
  password: string
  role: UserRole
  status: UserStatus
  lastLogin: Date | null
  customPerms?: Record<string, boolean>
}

export interface Discount {
  id: string
  code: string
  type: 'percent' | 'fixed' | 'shipping'
  value: number
  minOrder: number
  limit: number
  uses: number
  expiry: Date
  status: 'Active' | 'Expired' | 'Disabled'
  desc: string
}

export const SYSTEM_USERS: SystemUser[] = [
  { id: 'u1', name: 'Avery Quinn',   email: 'admin@r99.studio',  password: 'admin123',  role: 'Owner',   status: 'Active',   lastLogin: new Date(2026, 5, 19, 9, 14) },
  { id: 'u2', name: 'Jordan Lee',    email: 'staff@r99.studio',  password: 'staff123',  role: 'Staff',   status: 'Active',   lastLogin: new Date(2026, 5, 18, 14, 32) },
  { id: 'u3', name: 'Sam Rivera',    email: 'viewer@r99.studio', password: 'viewer123', role: 'Viewer',  status: 'Active',   lastLogin: null },
  { id: 'u4', name: 'Mia Thornton',  email: 'mia@r99.studio',   password: 'mia12345',  role: 'Manager', status: 'Active',   lastLogin: new Date(2026, 5, 17, 11, 5) },
  { id: 'u5', name: 'Kai Nakamura',  email: 'kai@r99.studio',   password: 'kai12345',  role: 'Staff',   status: 'Inactive', lastLogin: new Date(2026, 4, 30, 16, 48) },
]

export const DISCOUNTS: Discount[] = [
  { id: 'd1', code: 'WELCOME10', type: 'percent',  value: 10, minOrder: 0,   limit: 100, uses: 34,  expiry: new Date(2026, 8,  30), status: 'Active',  desc: 'New customer welcome' },
  { id: 'd2', code: 'SUMMER25',  type: 'percent',  value: 25, minOrder: 150, limit: 50,  uses: 12,  expiry: new Date(2026, 6,  31), status: 'Active',  desc: 'Summer sale' },
  { id: 'd3', code: 'FLAT20',    type: 'fixed',    value: 20, minOrder: 80,  limit: 0,   uses: 89,  expiry: new Date(2026, 5,  30), status: 'Expired', desc: 'Flat $20 off' },
  { id: 'd4', code: 'FREESHIP',  type: 'shipping', value: 0,  minOrder: 0,   limit: 200, uses: 156, expiry: new Date(2026, 11, 31), status: 'Active',  desc: 'Free shipping always' },
  { id: 'd5', code: 'VIP50',     type: 'percent',  value: 50, minOrder: 300, limit: 10,  uses: 3,   expiry: new Date(2026, 9,  15), status: 'Active',  desc: 'VIP customers only' },
]

export const CUSTOMERS = Array.from({ length: 12 }, (_, i) => {
  const names = ['Maya Reeves','Tom Ladner','Priya Shah','Jordan Avery','Noah Kim','Elena Ortiz','Liam Walsh','Sofia Marchetti','Wren Calloway','Hana Sato','Marcus Webb','Ada Nwosu']
  const name = names[i]
  return {
    id: 'c' + (i + 1),
    name,
    email: name.toLowerCase().replace(' ', '.') + '@email.com',
    orders: 1 + (i * 3 % 8),
    spent: 58 + i * 142,
    lastOrder: new Date(2026, 5, 19 - i * 2),
    status: i === 4 ? 'Inactive' : 'Active' as 'Active' | 'Inactive',
  }
})
