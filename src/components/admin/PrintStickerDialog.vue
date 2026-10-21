<template>
  <Dialog :open="open" @update:open="(v) => !v && $emit('close')">
    <DialogContent class="max-w-2xl p-0 gap-0 overflow-hidden">
      <div class="py-6 flex flex-col gap-5 overflow-y-auto max-h-[72vh] items-center">
        <InvCard
          v-for="o in orders"
          :key="o.uuid"
          :recipient-name="o.customer_name"
          :phones="[o.customer_phone]"
          :locations="o.delivery_address ? [o.delivery_address] : []"
          :total-price="String(o.total_amount)"
        />
      </div>

      <div class="flex items-center justify-between gap-4 px-6 py-4 border-t">
        <div class="flex gap-2">
          <Button variant="outline" @click="$emit('close')">Cancel</Button>
          <Button variant="outline" @click="sendToMac">
            <Monitor :size="14" class="mr-1.5" />Print on Mac
          </Button>
          <Button @click="doPrint"><Printer :size="14" class="mr-1.5" />Print here</Button>
        </div>
      </div>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { watch } from "vue";
import { Monitor, Printer } from "@lucide/vue";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import type { OrderResponse } from "@/api/orders";
import { printHtml, getPrintStyles } from "@/utils/printStyles";
import { buildStickerCard } from "@/utils/printBuilders";
import { type StickerJob } from "@/utils/printJobUrl";
import { sendPrintJob } from "@/composables/usePrintSocket";
import InvCard from "./InvCard.vue";

const props = defineProps<{ open: boolean; orders: OrderResponse[] }>();
defineEmits<{ close: [] }>();

watch(() => props.open, (open) => { if (open) getPrintStyles(); });

function buildCurrentJob(): StickerJob {
  return {
    type: "stickers",
    orders: props.orders.map((o) => ({
      customer_name: o.customer_name,
      customer_phone: o.customer_phone,
      delivery_address: o.delivery_address ?? null,
      total_amount: o.total_amount,
    })),
  };
}

function sendToMac() {
  sendPrintJob(buildCurrentJob());
}

async function doPrint() {
  const orders = props.orders.slice();
  await printHtml((styles) => {
    const body = document.createElement("body");
    orders.forEach((o, i) => {
      body.appendChild(buildStickerCard({
        customer_name: o.customer_name,
        customer_phone: o.customer_phone,
        delivery_address: o.delivery_address ?? null,
        total_amount: o.total_amount,
      }));
      if (i < orders.length - 1) {
        const pb = document.createElement("div");
        pb.className = "page-break";
        body.appendChild(pb);
      }
    });
    return `<!DOCTYPE html><html lang="km"><head><meta charset="UTF-8"><title>Stickers</title><style>${styles}</style></head>${body.outerHTML}</html>`;
  });
}
</script>

