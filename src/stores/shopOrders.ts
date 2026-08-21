import { defineStore } from 'pinia'
import { ref, computed, toRaw } from 'vue'

export type DeliveryStatus = 'Pending' | 'Delivered' | 'Failed' | 'Returned'
export type ItemOutcome = 'pending' | 'delivered' | 'returned' | 'exchanged'

export interface ExchangeTarget {
  productId: string
  productName: string
  size: string
  color: string
  unitPrice: number
}

export interface OrderItem {
  productId: string
  productName: string
  size: string
  color: string
  unitPrice: number
  qty: number
  outcome: ItemOutcome
  exchangedTo?: ExchangeTarget
}

export function orderCharge(order: { totalPrice: number; items?: OrderItem[] }): number {
  if (!order.items?.length) return order.totalPrice
  const allReturned = order.items.every(i => i.outcome === 'returned')
  if (allReturned) return 2
  return order.items.reduce((sum, item) => {
    if (item.outcome === 'delivered') return sum + item.unitPrice * item.qty
    if (item.outcome === 'exchanged' && item.exchangedTo) return sum + item.exchangedTo.unitPrice * item.qty
    return sum
  }, 0)
}

export interface ShopOrder {
  id: string
  shop: string
  customerName: string
  phone: string
  location: string
  totalPrice: number
  deliverService: string
  chatRespondent: string
  outlet: string
  link: string
  date: Date
  status: DeliveryStatus
  note: string
  driverId: string
  deliveryFee: number    // variable per order — depends on distance
  items: OrderItem[]
}

function load(): ShopOrder[] {
  try {
    const raw = localStorage.getItem('shop-orders')
    if (!raw) return []
    return JSON.parse(raw).map((o: any) => ({ ...o, date: new Date(o.date) }))
  } catch { return [] }
}

export const useShopOrderStore = defineStore('shopOrders', () => {
  const orders = ref<ShopOrder[]>(load())

  function persist() { localStorage.setItem('shop-orders', JSON.stringify(toRaw(orders.value).map(o => toRaw(o)))) }

  const totalRevenue   = computed(() => orders.value.reduce((s, o) => s + o.totalPrice, 0))
  const deliveredRevenue = computed(() => orders.value.filter(o => o.status === 'Delivered').reduce((s, o) => s + o.totalPrice, 0))
  const pendingCount   = computed(() => orders.value.filter(o => o.status === 'Pending').length)
  const deliveredCount = computed(() => orders.value.filter(o => o.status === 'Delivered').length)
  const failedCount    = computed(() => orders.value.filter(o => o.status === 'Failed' || o.status === 'Returned').length)

  function addOrder(data: Omit<ShopOrder, 'id' | 'date' | 'status' | 'driverId' | 'deliveryFee' | 'items'>) {
    orders.value.unshift({
      ...data,
      id: `order-${Date.now()}`,
      date: new Date(),
      status: 'Pending',
      driverId: '',
      deliveryFee: 0,
      items: [],
    })
    persist()
  }

  function importOrders(incoming: ShopOrder[], replace: boolean) {
    if (replace) { orders.value = incoming }
    else {
      const ids = new Set(orders.value.map(o => o.id))
      orders.value = [...orders.value, ...incoming.filter(o => !ids.has(o.id))]
    }
    persist()
  }

  function patchOrder(id: string, patch: Partial<ShopOrder>) {
    const idx = orders.value.findIndex(o => o.id === id)
    if (idx !== -1) { orders.value[idx] = { ...toRaw(orders.value[idx]), ...patch }; persist() }
  }

  function updateStatus(id: string, status: DeliveryStatus)     { patchOrder(id, { status }) }
  function assignDriver(id: string, driverId: string)           { patchOrder(id, { driverId }) }
  function updateNote(id: string, note: string)                 { patchOrder(id, { note }) }
  function updateDeliveryFee(id: string, fee: number)           { patchOrder(id, { deliveryFee: Math.max(0, fee) }) }
  function updateItems(id: string, items: OrderItem[])          { patchOrder(id, { items }) }

  function clearAll() { orders.value = []; persist() }

  // Staff commission: only DELIVERED orders count ($0.50 each)
  function countByRespondent(statusFilter: DeliveryStatus | 'all' = 'Delivered'): Record<string, number> {
    const counts: Record<string, number> = {}
    for (const o of orders.value) {
      if (statusFilter !== 'all' && o.status !== statusFilter) continue
      const name = o.chatRespondent?.trim()
      if (name) counts[name] = (counts[name] ?? 0) + 1
    }
    return counts
  }

  // Driver stats: cash collected + delivery fee earned (variable per order)
  function driverStats(driverId: string): { delivered: number; failed: number; collected: number; deliveryFeeEarned: number } {
    const mine      = orders.value.filter(o => o.driverId === driverId)
    const delivered = mine.filter(o => o.status === 'Delivered')
    const failed    = mine.filter(o => o.status === 'Failed' || o.status === 'Returned')
    return {
      delivered:        delivered.length,
      failed:           failed.length,
      collected:        delivered.reduce((s, o) => s + orderCharge(o), 0),
      deliveryFeeEarned: delivered.reduce((s, o) => s + (o.deliveryFee ?? 0), 0),
    }
  }

  // Staff commission report
  function staffCommissionReport(rate = 0.5): { name: string; delivered: number; failed: number; commission: number }[] {
    const delivered: Record<string, number> = {}
    const failed:    Record<string, number> = {}
    for (const o of orders.value) {
      const name = o.chatRespondent?.trim()
      if (!name) continue
      if (o.status === 'Delivered') delivered[name] = (delivered[name] ?? 0) + 1
      else if (o.status === 'Failed' || o.status === 'Returned') failed[name] = (failed[name] ?? 0) + 1
    }
    const names = [...new Set([...Object.keys(delivered), ...Object.keys(failed)])]
    return names.map(name => ({
      name,
      delivered: delivered[name] ?? 0,
      failed:    failed[name]    ?? 0,
      commission: (delivered[name] ?? 0) * rate,
    }))
  }

  // Delivery report by driver — commission = sum of deliveryFee per delivered order
  function driverReport(): { driverId: string; delivered: number; failed: number; pending: number; collected: number; deliveryFeeEarned: number }[] {
    const map: Record<string, { delivered: number; failed: number; pending: number; collected: number; deliveryFeeEarned: number }> = {}
    for (const o of orders.value) {
      if (!o.driverId) continue
      if (!map[o.driverId]) map[o.driverId] = { delivered: 0, failed: 0, pending: 0, collected: 0, deliveryFeeEarned: 0 }
      if (o.status === 'Delivered') {
        map[o.driverId].delivered++
        map[o.driverId].collected        += orderCharge(o)
        map[o.driverId].deliveryFeeEarned += (o.deliveryFee ?? 0)
      } else if (o.status === 'Failed' || o.status === 'Returned') {
        map[o.driverId].failed++
      } else {
        map[o.driverId].pending++
      }
    }
    return Object.entries(map).map(([driverId, s]) => ({ driverId, ...s }))
  }

  return {
    orders, totalRevenue, deliveredRevenue, pendingCount, deliveredCount, failedCount,
    addOrder, importOrders, updateStatus, updateNote, updateDeliveryFee, updateItems, assignDriver, clearAll,
    countByRespondent, driverStats, staffCommissionReport, driverReport,
  }
})
