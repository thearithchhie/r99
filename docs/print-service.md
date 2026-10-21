# Print Service

## Overview

The print service is a small Node.js HTTP server that runs locally on the Mac connected to the physical printer. It bridges the gap between any device in the store (iPad, phone) and the thermal printer — without any browser print dialogs.

Run it with:

```bash
npm run print-service

# target a specific printer by name
PRINTER_NAME="MyThermal_Printer" npm run print-service
```

---

## Why it exists

Browsers cannot send jobs directly to a physical printer silently. `window.print()` always shows a dialog and requires the user to confirm. This service bypasses that entirely:

- Printing is **automatic and silent** — no dialog, no user interaction on the Mac
- Works from **any device** — an iPad on the shop floor can trigger a print on the Mac
- Respects exact **thermal paper size** (`58mm × 102mm`) via CSS `@page` in the print styles

---

## How the full flow works

```
Any device (iPad / phone / browser)
  │
  │  HTTP POST /api/v1/print/push   (sends PrintJobData JSON)
  ▼
Backend (Spring Boot)
  │
  │  WebSocket push → /topic/print
  ▼
Mac browser tab (subscribed via usePrintSocket)
  │
  │  HTTP POST http://localhost:3001/print   (sends rendered HTML)
  ▼
print-service.js (Node.js, port 3001)
  │
  ├─ writes HTML to /tmp/r99-print-<id>.html
  ├─ runs headless Chrome  →  /tmp/r99-print-<id>.pdf
  ├─ sends PDF to printer  via  lp -d <printer>
  └─ cleans up temp files
```

---

## Two print job types

Both are defined in `src/utils/printJobUrl.ts` as `PrintJobData`:

| Type | Description |
|---|---|
| `invoice` | Single invoice card — page name, recipient name, phones, locations, delivery fee, service flags (VAT / J&T / guest service) |
| `stickers` | One or more sticker cards — one per order, printed with page breaks between them |

HTML for both is built in `src/utils/printBuilders.ts` using DOM APIs (no template strings), then styled by `src/utils/printStyles.ts`.

---

## Sending a print job (any device)

Import `sendPrintJob` from `src/composables/usePrintSocket.ts`:

```ts
import { sendPrintJob } from "@/composables/usePrintSocket"
import type { PrintJobData } from "@/utils/printJobUrl"

const job: PrintJobData = {
  type: "invoice",
  pageName: "R99 Studio",
  recipientName: "John Doe",
  phones: ["012 345 678"],
  locations: ["Phnom Penh"],
  guestService: true,
  virak: false,
  jt: true,
  currency: "$",
  totalPrice: "12.50",
}

await sendPrintJob(job)
```

This POSTs the job to the backend. No WebSocket connection is needed on the sending device.

---

## Receiving / connecting the Mac

Call `usePrintSocket().connect()` once on the Mac print station (done inside `AdminLayout`). This opens a STOMP WebSocket to the backend and subscribes to `/topic/print`. When a job arrives it is handled automatically.

```ts
import { usePrintSocket, printSocketConnected } from "@/composables/usePrintSocket"

const { connect, disconnect } = usePrintSocket()
connect()

// reactive status — use in UI to show connected/disconnected indicator
console.log(printSocketConnected.value)
```

The connection is a **singleton** — calling `connect()` multiple times is safe, it reuses the existing client.

---

## print-service.js internals

| Step | Detail |
|---|---|
| HTTP server | `http.createServer` on `127.0.0.1:3001` (localhost only) |
| Chrome detection | Scans common macOS paths; throws if not found |
| HTML → PDF | `chrome --headless --print-to-pdf` with `--no-pdf-header-footer` |
| PDF → printer | `lp -d <printer> <pdf>` via macOS CUPS |
| Printer detection | Uses `PRINTER_NAME` env var → CUPS default → first available from `lpstat -a` |
| Temp files | Written to `os.tmpdir()`, always cleaned up in `finally` |

---

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `PRINTER_NAME` | *(auto-detect)* | Force a specific CUPS printer name |
| `VITE_WS_URL` | *(same origin)* | Override WebSocket URL (e.g. for ngrok tunnels) |
| `VITE_API_BASE_URL` | *(same origin)* | Backend base URL used by Axios |

---

## Troubleshooting

**Chrome not found**
Install Google Chrome, or set the path manually in `CHROME_CANDIDATES` inside `scripts/print-service.js`.

**No printer found**
Add a printer in macOS System Settings → Printers & Scanners, then restart the service. Or run with `PRINTER_NAME="YourPrinter" npm run print-service`. List available printers with `lpstat -a`.

**WebSocket not connecting**
Check that `VITE_WS_URL` points to the correct backend and that the backend WebSocket endpoint (`/ws`) is reachable. The client retries automatically every 5 seconds.

**Print job sent but nothing prints**
Confirm the Mac print-service is running (`curl http://localhost:3001/`) and that `printSocketConnected` is `true` in the UI.
