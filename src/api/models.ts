import { apiFetch } from "./http";
import { ROUTES } from "./routes";

export interface ModelResponse {
  id: number;
  uuid: string;
  name: string;
  description?: string;
  created_at?: string;
  updated_at?: string;
}

export interface ModelDetailResponse extends ModelResponse {
  variants: ModelVariant[];
}

export interface ModelVariant {
  id: number;
  size: string | null;
  color: string | null;
  created_at?: string;
  updated_at?: string;
}

export function fetchModels(): Promise<ModelResponse[]> {
  return apiFetch<ModelResponse[]>(ROUTES.models.list);
}

export function fetchModel(uuid: string): Promise<ModelDetailResponse> {
  return apiFetch<ModelDetailResponse>(ROUTES.models.detail(uuid));
}

export function createModel(payload: { name: string; description?: string }): Promise<ModelResponse> {
  return apiFetch<ModelResponse>(ROUTES.models.list, { method: "POST", data: payload });
}

export function fetchModelVariants(modelId: number): Promise<ModelVariant[]> {
  return apiFetch<ModelVariant[]>(ROUTES.models.variants(modelId));
}

export function createModelVariant(
  modelId: number,
  payload: { size: string; color: string },
): Promise<ModelVariant> {
  return apiFetch<ModelVariant>(ROUTES.models.variants(modelId), {
    method: "POST",
    data: payload,
  });
}
