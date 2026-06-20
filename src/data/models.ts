export interface ModelColorVariant {
  color: string
  hex: string
  stock: number
  images: { id: number; label: string }[]
}

export interface ModelSizeVariant {
  size: string
  colors: ModelColorVariant[]
}

export interface StockModel {
  id: string
  code: string
  name: string
  sizes: ModelSizeVariant[]
}

export const MODELS: StockModel[] = [
  {
    id: 'model-282', code: '282', name: 'Oversized Washed Tee',
    sizes: [
      { size: 'S', colors: [
        { color: 'Black', hex: '#1a1a1a', stock: 24, images: [{ id: 1, label: 'black · front' }, { id: 2, label: 'black · back' }] },
        { color: 'White', hex: '#f5f5f0', stock: 18, images: [{ id: 3, label: 'white · front' }] },
        { color: 'Sage',  hex: '#8fa68a', stock: 4,  images: [] },
        { color: 'Red',   hex: '#c0392b', stock: 0,  images: [] },
      ]},
      { size: 'M', colors: [
        { color: 'Black', hex: '#1a1a1a', stock: 42, images: [{ id: 4, label: 'black · front' }] },
        { color: 'White', hex: '#f5f5f0', stock: 31, images: [{ id: 5, label: 'white · front' }] },
        { color: 'Sage',  hex: '#8fa68a', stock: 12, images: [] },
        { color: 'Red',   hex: '#c0392b', stock: 3,  images: [] },
      ]},
      { size: 'L', colors: [
        { color: 'Black', hex: '#1a1a1a', stock: 38, images: [] },
        { color: 'White', hex: '#f5f5f0', stock: 22, images: [] },
        { color: 'Sage',  hex: '#8fa68a', stock: 5,  images: [] },
        { color: 'Red',   hex: '#c0392b', stock: 0,  images: [] },
      ]},
      { size: 'XL', colors: [
        { color: 'Black', hex: '#1a1a1a', stock: 15, images: [] },
        { color: 'White', hex: '#f5f5f0', stock: 9,  images: [] },
        { color: 'Sage',  hex: '#8fa68a', stock: 0,  images: [] },
        { color: 'Red',   hex: '#c0392b', stock: 0,  images: [] },
      ]},
    ],
  },
  {
    id: 'model-92', code: '92', name: 'Relaxed Linen Trousers',
    sizes: [
      { size: 'S', colors: [
        { color: 'Ecru',  hex: '#e8dfc8', stock: 14, images: [{ id: 6, label: 'ecru · front' }] },
        { color: 'Navy',  hex: '#1e2e4a', stock: 8,  images: [{ id: 7, label: 'navy · front' }] },
        { color: 'Camel', hex: '#c49a5a', stock: 2,  images: [] },
      ]},
      { size: 'M', colors: [
        { color: 'Ecru',  hex: '#e8dfc8', stock: 22, images: [] },
        { color: 'Navy',  hex: '#1e2e4a', stock: 17, images: [] },
        { color: 'Camel', hex: '#c49a5a', stock: 6,  images: [] },
      ]},
      { size: 'L', colors: [
        { color: 'Ecru',  hex: '#e8dfc8', stock: 19, images: [] },
        { color: 'Navy',  hex: '#1e2e4a', stock: 5,  images: [] },
        { color: 'Camel', hex: '#c49a5a', stock: 0,  images: [] },
      ]},
      { size: 'XL', colors: [
        { color: 'Ecru',  hex: '#e8dfc8', stock: 7, images: [] },
        { color: 'Navy',  hex: '#1e2e4a', stock: 3, images: [] },
        { color: 'Camel', hex: '#c49a5a', stock: 0, images: [] },
      ]},
    ],
  },
]
