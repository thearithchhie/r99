<template>
  <div class="inv-card khmer">
    <!-- Page header row -->
    <div class="inv-hrow">
      <img :src="urlFb" width="18" height="18" />
      <span>ឈ្មោះផេកៈ {{ pageName }}</span>
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
    <div class="inv-val">{{ recipientName || "-" }}</div>

    <!-- Phone -->
    <div class="inv-sec-hdr">
      <img :src="urlPhone" width="18" height="18" />
      <span>លេខទូរស័ព្ទអ្នកទទួល</span>
    </div>
    <template v-if="phones.length === 0">
      <div class="inv-val inv-val-phone">-</div>
    </template>
    <div v-for="(p, i) in phones" :key="i" class="inv-val inv-val-phone">
      {{ p || "-" }}
    </div>

    <!-- Location -->
    <div class="inv-sec-hdr">
      <img :src="urlPin" width="18" height="18" />
      <span>ទីតាំង</span>
    </div>
    <template v-if="locations.length === 0">
      <div class="inv-val inv-val-loc">-</div>
    </template>
    <div v-for="(l, i) in locations" :key="i" class="inv-val inv-val-loc">
      {{ l || "-" }}
    </div>

    <!-- Delivery row -->
    <div class="inv-drow">
      <span class="inv-drow-left">
        <img :src="urlTruck" width="16" height="16" />
        <span>សេវាដឹក</span>
      </span>
      <span class="inv-drow-amt">តម្លៃ: {{ currency }}{{ totalPrice || "0" }}</span>
    </div>

    <!-- Chips -->
    <div class="inv-chips">
      <div class="inv-chip">
        <div class="inv-chk">{{ guestService ? "✓" : "" }}</div>
        <span class="khmer">សេវា<br />ខាងភ្ញៀវ</span>
      </div>
      <div class="inv-chip">
        <div class="inv-chk">{{ virak ? "✓" : "" }}</div>
        <span>VAT</span>
      </div>
      <div class="inv-chip">
        <div class="inv-chk">{{ jt ? "✓" : "" }}</div>
        <span>J&amp;T</span>
      </div>
    </div>

    <div class="inv-footer">សូមអរគុណសម្រាប់ការគាំទ្រ</div>
  </div>
</template>

<script setup lang="ts">
import urlFb from "@/assets/icon/svg/fb.svg";
import urlPhone from "@/assets/icon/svg/phone.svg";
import urlPin from "@/assets/icon/svg/pin.svg";
import urlTruck from "@/assets/icon/svg/truck.svg";
import urlUser from "@/assets/icon/svg/user.svg";

withDefaults(defineProps<{
  pageName?: string;
  recipientName?: string;
  phones?: string[];
  locations?: string[];
  guestService?: boolean;
  virak?: boolean;
  jt?: boolean;
  currency?: string;
  totalPrice?: string;
}>(), {
  pageName: "R99",
  recipientName: "",
  phones: () => [],
  locations: () => [],
  guestService: false,
  virak: false,
  jt: false,
  currency: "$",
  totalPrice: "0",
});
</script>

<style src="@/styles/print-invoice-dialog.css"></style>
