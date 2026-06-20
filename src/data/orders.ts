import { PRODUCTS } from './products'

export interface OrderItem {
  id: string
  name: string
  tone: number
  qty: number
  price: number
  size: string
  color: string
}

export interface Order {
  id: string
  customer: string
  email: string
  city: string
  items: OrderItem[]
  total: number
  status: 'Paid' | 'Processing' | 'Shipped' | 'Delivered' | 'Refunded'
  date: Date
  ship: 'Standard' | 'Express'
  tracking?: string
}

export const STATUS_COLORS: Record<string, { color: string; bg: string }> = {
  Paid:       { color: 'var(--green)',  bg: 'var(--green-bg)' },
  Processing: { color: 'var(--amber)',  bg: 'var(--amber-bg)' },
  Shipped:    { color: 'var(--blue)',   bg: 'var(--blue-bg)' },
  Delivered:  { color: 'var(--violet)', bg: 'var(--violet-bg)' },
  Refunded:   { color: 'var(--red)',    bg: 'var(--red-bg)' },
}

const NAMES = ['Maya Reeves','Tom Ladner','Priya Shah','Jordan Avery','Noah Kim','Elena Ortiz','Liam Walsh','Sofia Marchetti','Wren Calloway','Hana Sato','Marcus Webb','Ada Nwosu','Iris Lindqvist','Felix Moreau','Dahlia Brooks']
const CITIES = ['New York, US','London, UK','Toronto, CA','Paris, FR','Berlin, DE','Stockholm, SE','Melbourne, AU','Tokyo, JP']
const STATUS_KEYS: Order['status'][] = ['Paid','Processing','Shipped','Delivered','Refunded']

function pick<T>(arr: readonly T[], seed: number): T { return arr[seed % arr.length] }

export const ORDERS: Order[] = Array.from({ length: 14 }, (_, i) => {
  const n = 14 - i
  const itemCount = 1 + ((i * 3) % 3)
  const items: OrderItem[] = Array.from({ length: itemCount }, (_, j) => {
    const p = PRODUCTS[(i * 5 + j * 3) % PRODUCTS.length]
    const qty = 1 + ((i + j) % 2)
    return {
      id: p.id, name: p.name, tone: p.tone, qty, price: p.price,
      size: ['XS','S','M','L','XL'][(i + j) % 5],
      color: ['Bone','Camel','Stone','Black','Sage'][(i + j) % 5],
    }
  })
  const total = items.reduce((s, it) => s + it.price * it.qty, 0)
  const status = i === 0 ? 'Processing' : pick(STATUS_KEYS, i * 2 + 1)
  const d = new Date(2026, 5, 19 - i, 9 + i % 9, (i * 13) % 60)
  return {
    id: 'R99-' + (104820 - n * 7),
    customer: pick(NAMES, i),
    email: pick(NAMES, i).toLowerCase().replace(' ', '.') + '@email.com',
    city: pick(CITIES, i * 3),
    items,
    total: total + 12,
    status,
    date: d,
    ship: i % 3 === 0 ? 'Express' : 'Standard',
  }
})

export const REVENUE_SERIES = [4.2, 3.1, 5.6, 4.9, 6.2, 5.1, 7.3, 6.8, 5.4, 8.1, 7.6, 9.2]

export const KPIS = [
  { key: 'rev', label: "Revenue",          value: '$84,219', delta: 12.4, up: true,  icon: 'DollarSign', sub: 'vs. last 30 days' },
  { key: 'ord', label: 'Orders',           value: '1,284',   delta: 8.1,  up: true,  icon: 'ShoppingCart', sub: 'vs. last 30 days' },
  { key: 'aov', label: 'Avg. order value', value: '$172',    delta: 3.2,  up: true,  icon: 'TrendingUp', sub: 'vs. last 30 days' },
  { key: 'cvr', label: 'Conversion rate',  value: '3.18%',   delta: 0.6,  up: false, icon: 'Percent', sub: 'vs. last 30 days' },
]
