import { apiClient } from "./http";
import { ROUTES } from "./routes";
import type { AppRole } from "@/stores/session";

export interface LoginPayload {
  phone: string;
  password: string;
}

export interface AuthData {
  token: string;
  uuid: string;
  name: string;
  phone: string;
  role: AppRole;
}

export async function loginApi(payload: LoginPayload): Promise<AuthData> {
  const response = await apiClient.post<{ success: boolean; message?: string; data: AuthData }>(
    ROUTES.auth.login,
    payload,
  );
  if (!response.data.success) {
    throw new Error(response.data.message ?? "Login failed");
  }
  return response.data.data;
}
