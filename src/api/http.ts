import axios, { type AxiosRequestConfig } from "axios";
import router from "@/router";
import { useSessionStore } from "@/stores/session";

const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "";

export const apiClient = axios.create({
  baseURL: BASE_URL,
  headers: { "Content-Type": "application/json" },
});

apiClient.interceptors.request.use((config) => {
  const session = useSessionStore();
  if (session.token) {
    config.headers.Authorization = `Bearer ${session.token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const session = useSessionStore();
      session.logout();
      router.push("/admin/login");
      return Promise.reject(new Error("Session expired. Please log in again."));
    }
    const message =
      error.response?.data?.message ?? error.message ?? "Unknown error";
    return Promise.reject(new Error(message));
  },
);

export async function apiFetch<T>(
  path: string,
  config?: AxiosRequestConfig,
  tokenOverride?: string,
): Promise<T> {
  const headers: Record<string, string> = {
    ...(config?.headers as Record<string, string>),
  };
  if (tokenOverride) headers["Authorization"] = `Bearer ${tokenOverride}`;

  const response = await apiClient.request<{
    success: boolean;
    message?: string;
    data: T;
  }>({
    url: path,
    ...config,
    headers: Object.keys(headers).length ? headers : undefined,
  });

  // 204 No Content — no body to unwrap
  if (response.status === 204) return undefined as T;

  if (!response.data.success) {
    throw new Error(response.data.message ?? `HTTP ${response.status}`);
  }

  return response.data.data;
}
