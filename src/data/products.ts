export interface AdminProduct {
  id: string
  name: string
  sku: string
  cat: 'Women' | 'Men' | 'Accessories' | 'Outerwear'
  line: string
  price: number
  cost: number
  stock: number
  tone: number
  status: 'Active' | 'Out of stock' | 'Low draft'
  linkedModel?: string
}

export const PRODUCTS: AdminProduct[] = [
  { id: 'linen-shirt',   name: 'Relaxed Linen Shirt',          sku: 'RW-LIN-01', cat: 'Women', line: 'Shirting',   price: 128, cost: 41,  stock: 86,  tone: 2, status: 'Active' },
  { id: 'wool-trouser',  name: 'Pleated Wool Trouser',          sku: 'RW-WOL-02', cat: 'Women', line: 'Tailoring',  price: 195, cost: 68,  stock: 34,  tone: 5, status: 'Active',        linkedModel: 'model-92' },
  { id: 'cashmere-crew', name: 'Featherweight Cashmere Crew',   sku: 'RW-CAS-03', cat: 'Women', line: 'Knitwear',   price: 240, cost: 92,  stock: 7,   tone: 0, status: 'Active' },
  { id: 'cotton-tee',    name: 'Heavy Cotton Tee',              sku: 'RW-COT-04', cat: 'Women', line: 'Essentials', price: 58,  cost: 14,  stock: 240, tone: 4, status: 'Active',        linkedModel: 'model-282' },
  { id: 'silk-dress',    name: 'Bias-Cut Silk Dress',           sku: 'RW-SIL-05', cat: 'Women', line: 'Occasion',   price: 268, cost: 96,  stock: 0,   tone: 3, status: 'Out of stock' },
  { id: 'denim-jacket',  name: 'Workwear Denim Jacket',         sku: 'RW-DEN-06', cat: 'Women', line: 'Outerwear',  price: 178, cost: 59,  stock: 52,  tone: 1, status: 'Active' },
  { id: 'oxford-shirt',  name: 'Garment-Dyed Oxford',           sku: 'RM-OXF-07', cat: 'Men',   line: 'Shirting',   price: 138, cost: 44,  stock: 120, tone: 2, status: 'Active' },
  { id: 'merino-polo',   name: 'Merino Knit Polo',              sku: 'RM-MER-08', cat: 'Men',   line: 'Knitwear',   price: 165, cost: 57,  stock: 9,   tone: 5, status: 'Active' },
  { id: 'pleated-chino', name: 'Pleated Cotton Chino',          sku: 'RM-CHI-09', cat: 'Men',   line: 'Tailoring',  price: 145, cost: 46,  stock: 73,  tone: 0, status: 'Active' },
  { id: 'field-jacket',  name: 'Cotton Field Jacket',           sku: 'RM-FLD-10', cat: 'Men',   line: 'Outerwear',  price: 285, cost: 104, stock: 18,  tone: 1, status: 'Active' },
  { id: 'lounge-pant',   name: 'Brushed Lounge Pant',           sku: 'RM-LNG-11', cat: 'Men',   line: 'Essentials', price: 98,  cost: 27,  stock: 155, tone: 4, status: 'Active' },
  { id: 'wool-coat',     name: 'Double-Face Wool Coat',         sku: 'RM-COA-12', cat: 'Men',   line: 'Outerwear',  price: 420, cost: 162, stock: 4,   tone: 3, status: 'Low draft' },
]

export const CATEGORIES = ['Women', 'Men', 'Accessories', 'Outerwear'] as const
