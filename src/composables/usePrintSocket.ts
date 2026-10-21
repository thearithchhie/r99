import { ref } from "vue";
import { Client } from "@stomp/stompjs";
import SockJS from "sockjs-client";
import { useSessionStore } from "@/stores/session";
import { useUIStore } from "@/stores/ui";
import { apiClient } from "@/api/http";
import { getPrintStyles } from "@/utils/printStyles";
import { buildInvoiceCard, buildStickerCard } from "@/utils/printBuilders";
import type { PrintJobData } from "@/utils/printJobUrl";

// SockJS needs http:// / https:// (not ws://), same origin → works via Vite proxy and ngrok
function getSockJsUrl(): string {
  const explicit = import.meta.env.VITE_WS_URL as string | undefined;
  if (explicit) return explicit.replace(/^ws/, "http");
  return `${window.location.protocol}//${window.location.host}/ws`;
}

// Singleton — one connection shared across all component mounts
let _client: Client | null = null;
export const printSocketConnected = ref(false);

// ─── Sender (any device) ─────────────────────────────────────────────────────
// Plain HTTP POST — no WebSocket connection required on the sending device.
export async function sendPrintJob(job: PrintJobData): Promise<void> {
  try {
    await apiClient.post("/api/v1/print/push", job);
    useUIStore().showToast("Sent to Mac — printing…", "success");
  } catch {
    useUIStore().showToast("Failed to send print job", "danger");
  }
}

// ─── Receiver (Mac print station only) ───────────────────────────────────────
function buildPrintHtml(job: PrintJobData, styles: string): string {
  const body = document.createElement("body");
  if (job.type === "invoice") {
    body.appendChild(buildInvoiceCard(job));
  } else {
    job.orders.forEach((o, i) => {
      body.appendChild(buildStickerCard(o));
      if (i < job.orders.length - 1) {
        const pb = document.createElement("div");
        pb.className = "page-break";
        body.appendChild(pb);
      }
    });
  }
  const title = job.type === "invoice" ? "Invoice" : "Stickers";
  return `<!DOCTYPE html><html lang="km"><head><meta charset="UTF-8"><title>${title}</title><style>${styles}</style></head>${body.outerHTML}</html>`;
}

async function handlePrintJob(job: PrintJobData): Promise<void> {
  const styles = await getPrintStyles();
  const html = buildPrintHtml(job, styles);
  try {
    const res = await fetch("http://localhost:3001/print", {
      method: "POST",
      headers: { "Content-Type": "text/html; charset=utf-8" },
      body: html,
    });
    if (res.ok) {
      const label =
        job.type === "invoice"
          ? job.recipientName || "Invoice"
          : `${job.orders.length} sticker${job.orders.length !== 1 ? "s" : ""}`;
      useUIStore().showToast(`Printing: ${label}…`, "success");
    }
  } catch {
    // Should not reach here — this function only runs on the Mac where localhost:3001 is reachable
  }
}

export function usePrintSocket() {
  function connect() {
    if (_client?.active) return;
    const session = useSessionStore();
    if (!session.token) return;

    _client = new Client({
      webSocketFactory: () => new SockJS(getSockJsUrl()),
      connectHeaders: { Authorization: `Bearer ${session.token}` },
      reconnectDelay: 5_000,
      onConnect: () => {
        printSocketConnected.value = true;
        getPrintStyles(); // pre-warm font cache
        _client!.subscribe("/topic/print", (msg) => {
          try {
            handlePrintJob(JSON.parse(msg.body) as PrintJobData);
          } catch (e) {
            console.error("[PrintSocket] failed to handle print job:", e);
          }
        });
      },
      onDisconnect: () => { printSocketConnected.value = false; },
      onStompError:  () => { printSocketConnected.value = false; },
    });
    _client.activate();
  }

  function disconnect() {
    _client?.deactivate();
    _client = null;
    printSocketConnected.value = false;
  }

  return { connect, disconnect };
}
