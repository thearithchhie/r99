<template>
  <Sheet :open="!!order" @update:open="(v) => !v && $emit('close')">
    <SheetContent class="overflow-y-auto p-0 w-110 sm:max-w-110">
      <div v-if="order" class="flex flex-col h-full">
        <!-- Header -->
        <div
          class="flex items-start justify-between px-5 py-4 border-b sticky top-0 bg-background z-10"
        >
          <div>
            <div class="mono text-[14px] font-semibold">{{ order.id }}</div>
            <StatusBadge :status="order.status" class="mt-1" />
          </div>
          <div class="flex items-center gap-1">
            <Button
              variant="ghost"
              size="icon"
              class="h-8 w-8"
              @click="printOpen = true"
            >
              <Printer :size="15" />
            </Button>
            <Button
              variant="ghost"
              size="icon"
              class="h-8 w-8"
              @click="$emit('close')"
            >
              <X :size="18" />
            </Button>
          </div>
        </div>

        <!-- Body -->
        <div class="flex-1 overflow-y-auto p-5 flex flex-col gap-5">
          <!-- Customer -->
          <section>
            <div
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground mb-2.5"
            >
              Customer
            </div>
            <div class="flex items-center gap-2.5">
              <UserAvatar :name="order.customer" :size="36" />
              <div>
                <div class="font-semibold">{{ order.customer }}</div>
                <div class="text-muted-foreground text-[12.5px]">
                  {{ order.email }}
                </div>
                <div class="text-muted-foreground text-[12.5px]">
                  {{ order.city }}
                </div>
              </div>
            </div>
          </section>

          <Separator />

          <!-- Items -->
          <section>
            <div
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground mb-2.5"
            >
              Items
            </div>
            <div class="flex flex-col gap-2.5">
              <div
                v-for="item in order.items"
                :key="item.id + item.size"
                class="flex items-center gap-2.5"
              >
                <PlaceholderThumb :tone="item.tone" :size="40" />
                <div class="flex-1 min-w-0">
                  <div class="text-[13.5px] font-medium">{{ item.name }}</div>
                  <div class="text-muted-foreground text-[12px]">
                    {{ item.size }} · {{ item.color }}
                  </div>
                </div>
                <div class="text-right shrink-0">
                  <div class="font-medium">
                    {{ money(item.price * item.qty) }}
                  </div>
                  <div class="text-muted-foreground text-[12px]">
                    × {{ item.qty }}
                  </div>
                </div>
              </div>
            </div>
          </section>

          <Separator />

          <!-- Summary -->
          <section>
            <div
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground mb-2.5"
            >
              Summary
            </div>
            <div class="flex flex-col gap-2 text-[13.5px]">
              <div class="flex justify-between">
                <span class="text-muted-foreground">Subtotal</span>
                <span>{{ money(order.total - 12) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-muted-foreground"
                  >Shipping ({{ order.ship }})</span
                >
                <span>{{ order.ship === "Express" ? money(12) : "Free" }}</span>
              </div>
              <Separator class="my-1" />
              <div class="flex justify-between font-semibold">
                <span>Total</span><span>{{ money(order.total) }}</span>
              </div>
            </div>
          </section>

          <!-- Fulfil -->
          <section v-if="order.status === 'Processing'">
            <div
              class="text-[11px] font-semibold uppercase tracking-widest text-muted-foreground mb-2.5"
            >
              Fulfil order
            </div>
            <div class="flex flex-col gap-2">
              <Input
                v-model="tracking"
                placeholder="Tracking number (optional)"
              />
              <Button class="w-full" @click="markShipped">
                <Truck :size="15" /> Mark as Shipped
              </Button>
            </div>
          </section>

          <p class="text-muted-foreground text-[12px]">
            Placed {{ fmtDate(order.date) }}
          </p>
        </div>
      </div>
    </SheetContent>
  </Sheet>

  <PrintInvoiceDialog
    :open="printOpen"
    :order="order"
    @close="printOpen = false"
  />
</template>

<script setup lang="ts">
import { ref } from "vue";
import { X, Truck, Printer } from "@lucide/vue";
import { Sheet, SheetContent } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Separator } from "@/components/ui/separator";
import StatusBadge from "@/components/admin/StatusBadge.vue";
import UserAvatar from "@/components/admin/UserAvatar.vue";
import PlaceholderThumb from "@/components/admin/PlaceholderThumb.vue";
import PrintInvoiceDialog from "@/components/admin/PrintInvoiceDialog.vue";
import { money, fmtDate } from "@/utils/format";
import { useUIStore } from "@/stores/ui";
import type { Order } from "@/data/orders";

defineProps<{ order: Order | null }>();
const emit = defineEmits<{ close: [] }>();

const ui = useUIStore();
const tracking = ref("");
const printOpen = ref(false);

function markShipped() {
  ui.showToast("Order marked as Shipped");
  emit("close");
}
</script>
