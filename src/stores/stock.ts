import { defineStore } from "pinia";
import { ref } from "vue";
import { fetchStockLevels, fetchStockMovements } from "@/api/stock";
import type { StockLevelResponse, StockMovementResponse } from "@/api/stock";
import type { PageMeta } from "@/api/users";

export const useStockStore = defineStore("stock", () => {
  const stockLevels = ref<StockLevelResponse[]>([]);
  const meta = ref<PageMeta | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const movements = ref<StockMovementResponse[]>([]);
  const movementsMeta = ref<PageMeta | null>(null);
  const movementsLoading = ref(false);
  const movementsError = ref<string | null>(null);

  async function loadStockLevels(page = 1) {
    loading.value = true;
    error.value = null;
    try {
      const data = await fetchStockLevels(page);
      stockLevels.value = data.stock_levels;
      meta.value = data.meta;
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : "Failed to load stock";
    } finally {
      loading.value = false;
    }
  }

  async function loadMovements(page = 1) {
    movementsLoading.value = true;
    movementsError.value = null;
    try {
      const data = await fetchStockMovements(page);
      movements.value = data.stock_movements;
      movementsMeta.value = data.meta;
    } catch (e: unknown) {
      movementsError.value = e instanceof Error ? e.message : "Failed to load stock movements";
    } finally {
      movementsLoading.value = false;
    }
  }

  return {
    stockLevels, meta, loading, error, loadStockLevels,
    movements, movementsMeta, movementsLoading, movementsError, loadMovements,
  };
});
