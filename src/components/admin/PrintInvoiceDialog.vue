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
          <InvCard
            :page-name="form.pageName || 'R99'"
            :recipient-name="form.recipientName"
            :phones="form.phones"
            :locations="form.locations"
            :guest-service="form.guestService"
            :virak="form.virak"
            :jt="form.jt"
            :currency="form.currency"
            :total-price="form.totalPrice"
          />
        </div>
      </div>

      <div class="flex justify-end gap-2 px-6 py-4 border-t">
        <Button variant="outline" @click="$emit('close')">Cancel</Button>
        <Button variant="outline" @click="sendToMac">
          <Monitor :size="14" class="mr-1.5" />Print on Mac
        </Button>
        <Button @click="doPrint"><Printer :size="14" class="mr-1.5" />Print here</Button>
      </div>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { reactive, watch } from "vue";
import { printHtml, getPrintStyles } from "@/utils/printStyles";
import { type InvoiceJob } from "@/utils/printJobUrl";
import { buildInvoiceCard } from "@/utils/printBuilders";
import { sendPrintJob } from "@/composables/usePrintSocket";
import { Monitor, X, Printer } from "@lucide/vue";
import InvCard from "./InvCard.vue";
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

function buildCurrentJob(): InvoiceJob {
  const phones = form.phones.filter(Boolean);
  const locations = form.locations.filter(Boolean);
  return {
    type: "invoice",
    pageName: form.pageName || "R99",
    recipientName: form.recipientName || "-",
    phones: phones.length ? phones : ["-"],
    locations: locations.length ? locations : ["-"],
    guestService: form.guestService,
    virak: form.virak,
    jt: form.jt,
    currency: form.currency,
    totalPrice: form.totalPrice || "0",
  };
}

// Pre-warm font cache when dialog opens
watch(() => props.open, (open) => { if (open) getPrintStyles(); });

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
    } catch {
      /* silent — user can fill manually */
    }
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

async function doPrint() {
  const job = buildCurrentJob();
  await printHtml((styles) => {
    const body = document.createElement("body");
    body.appendChild(buildInvoiceCard(job));
    return `<!DOCTYPE html><html lang="km"><head><meta charset="UTF-8"><title>Invoice</title><style>${styles}</style></head>${body.outerHTML}</html>`;
  });
}

function sendToMac() {
  sendPrintJob(buildCurrentJob());
}
</script>
