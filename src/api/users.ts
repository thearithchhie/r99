import { apiFetch } from "./http";
import { ROUTES } from "./routes";

export interface UserResponse {
  id: number;
  uuid: string;
  name: string;
  phone: string;
  role: string;
  status: string;
  created_at: string;
  created_by: string | null;
  updated_at: string;
  updated_by: string | null;
}

export interface PageMeta {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
  has_next: boolean;
  has_previous: boolean;
}

export interface UserListData {
  users: UserResponse[];
  meta: PageMeta;
}

export function fetchMe(token?: string): Promise<UserResponse> {
  return apiFetch<UserResponse>(ROUTES.users.me, undefined, token);
}

export function fetchUsers(page = 1, size = 10): Promise<UserListData> {
  return apiFetch<UserListData>(`${ROUTES.users.list}?page=${page - 1}&size=${size}`);
}

export function fetchUser(uuid: string): Promise<UserResponse> {
  return apiFetch<UserResponse>(ROUTES.users.detail(uuid));
}

export interface CreateUserRequest {
  name: string;
  phone: string;
  password: string;
}

export function createUser(payload: CreateUserRequest): Promise<UserResponse> {
  return apiFetch<UserResponse>(ROUTES.users.create, {
    method: "POST",
    data: payload,
  });
}

export interface UpdateUserRequest {
  name: string;
  phone: string;
}

export function updateUser(uuid: string, payload: UpdateUserRequest): Promise<UserResponse> {
  return apiFetch<UserResponse>(ROUTES.users.update(uuid), {
    method: "PATCH",
    data: payload,
  });
}

export function deleteUser(uuid: string): Promise<void> {
  return apiFetch<void>(ROUTES.users.delete(uuid), { method: "DELETE" });
}
