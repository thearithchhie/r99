import { apiFetch } from "./http";
import { ROUTES } from "./routes";

export interface CategoryResponse {
  id: number;
  name: string;
  created_at?: string;
}

export function fetchCategories(): Promise<CategoryResponse[]> {
  return apiFetch<CategoryResponse[]>(ROUTES.categories.list);
}
