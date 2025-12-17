import apiClient from './client';
import {
  ApiResponse,
  PaginatedResponse,
  PaginationParams,
  Permission,
  Role,
  RoleFormData,
} from '@/types';

export const rolesApi = {
  /**
   * Get paginated list of roles
   */
  getAll: async (params?: PaginationParams): Promise<PaginatedResponse<Role>> => {
    const response = await apiClient.get<PaginatedResponse<Role>>('/roles', { params });
    return response.data;
  },

  /**
   * Get all roles (unpaginated) for dropdowns
   */
  getAllForDropdown: async (): Promise<ApiResponse<Role[]>> => {
    const response = await apiClient.get<ApiResponse<Role[]>>('/roles', {
      params: { per_page: 1000 },
    });
    return {
      success: true,
      message: 'Success',
      data: response.data.data as unknown as Role[],
    };
  },

  /**
   * Get single role by ID
   */
  getById: async (id: number): Promise<ApiResponse<Role>> => {
    const response = await apiClient.get<ApiResponse<Role>>(`/roles/${id}`);
    return response.data;
  },

  /**
   * Create new role
   */
  create: async (data: RoleFormData): Promise<ApiResponse<Role>> => {
    const response = await apiClient.post<ApiResponse<Role>>('/roles', data);
    return response.data;
  },

  /**
   * Update existing role
   */
  update: async (id: number, data: Partial<RoleFormData>): Promise<ApiResponse<Role>> => {
    const response = await apiClient.put<ApiResponse<Role>>(`/roles/${id}`, data);
    return response.data;
  },

  /**
   * Delete role
   */
  delete: async (id: number): Promise<ApiResponse<null>> => {
    const response = await apiClient.delete<ApiResponse<null>>(`/roles/${id}`);
    return response.data;
  },

  /**
   * Update role permissions
   */
  updatePermissions: async (
    id: number,
    permissionIds: number[]
  ): Promise<ApiResponse<Role>> => {
    const response = await apiClient.put<ApiResponse<Role>>(`/roles/${id}/permissions`, {
      permission_ids: permissionIds,
    });
    return response.data;
  },
};

export const permissionsApi = {
  /**
   * Get all permissions
   */
  getAll: async (): Promise<ApiResponse<Permission[]>> => {
    const response = await apiClient.get<ApiResponse<Permission[]>>('/permissions');
    return response.data;
  },

  /**
   * Get permissions grouped by module
   */
  getGrouped: async (): Promise<ApiResponse<Record<string, Permission[]>>> => {
    const response = await apiClient.get<ApiResponse<Permission[]>>('/permissions');

    // Group permissions by module (first part of permission name)
    const grouped: Record<string, Permission[]> = {};
    response.data.data.forEach((permission) => {
      const module = permission.name.split('.')[0];
      if (!grouped[module]) {
        grouped[module] = [];
      }
      grouped[module].push(permission);
    });

    return {
      success: true,
      message: 'Success',
      data: grouped,
    };
  },
};

export default rolesApi;
