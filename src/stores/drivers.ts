import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface Driver {
  id: string
  name: string
  phone: string
  status: 'Active' | 'Inactive'
  commissionRate: number   // $ per successful delivery
}

export interface Settlement {
  id: string
  driverId: string
  amount: number
  date: Date
  note: string
}

function loadDrivers(): Driver[] {
  try {
    const raw = localStorage.getItem('drivers')
    return raw ? JSON.parse(raw) : []
  } catch { return [] }
}

function loadSettlements(): Settlement[] {
  try {
    const raw = localStorage.getItem('driver-settlements')
    if (!raw) return []
    return JSON.parse(raw).map((s: any) => ({ ...s, date: new Date(s.date) }))
  } catch { return [] }
}

export const useDriverStore = defineStore('drivers', () => {
  const drivers     = ref<Driver[]>(loadDrivers())
  const settlements = ref<Settlement[]>(loadSettlements())

  function persist() {
    localStorage.setItem('drivers', JSON.stringify(drivers.value))
    localStorage.setItem('driver-settlements', JSON.stringify(settlements.value))
  }

  const active = computed(() => drivers.value.filter(d => d.status === 'Active'))

  function add(name: string, phone: string, commissionRate = 0.5) {
    drivers.value.push({ id: Date.now().toString(), name, phone, status: 'Active', commissionRate })
    persist()
  }

  function update(id: string, patch: Partial<Omit<Driver, 'id'>>) {
    const d = drivers.value.find(d => d.id === id)
    if (d) { Object.assign(d, patch); persist() }
  }

  function remove(id: string) {
    drivers.value     = drivers.value.filter(d => d.id !== id)
    settlements.value = settlements.value.filter(s => s.driverId !== id)
    persist()
  }

  // Settlement: driver pays shop
  function addSettlement(driverId: string, amount: number, note = '') {
    settlements.value.push({
      id: Date.now().toString(),
      driverId,
      amount,
      date: new Date(),
      note,
    })
    persist()
  }

  function removeSettlement(id: string) {
    settlements.value = settlements.value.filter(s => s.id !== id)
    persist()
  }

  // How much a driver has settled with the shop
  function settledAmount(driverId: string): number {
    return settlements.value.filter(s => s.driverId === driverId).reduce((s, p) => s + p.amount, 0)
  }

  function driverSettlements(driverId: string): Settlement[] {
    return settlements.value.filter(s => s.driverId === driverId).sort((a, b) => b.date.getTime() - a.date.getTime())
  }

  return { drivers, settlements, active, add, update, remove, addSettlement, removeSettlement, settledAmount, driverSettlements }
})
