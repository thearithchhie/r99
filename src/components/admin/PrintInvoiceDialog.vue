<template>
  <Dialog :open="open" @update:open="(v) => !v && $emit('close')">
    <DialogContent class="max-w-3xl p-0 gap-0 overflow-hidden">
      <DialogHeader class="px-6 pt-5 pb-4 border-b">
        <DialogTitle>Print Invoice</DialogTitle>
      </DialogHeader>

      <div class="flex overflow-y-auto max-h-[68vh]">
        <!-- Form -->
        <div class="flex-1 p-6 space-y-4 border-r min-w-0">
          <div class="space-y-1.5">
            <Label
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
              >Facebook Page</Label
            >
            <Input v-model="form.pageName" placeholder="R99 / R99-II" />
          </div>

          <div class="space-y-1.5">
            <Label
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
              >Customer Name</Label
            >
            <Input v-model="form.recipientName" placeholder="Customer name" />
          </div>

          <div class="space-y-1.5">
            <Label
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
              >Phone Numbers</Label
            >
            <div v-for="(_, i) in form.phones" :key="i" class="flex gap-2">
              <Input v-model="form.phones[i]" placeholder="0xx xxx xxx" />
              <Button
                variant="ghost"
                size="icon"
                class="shrink-0 h-9 w-9"
                @click="removePhone(i)"
              >
                <X :size="14" />
              </Button>
            </div>
            <Button
              variant="outline"
              size="sm"
              class="w-full text-xs"
              @click="addPhone"
              >+ Add Phone</Button
            >
          </div>

          <div class="space-y-1.5">
            <Label
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
              >Location</Label
            >
            <div v-for="(_, i) in form.locations" :key="i" class="flex gap-2">
              <Input v-model="form.locations[i]" placeholder="Address line" />
              <Button
                variant="ghost"
                size="icon"
                class="shrink-0 h-9 w-9"
                @click="removeLocation(i)"
              >
                <X :size="14" />
              </Button>
            </div>
            <Button
              variant="outline"
              size="sm"
              class="w-full text-xs"
              @click="addLocation"
              >+ Add Location</Button
            >
          </div>

          <div class="space-y-1.5">
            <Label
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
              >Delivery Service</Label
            >
            <div class="flex flex-col gap-2 pt-0.5">
              <label
                class="flex items-center gap-2 text-sm cursor-pointer khmer"
              >
                <input
                  type="checkbox"
                  v-model="form.guestService"
                  class="rounded"
                />
                សេវាខាងភ្ញៀវ
              </label>
              <label class="flex items-center gap-2 text-sm cursor-pointer">
                <input type="checkbox" v-model="form.virak" class="rounded" />
                VAT
              </label>
              <label class="flex items-center gap-2 text-sm cursor-pointer">
                <input type="checkbox" v-model="form.jt" class="rounded" />
                J&amp;T
              </label>
            </div>
          </div>

          <div class="flex gap-2">
            <div class="space-y-1.5 w-20">
              <Label
                class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
                >Currency</Label
              >
              <Input v-model="form.currency" placeholder="$" />
            </div>
            <div class="space-y-1.5 flex-1">
              <Label
                class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground"
                >Total Price</Label
              >
              <Input v-model="form.totalPrice" placeholder="0.00" />
            </div>
          </div>
        </div>

        <!-- Preview -->
        <div class="py-6 flex flex-col shrink-0 bg-muted/30">
          <div
            class="text-[10px] font-semibold uppercase tracking-widest text-muted-foreground mb-3 mx-6 text-center"
          >
            Preview
          </div>
          <div class="inv-card khmer">
            <!-- Page header row -->
            <div class="inv-hrow">
              <img :src="urlFb" width="18" height="18" />
              <span>ឈ្មោះផេកៈ {{ form.pageName || "R99" }}</span>
            </div>
            <!-- Sender phone rows -->
            <div class="inv-sender-label">
              <img :src="urlPhone" width="18" height="18" />
              <span>លេខទូរស័ព្ទអ្នកផ្ញើរ ឬ លុយ</span>
            </div>
            <div class="inv-sender-phone">097 71 56 486</div>

            <!-- Customer name -->
            <div class="inv-sec-hdr">
              <img :src="urlUser" width="18" height="18" />
              <span>ឈ្មោះអតិថិជន</span>
            </div>
            <div class="inv-val">{{ form.recipientName || "-" }}</div>

            <!-- Phone -->
            <div class="inv-sec-hdr">
              <img :src="urlPhone" width="18" height="18" />
              <span>លេខទូរស័ព្ទអ្នកទទួល</span>
            </div>
            <template v-if="form.phones.length === 0">
              <div class="inv-val inv-val-phone">-</div>
            </template>
            <div
              v-for="(p, i) in form.phones"
              :key="i"
              class="inv-val inv-val-phone"
            >
              {{ p || "-" }}
            </div>

            <!-- Location -->
            <div class="inv-sec-hdr">
              <img :src="urlPin" width="18" height="18" />
              <span>ទីតាំង</span>
            </div>
            <template v-if="form.locations.length === 0">
              <div class="inv-val inv-val-loc">-</div>
            </template>
            <div
              v-for="(l, i) in form.locations"
              :key="i"
              class="inv-val inv-val-loc"
            >
              {{ l || "-" }}
            </div>

            <!-- Delivery row -->
            <div class="inv-drow">
              <span class="inv-drow-left">
                <img :src="urlTruck" width="16" height="16" />
                <span>សេវាដឹក</span>
              </span>
              <span class="inv-drow-amt"
                >តម្លៃ: {{ form.currency }}{{ form.totalPrice || "0" }}</span
              >
            </div>

            <!-- Chips -->
            <div class="inv-chips">
              <div class="inv-chip">
                <div class="inv-chk">{{ form.guestService ? "✓" : "" }}</div>
                <span class="khmer">សេវា<br />ខាងភ្ញៀវ</span>
              </div>
              <div class="inv-chip">
                <div class="inv-chk">{{ form.virak ? "✓" : "" }}</div>
                <span>VAT</span>
              </div>
              <div class="inv-chip">
                <div class="inv-chk">{{ form.jt ? "✓" : "" }}</div>
                <span>J&amp;T</span>
              </div>
            </div>

            <div class="inv-footer">សូមអរគុណសម្រាប់ការគាំទ្រ</div>
          </div>
        </div>
      </div>

      <div class="flex justify-end gap-2 px-6 py-4 border-t">
        <Button variant="outline" @click="$emit('close')">Cancel</Button>
        <Button @click="doPrint"
          ><Printer :size="14" class="mr-1.5" />Print</Button
        >
      </div>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { reactive, watch } from "vue";
import { PRINT_STYLES } from "@/utils/printStyles";
import IC_FB from "@/assets/icon/svg/fb.svg?raw";
import IC_PHONE from "@/assets/icon/svg/phone.svg?raw";
import IC_PIN from "@/assets/icon/svg/pin.svg?raw";
import IC_TRUCK from "@/assets/icon/svg/truck.svg?raw";
import IC_USER from "@/assets/icon/svg/user.svg?raw";
import urlFb from "@/assets/icon/svg/fb.svg";
import urlPhone from "@/assets/icon/svg/phone.svg";
import urlPin from "@/assets/icon/svg/pin.svg";
import urlTruck from "@/assets/icon/svg/truck.svg";
import urlUser from "@/assets/icon/svg/user.svg";
import { X, Printer } from "@lucide/vue";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import type { OrderResponse } from "@/api/orders";
import { searchCustomers } from "@/api/customers";

const props = defineProps<{ open: boolean; order: OrderResponse | null }>();
const emit = defineEmits<{ close: [] }>();

const form = reactive({
  pageName: "",
  recipientName: "",
  phones: [""] as string[],
  locations: [""] as string[],
  guestService: false,
  virak: false,
  jt: false,
  currency: "$",
  totalPrice: "",
});

watch(
  () => props.order,
  async (order) => {
    if (!order) return;
    form.recipientName = order.customer_name;
    form.totalPrice = String(order.total_amount);
    form.phones = [order.customer_phone];
    form.locations = [""];
    form.guestService = false;
    form.virak = false;
    form.jt = false;
    // pageName kept across orders — user sets it once

    // pre-fill location from customer profile
    try {
      const results = await searchCustomers(order.customer_phone);
      const customer = results[0];
      if (customer) {
        form.locations = customer.address ? [customer.address] : [""];
      }
    } catch { /* silent — user can fill manually */ }
  },
  { immediate: true },
);

function addPhone() {
  form.phones.push("");
}
function removePhone(i: number) {
  form.phones.splice(i, 1);
}
function addLocation() {
  form.locations.push("");
}
function removeLocation(i: number) {
  form.locations.splice(i, 1);
}

type PrintData = {
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

function doPrint() {
  const phones = form.phones.filter(Boolean);
  const locations = form.locations.filter(Boolean);
  printWithIframe(
    buildPrintHTML({
      pageName: form.pageName || "R99",
      recipientName: form.recipientName || "-",
      phones: phones.length ? phones : ["-"],
      locations: locations.length ? locations : ["-"],
      guestService: form.guestService,
      virak: form.virak,
      jt: form.jt,
      currency: form.currency,
      totalPrice: form.totalPrice || "0",
    }),
  );
}

function printWithIframe(html: string) {
  const iframe = document.createElement("iframe");
  iframe.style.cssText =
    "position:fixed;left:-9999px;top:-9999px;width:58mm;height:102mm;border:0";
  document.body.appendChild(iframe);

  const win = iframe.contentWindow;
  const doc = iframe.contentDocument;
  if (!win || !doc) return;

  doc.write(html.replace(/<script[\s\S]*?<\/script>/gi, ""));
  doc.close();

  doc.fonts.ready.then(() => {
    win.print();
    win.addEventListener("afterprint", () => iframe.remove(), { once: true });
    setTimeout(() => iframe.remove(), 30000);
  });
}

// ─── DOM builder helpers ──────────────────────────────────────────────────────

function el(tag: string, className?: string): HTMLElement {
  const node = document.createElement(tag);
  if (className) node.className = className;
  return node;
}

function text(tag: string, content: string, className?: string): HTMLElement {
  const node = el(tag, className);
  node.textContent = content;
  return node;
}

function svgIcon(raw: string): Element {
  const div = document.createElement("div");
  div.innerHTML = raw;
  const svg = div.firstElementChild!;
  svg.setAttribute("width", "9pt");
  svg.setAttribute("height", "9pt");
  svg.setAttribute("fill", "currentColor");
  svg.setAttribute("class", "icon");
  return svg;
}

function iconRow(
  className: string,
  icon: Element,
  content: string,
): HTMLElement {
  const div = el("div", className);
  div.append(icon, document.createTextNode(content));
  return div;
}

// ─── Invoice section builders ─────────────────────────────────────────────────

function buildSectionHeader(title: string, icon: Element): HTMLElement {
  const hdr = el("div", "sec-hdr");
  hdr.append(icon, text("span", title));
  return hdr;
}

function buildValueRows(values: string[], modifier?: string): DocumentFragment {
  const frag = document.createDocumentFragment();
  values.forEach((v) => {
    frag.appendChild(
      text("div", v, modifier ? `sec-val ${modifier}` : "sec-val"),
    );
  });
  return frag;
}

function buildDeliveryRow(currency: string, totalPrice: string): HTMLElement {
  const row = el("div", "drow");
  const left = el("span", "drow-left");
  left.append(svgIcon(IC_TRUCK), document.createTextNode(" សេវាដឹក"));
  row.append(left, text("span", `តម្លៃ: ${currency}${totalPrice}`, "drow-amt"));
  return row;
}

function buildChip(
  label: string,
  checked: boolean,
  khmer = false,
): HTMLElement {
  const chip = el("div", "chip");
  const chk = el("div", "chk");
  if (checked) chk.textContent = "✓";

  const span = el("span", khmer ? "klabel" : undefined);
  const lines = label.split("\n");
  lines.forEach((line, i) => {
    if (i > 0) span.appendChild(document.createElement("br"));
    span.appendChild(document.createTextNode(line));
  });

  chip.append(chk, span);
  return chip;
}

function buildChips(d: PrintData): HTMLElement {
  const chips = el("div", "chips");
  chips.append(
    buildChip("សេវា\nខាងភ្ញៀវ", d.guestService, true),
    buildChip("VAT", d.virak),
    buildChip("J&T", d.jt),
  );
  return chips;
}

function buildInvoiceCard(d: PrintData): HTMLElement {
  const card = el("div", "card");
  card.append(
    iconRow("hrow", svgIcon(IC_FB), `ឈ្មោះផេកៈ ${d.pageName}`),
    iconRow("sender-label", svgIcon(IC_PHONE), "លេខទូរស័ព្ទអ្នកផ្ញើរ ឬ វេរលុយ"),
    text("div", "097 71 56 486", "sender-phone"),
    buildSectionHeader("ឈ្មោះអតិថិជន", svgIcon(IC_USER)),
    text("div", d.recipientName, "sec-val"),
    buildSectionHeader("លេខទូរស័ព្ទអ្នកទទួល", svgIcon(IC_PHONE)),
    buildValueRows(d.phones, "phone"),
    buildSectionHeader("ទីតាំង", svgIcon(IC_PIN)),
    buildValueRows(d.locations, "loc"),
    buildDeliveryRow(d.currency, d.totalPrice),
    buildChips(d),
  );
  card.appendChild(text("div", "សូមអរគុណសម្រាប់ការគាំទ្រ", "footer"));
  return card;
}

// ─── Print document assembly ──────────────────────────────────────────────────

function buildPrintHTML(d: PrintData): string {
  const body = document.createElement("body");
  body.appendChild(buildInvoiceCard(d));
  return `<!DOCTYPE html>
<html lang="km">
<head>
<meta charset="UTF-8">
<title>Invoice</title>
<style>${PRINT_STYLES}</style>
</head>
${body.outerHTML}
</html>`;
}
</script>

<style src="@/styles/print-invoice-dialog.css"></style>
