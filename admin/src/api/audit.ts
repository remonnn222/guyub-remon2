import apiClient from './client';
import {
  ActivityFilters,
  ActivityLog,
  ApiResponse,
  AuditFilters,
  AuditLog,
  DashboardStats,
  PaginatedResponse,
  PaginationParams,
} from '@/types';

export const auditApi = {
  /**
   * Get paginated list of audit logs
   */
  getAll: async (
    params?: PaginationParams & AuditFilters
  ): Promise<PaginatedResponse<AuditLog>> => {
    const response = await apiClient.get<PaginatedResponse<AuditLog>>('/audit', { params });
    return response.data;
  },

  /**
   * Get single audit log by ID
   */
  getById: async (id: number): Promise<ApiResponse<AuditLog>> => {
    const response = await apiClient.get<ApiResponse<AuditLog>>(`/audit/${id}`);
    return response.data;
  },

  /**
   * Export audit logs to CSV
   */
  export: async (filters?: AuditFilters): Promise<Blob> => {
    const response = await apiClient.get('/audit/export', {
      params: filters,
      responseType: 'blob',
    });
    return response.data;
  },
};

export const activityApi = {
  /**
   * Get paginated list of activity logs
   */
  getAll: async (
    params?: PaginationParams & ActivityFilters
  ): Promise<PaginatedResponse<ActivityLog>> => {
    const response = await apiClient.get<PaginatedResponse<ActivityLog>>('/activity', {
      params,
    });
    return response.data;
  },

  /**
   * Get single activity log by ID
   */
  getById: async (id: number): Promise<ApiResponse<ActivityLog>> => {
    const response = await apiClient.get<ApiResponse<ActivityLog>>(`/activity/${id}`);
    return response.data;
  },

  /**
   * Get activity stats for user
   */
  getUserStats: async (userId: number): Promise<ApiResponse<{
    total_logins: number;
    last_login: string | null;
    total_activities: number;
  }>> => {
    const response = await apiClient.get<ApiResponse<{
      total_logins: number;
      last_login: string | null;
      total_activities: number;
    }>>(`/activity/user/${userId}/stats`);
    return response.data;
  },
};

export const analyticsApi = {
  /**
   * Get dashboard statistics
   */
  getDashboardStats: async (): Promise<ApiResponse<DashboardStats>> => {
    const response = await apiClient.get<ApiResponse<DashboardStats>>('/analytics/dashboard');
    return response.data;
  },

  /**
   * Get user growth chart data
   */
  getUserGrowth: async (period: 'week' | 'month' | 'year' = 'month'): Promise<ApiResponse<{
    labels: string[];
    data: number[];
  }>> => {
    const response = await apiClient.get<ApiResponse<{ labels: string[]; data: number[] }>>(
      '/analytics/users/growth',
      { params: { period } }
    );
    return response.data;
  },

  /**
   * Get activity trends
   */
  getActivityTrends: async (period: 'week' | 'month' = 'week'): Promise<ApiResponse<{
    labels: string[];
    data: number[];
  }>> => {
    const response = await apiClient.get<ApiResponse<{ labels: string[]; data: number[] }>>(
      '/analytics/activity/trends',
      { params: { period } }
    );
    return response.data;
  },
};

export default auditApi;
