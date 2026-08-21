import { apiFetch } from "./http";
import { ROUTES } from "./routes";

export interface LineResponse {
  id: number;
  name: string;
  created_at: string;
  updated_at: string;
}

export function fetchLines(): Promise<LineResponse[]> {
  return apiFetch<LineResponse[]>(ROUTES.lines.list);
}

export function createLine(name: string): Promise<LineResponse> {
  return apiFetch<LineResponse>(ROUTES.lines.create, { method: "POST", data: { name } });
}
