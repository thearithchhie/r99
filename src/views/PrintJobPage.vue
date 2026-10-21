<template>
  <div>
    <!-- Screen message (hidden in print) -->
    <div class="no-print fixed inset-0 flex items-center justify-center bg-white">
      <div class="text-center p-6 max-w-xs">
        <template v-if="!ready && !error">
          <div class="text-gray-400 text-sm">Preparing print job…</div>
        </template>
        <template v-else-if="error">
          <div class="text-red-500 font-semibold">Invalid print link</div>
          <div class="text-gray-400 text-sm mt-1">This link may be expired or malformed.</div>
        </template>
        <template v-else>
          <div class="text-gray-800 font-semibold text-base mb-1">Print dialog opened</div>
          <div class="text-gray-400 text-sm">You can close this tab after printing.</div>
          <button
            class="mt-4 px-4 py-1.5 bg-gray-100 hover:bg-gray-200 rounded text-sm transition-colors"
            @click="window.print()"
          >
            Print again
          </button>
        </template>
      </div>
    </div>

    <!-- Print-only content (hidden on screen) -->
    <div id="pj-content"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { getPrintStyles } from "@/utils/printStyles";
import { decodePrintJob } from "@/utils/printJobUrl";
import { buildInvoiceCard, buildStickerCard } from "@/utils/printBuilders";

const route = useRoute();
const ready = ref(false);
const error = ref(false);
const window = globalThis.window;

onMounted(async () => {
  const encoded = route.query.d as string;
  if (!encoded) { error.value = true; return; }

  const job = decodePrintJob(encoded);
  if (!job) { error.value = true; return; }

  const styles = await getPrintStyles();

  const styleEl = document.createElement("style");
  styleEl.textContent = `@media screen{#pj-content{display:none}}@media print{.no-print{display:none!important}}${styles}`;
  document.head.appendChild(styleEl);

  const container = document.getElementById("pj-content")!;

  if (job.type === "invoice") {
    container.appendChild(buildInvoiceCard(job));
  } else {
    job.orders.forEach((o, i) => {
      container.appendChild(buildStickerCard(o));
      if (i < job.orders.length - 1) {
        const pb = document.createElement("div");
        pb.className = "page-break";
        container.appendChild(pb);
      }
    });
  }

  await document.fonts.ready;
  window.print();
  ready.value = true;
});
</script>
