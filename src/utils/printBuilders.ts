import IC_FB from "@/assets/icon/svg/fb.svg?raw";
import IC_PHONE from "@/assets/icon/svg/phone.svg?raw";
import IC_PIN from "@/assets/icon/svg/pin.svg?raw";
import IC_TRUCK from "@/assets/icon/svg/truck.svg?raw";
import IC_USER from "@/assets/icon/svg/user.svg?raw";
import type { InvoiceJob, StickerOrder } from "./printJobUrl";

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

function iconRow(className: string, icon: Element, content: string): HTMLElement {
  const div = el("div", className);
  div.append(icon, document.createTextNode(content));
  return div;
}

function buildSectionHeader(title: string, icon: Element): HTMLElement {
  const hdr = el("div", "sec-hdr");
  hdr.append(icon, text("span", title));
  return hdr;
}

function buildValueRows(values: string[], modifier?: string): DocumentFragment {
  const frag = document.createDocumentFragment();
  values.forEach((v) =>
    frag.appendChild(text("div", v, modifier ? `sec-val ${modifier}` : "sec-val")),
  );
  return frag;
}

function buildChip(label: string, checked: boolean, khmer = false): HTMLElement {
  const chip = el("div", "chip");
  const chk = el("div", "chk");
  if (checked) chk.textContent = "✓";
  const span = el("span", khmer ? "klabel" : undefined);
  label.split("\n").forEach((line, i) => {
    if (i > 0) span.appendChild(document.createElement("br"));
    span.appendChild(document.createTextNode(line));
  });
  chip.append(chk, span);
  return chip;
}

export function buildInvoiceCard(d: InvoiceJob): HTMLElement {
  const card = el("div", "card");
  const chips = el("div", "chips");
  chips.append(
    buildChip("សេវា\nខាងភ្ញៀវ", d.guestService, true),
    buildChip("VAT", d.virak),
    buildChip("J&T", d.jt),
  );
  const deliveryRow = el("div", "drow");
  const left = el("span", "drow-left");
  left.append(svgIcon(IC_TRUCK), document.createTextNode(" សេវាដឹក"));
  deliveryRow.append(left, text("span", `តម្លៃ: ${d.currency}${d.totalPrice}`, "drow-amt"));
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
    deliveryRow,
    chips,
    text("div", "សូមអរគុណសម្រាប់ការគាំទ្រ", "footer"),
  );
  return card;
}

export function buildStickerCard(o: StickerOrder): HTMLElement {
  const card = el("div", "card");
  const chips = el("div", "chips");
  chips.append(
    buildChip("សេវា\nខាងភ្ញៀវ", false, true),
    buildChip("VAT", false),
    buildChip("J&T", false),
  );
  const drow = el("div", "drow");
  const dleft = el("span", "drow-left");
  dleft.append(svgIcon(IC_TRUCK), document.createTextNode(" សេវាដឹក"));
  drow.append(dleft, text("span", `តម្លៃ: $${o.total_amount}`, "drow-amt"));
  card.append(
    iconRow("hrow", svgIcon(IC_FB), "ឈ្មោះផេកៈ R99"),
    iconRow("sender-label", svgIcon(IC_PHONE), "លេខទូរស័ព្ទអ្នកផ្ញើរ ឬ វេរលុយ"),
    text("div", "097 71 56 486", "sender-phone"),
    buildSectionHeader("ឈ្មោះអតិថិជន", svgIcon(IC_USER)),
    text("div", o.customer_name || "-", "sec-val"),
    buildSectionHeader("លេខទូរស័ព្ទអ្នកទទួល", svgIcon(IC_PHONE)),
    text("div", o.customer_phone || "-", "sec-val phone"),
    buildSectionHeader("ទីតាំង", svgIcon(IC_PIN)),
    text("div", o.delivery_address || "-", "sec-val loc"),
    drow,
    chips,
    text("div", "សូមអរគុណសម្រាប់ការគាំទ្រ", "footer"),
  );
  return card;
}
