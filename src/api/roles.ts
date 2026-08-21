import { apiFetch } from "./http";
import { ROUTES } from "./routes";
import type { PageMeta } from "./users";
import type { PermissionItem } from "./permissions";

export interface RoleResponse {
  id: number;
  uuid: string;
  name: string;
  description: string | null;
  user_count: number;
  permission_count: number;
  status: string;
  created_at: string;
  created_by: string | null;
  updated_at: string;
  updated_by: string | null;
}

export interface RoleDetailResponse extends RoleResponse {
  permissions: PermissionItem[];
}

export interface RoleListData {
  roles: RoleResponse[];
  meta: PageMeta;
}

export interface CreateRoleRequest {
  name: string;
  description?: string;
}

export interface UpdateRoleRequest {
  name: string;
  description?: string;
}

export function fetchRoles(page = 1, size = 10): Promise<RoleListData> {
  return apiFetch<RoleListData>(`${ROUTES.roles.list}?page=${page - 1}&size=${size}`);
}

export function fetchRole(uuid: string): Promise<RoleDetailResponse> {
  return apiFetch<RoleDetailResponse>(ROUTES.roles.detail(uuid));
}

export function updateRolePermissions(uuid: string, permissionUuids: string[]): Promise<RoleDetailResponse> {
  return apiFetch<RoleDetailResponse>(ROUTES.roles.updatePermissions(uuid), {
    method: "PATCH",
    data: { permissionUuids },
  });
}

export function updateRole(uuid: string, payload: UpdateRoleRequest): Promise<RoleDetailResponse> {
  return apiFetch<RoleDetailResponse>(ROUTES.roles.update(uuid), {
    method: "PATCH",
    data: payload,
  });
}

export function createRole(payload: CreateRoleRequest): Promise<RoleResponse> {
  return apiFetch<RoleResponse>(ROUTES.roles.create, {
    method: "POST",
    data: payload,
  });
}
