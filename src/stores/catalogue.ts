import { defineStore } from 'pinia'
import { ref } from 'vue'
import { PRODUCTS, type AdminProduct } from '@/data/products'

function load(): AdminProduct[] {
  try {
    const raw = localStorage.getItem('catalogue-products')
    if (raw) return JSON.parse(raw)
  } catch {}
  return PRODUCTS.map(p => ({ ...p }))
}

function deriveStatus(stock: number): AdminProduct['status'] {
  if (stock === 0) return 'Out of stock'
  if (stock <= 10) return 'Low draft'
  return 'Active'
}

export const useCatalogueStore = defineStore('catalogue', () => {
  const products = ref<AdminProduct[]>(load())

  function persist() { localStorage.setItem('catalogue-products', JSON.stringify(products.value)) }

  function add(data: Omit<AdminProduct, 'id' | 'tone' | 'status' | 'stock'>) {
    const tone = Math.floor(Math.random() * 6)
    products.value.push({
      ...data,
      id: `prod-${Date.now()}`,
      tone,
      stock: 0,
      status: 'Out of stock',
    })
    persist()
  }

  function update(id: string, patch: Partial<Omit<AdminProduct, 'id'>>) {
    const p = products.value.find(p => p.id === id)
    if (!p) return
    Object.assign(p, patch)
    if (patch.stock !== undefined) p.status = deriveStatus(p.stock)
    persist()
  }

  function remove(id: string) {
    products.value = products.value.filter(p => p.id !== id)
    persist()
  }

  function adjustStock(id: string, delta: number) {
    const p = products.value.find(p => p.id === id)
    if (!p) return
    p.stock = Math.max(0, p.stock + delta)
    p.status = deriveStatus(p.stock)
    persist()
  }

  return { products, add, update, remove, adjustStock }
})
