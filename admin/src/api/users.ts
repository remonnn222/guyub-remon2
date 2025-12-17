import apiClient from './client';
import {
  ApiResponse,
  PaginatedResponse,
  PaginationParams,
  User,
  UserFilters,
  UserFormData,
} from '@/types';

export const usersApi = {
  /**
   * Get paginated list of users
   */
  getAll: async (
    params?: PaginationParams & UserFilters
  ): Promise<PaginatedResponse<User>> => {
    const response = await apiClient.get<PaginatedResponse<User>>('/users', { params });
    return response.data;
  },

  /**
   * Get single user by ID
   */
  getById: async (id: number): Promise<ApiResponse<User>> => {
    const response = await apiClient.get<ApiResponse<User>>(`/users/${id}`);
    return response.data;
  },

  /**
   * Create new user
   */
  create: async (data: UserFormData): Promise<ApiResponse<User>> => {
    const response = await apiClient.post<ApiResponse<User>>('/users', data);
    return response.data;
  },

  /**
   * Update existing user
   */
  update: async (id: number, data: Partial<UserFormData>): Promise<ApiResponse<User>> => {
    const response = await apiClient.put<ApiResponse<User>>(`/users/${id}`, data);
    return response.data;
  },

  /**
   * Delete user (soft delete)
   */
  delete: async (id: number): Promise<ApiResponse<null>> => {
    const response = await apiClient.delete<ApiResponse<null>>(`/users/${id}`);
    return response.data;
  },

  /**
   * Restore soft-deleted user
   */
  restore: async (id: number): Promise<ApiResponse<User>> => {
    const response = await apiClient.post<ApiResponse<User>>(`/users/${id}/restore`);
    return response.data;
  },

  /**
   * Bulk delete users
   */
  bulkDelete: async (ids: number[]): Promise<ApiResponse<{ affected: number }>> => {
    const response = await apiClient.post<ApiResponse<{ affected: number }>>(
      '/users/bulk/delete',
      { ids }
    );
    return response.data;
  },

  /**
   * Bulk restore users
   */
  bulkRestore: async (ids: number[]): Promise<ApiResponse<{ affected: number }>> => {
    const response = await apiClient.post<ApiResponse<{ affected: number }>>(
      '/users/bulk/restore',
      { ids }
    );
    return response.data;
  },

  /**
   * Bulk assign role to users
   */
  bulkAssignRole: async (
    ids: number[],
    roleId: number
  ): Promise<ApiResponse<{ affected: number }>> => {
    const response = await apiClient.post<ApiResponse<{ affected: number }>>(
      '/users/bulk/assign-role',
      { ids, role_id: roleId }
    );
    return response.data;
  },

  /**
   * Export users to CSV
   */
  export: async (filters?: UserFilters): Promise<Blob> => {
    const response = await apiClient.get('/users/export', {
      params: filters,
      responseType: 'blob',
    });
    return response.data;
  },

  /**
   * Import users from CSV
   */
  import: async (file: File): Promise<ApiResponse<{ imported: number; failed: number }>> => {
    const formData = new FormData();
    formData.append('file', file);
    const response = await apiClient.post<
      ApiResponse<{ imported: number; failed: number }>
    >('/users/import', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  /**
   * Change user password
   */
  changePassword: async (
    id: number,
    data: { current_password: string; password: string; password_confirmation: string }
  ): Promise<ApiResponse<null>> => {
    const response = await apiClient.post<ApiResponse<null>>(
      `/users/${id}/change-password`,
      data
    );
    return response.data;
  },
};

export default usersApi;
