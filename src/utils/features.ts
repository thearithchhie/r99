const KEY = 'r99-app-features'

export interface FeatureFlag {
  label: string
  desc: string
  group: string
  on: boolean
}

export const DEFAULT_FLAGS: Record<string, FeatureFlag> = {
  announcementBar:  { label: 'Announcement bar',    desc: 'Show promotional banner at top of storefront',       group: 'Storefront', on: true  },
  wishlist:         { label: 'Wishlist',             desc: 'Allow customers to save products to wishlist',       group: 'Storefront', on: true  },
  productReviews:   { label: 'Product reviews',      desc: 'Show review section on product pages',               group: 'Storefront', on: true  },
  sizeGuide:        { label: 'Size guide',           desc: 'Show size guide modal on product pages',             group: 'Storefront', on: true  },
  relatedProducts:  { label: 'Related products',     desc: 'Show "Complete the look" section',                   group: 'Storefront', on: true  },
  newsletter:       { label: 'Newsletter signup',    desc: 'Show newsletter form in footer',                     group: 'Storefront', on: false },
  lowStockBadge:    { label: 'Low stock badges',     desc: 'Show low stock warnings on product pages',           group: 'Storefront', on: true  },
  freeShipping:     { label: 'Free shipping logic',  desc: 'Apply free shipping over $150 threshold',            group: 'Commerce',   on: true  },
  taxCalculation:   { label: 'Tax calculation',      desc: 'Add 8% tax at checkout',                            group: 'Commerce',   on: true  },
  cartDrawer:       { label: 'Cart drawer',          desc: 'Use slide-in drawer instead of cart page',           group: 'Commerce',   on: true  },
  lowStockAlerts:   { label: 'Low stock alerts',     desc: 'Show low stock alerts on admin dashboard',           group: 'Admin',      on: true  },
  fbChatPayroll:    { label: 'FB Chat Payroll link', desc: 'Show payroll tool link in admin navigation',         group: 'Admin',      on: false },
}

export function loadFlags(): Record<string, FeatureFlag> {
  try {
    const raw = localStorage.getItem(KEY)
    if (raw) return { ...DEFAULT_FLAGS, ...JSON.parse(raw) }
  } catch {}
  return { ...DEFAULT_FLAGS }
}

export function saveFlags(flags: Record<string, FeatureFlag>): void {
  localStorage.setItem(KEY, JSON.stringify(flags))
}
