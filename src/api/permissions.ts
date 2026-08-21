import { apiFetch } from "./http";
import { ROUTES } from "./routes";

export interface PermissionItem {
  id: number;
  uuid: string;
  name: string;
  description: string | null;
  module: string;
  action: string;
  status: string;
}

export interface PermissionListData {
  permissions: PermissionItem[];
}

export function fetchAllPermissions(): Promise<PermissionListData> {
  return apiFetch<PermissionListData>(`${ROUTES.permissions.list}?size=200`);
}
