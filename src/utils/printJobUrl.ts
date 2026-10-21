export type InvoiceJob = {
  type: "invoice";
  pageName: string;
  recipientName: string;
  phones: string[];
  locations: string[];
  guestService: boolean;
  virak: boolean;
  jt: boolean;
  currency: string;
  totalPrice: string;
};

export type StickerOrder = {
  customer_name: string;
  customer_phone: string;
  delivery_address: string | null;
  total_amount: number;
};

export type StickerJob = {
  type: "stickers";
  orders: StickerOrder[];
};

export type PrintJobData = InvoiceJob | StickerJob;

export function encodePrintJob(data: PrintJobData): string {
  return btoa(encodeURIComponent(JSON.stringify(data)));
}

export function decodePrintJob(encoded: string): PrintJobData | null {
  try {
    return JSON.parse(decodeURIComponent(atob(encoded)));
  } catch {
    return null;
  }
}

export function buildPrintJobUrl(data: PrintJobData): string {
  return `${window.location.origin}/print-job?d=${encodePrintJob(data)}`;
}
