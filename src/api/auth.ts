import { apiClient } from "./http";
import { ROUTES } from "./routes";
import type { AppRole } from "@/stores/session";

export interface LoginPayload {
  phone: string;
  password: string;
}

export interface AuthData {
  access_token: string;
}

export interface CurrentUserData {
  uuid: string;
  name: string;
  phone: string;
  role: AppRole;
  permissions: Record<string, string[]>;
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

export async function getCurrentUserApi(token: string): Promise<CurrentUserData> {
  const response = await apiClient.get<{ success: boolean; message?: string; data: CurrentUserData }>(
    ROUTES.auth.currentUser,
    { headers: { Authorization: `Bearer ${token}` } },
  );
  if (!response.data.success) {
    throw new Error(response.data.message ?? "Failed to load user profile");
  }
  return response.data.data;
}
