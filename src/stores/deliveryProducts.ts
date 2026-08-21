import { defineStore } from 'pinia'
import { ref } from 'vue'

export interface DeliveryProduct {
  id: string
  name: string
  size: string
  price: number
  stock: number
}

function load(): DeliveryProduct[] {
  try {
    const raw = localStorage.getItem('delivery-products')
    return raw ? JSON.parse(raw) : []
  } catch { return [] }
}

export const useDeliveryProductStore = defineStore('deliveryProducts', () => {
  const products = ref<DeliveryProduct[]>(load())

  function persist() { localStorage.setItem('delivery-products', JSON.stringify(products.value)) }

  function add(data: Omit<DeliveryProduct, 'id'>) {
    products.value.push({ id: `dp-${Date.now()}`, ...data })
    persist()
  }

  function update(id: string, patch: Partial<Omit<DeliveryProduct, 'id'>>) {
    const p = products.value.find(p => p.id === id)
    if (p) { Object.assign(p, patch); persist() }
  }

  function remove(id: string) {
    products.value = products.value.filter(p => p.id !== id)
    persist()
  }

  function adjustStock(id: string, delta: number) {
    const p = products.value.find(p => p.id === id)
    if (p) { p.stock = Math.max(0, p.stock + delta); persist() }
  }

  return { products, add, update, remove, adjustStock }
})
