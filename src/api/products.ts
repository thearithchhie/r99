import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";

export interface ProductResponse {
  id: number;
  uuid: string;
  code: string;
  name: string;
  sku: string | null;
  price: number;
  cost: number;
  tone: number;
  status: string;
  current_stock: number;
  variant_id: number | null;
  variant_size: string | null;
  variant_color: string | null;
  model_id: number | null;
  model_name: string | null;
  category_id: number | null;
  category_name: string | null;
  line_id: number | null;
  line_name: string | null;
  created_at: string;
  created_by: string | null;
  updated_at: string;
  updated_by: string | null;
}

export interface ProductImageResponse {
  id: number;
  file_name: string;
  file_url: string;
  mime_type: string;
  file_size: number;
  priority: number;
  created_at: string;
}

export interface ProductListData {
  products: ProductResponse[];
  meta: PageMeta;
}

export interface CreateProductRequest {
  variant_id: number;
  name: string;
  code?: string;
  price: number;
  cost?: number;
  initial_stock?: number;
}

export function fetchProducts(page = 1, size = 10): Promise<ProductListData> {
  return apiFetch<ProductListData>(`${ROUTES.products.list}?page=${page - 1}&size=${size}`);
}

export interface ProductSearchResult {
  uuid: string;
  code: string;
  name: string;
  current_stock: number;
}

export function searchProducts(q: string): Promise<ProductSearchResult[]> {
  return apiFetch<ProductSearchResult[]>(`${ROUTES.products.search}?q=${encodeURIComponent(q)}`);
}

export function createProduct(payload: CreateProductRequest): Promise<ProductResponse> {
  return apiFetch<ProductResponse>(ROUTES.products.create, {
    method: "POST",
    data: payload,
  });
}

export interface ProductDetailResponse {
  uuid: string;
  code: string;
  name: string;
  status: string;
  current_stock: number;
  variant_size: string | null;
  variant_color: string | null;
  model_name: string | null;
  price: number;
  images: ProductImageResponse[];
}

export function fetchProductWithImages(uuid: string): Promise<ProductDetailResponse> {
  return apiFetch<ProductDetailResponse>(ROUTES.products.images(uuid));
}

export function deleteProductImage(uuid: string, imageId: number): Promise<void> {
  return apiFetch<void>(`${ROUTES.products.images(uuid)}/${imageId}`, { method: "DELETE" });
}

export function uploadProductImages(uuid: string, files: File[]): Promise<void> {
  const form = new FormData();
  for (const file of files) form.append("files", file);
  return apiFetch<void>(ROUTES.products.images(uuid), {
    method: "POST",
    data: form,
    // Remove the default Content-Type so the browser sets multipart/form-data with boundary
    transformRequest: [(data: unknown, headers: Record<string, string>) => {
      delete headers["Content-Type"];
      return data;
    }],
  });
}
