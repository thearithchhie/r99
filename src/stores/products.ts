import { defineStore } from "pinia";
import { ref } from "vue";
import { fetchProducts } from "@/api/products";
import type { ProductResponse } from "@/api/products";
import type { PageMeta } from "@/api/users";

export const useProductsStore = defineStore("products", () => {
  const products = ref<ProductResponse[]>([]);
  const meta = ref<PageMeta | null>(null);
  const loading = ref(false);
  const error = ref<string | null>(null);

  async function loadProducts(page = 1) {
    loading.value = true;
    error.value = null;
    try {
      const data = await fetchProducts(page);
      products.value = data.products;
      meta.value = data.meta;
    } catch (e: unknown) {
      error.value = e instanceof Error ? e.message : "Failed to load products";
    } finally {
      loading.value = false;
    }
  }

  return { products, meta, loading, error, loadProducts };
});
