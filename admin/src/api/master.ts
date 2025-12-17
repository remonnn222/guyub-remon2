import apiClient from './client';
import {
  ApiResponse,
  MasterType,
  MasterTypeFormData,
  MasterValue,
  MasterValueFormData,
  PaginatedResponse,
  PaginationParams,
} from '@/types';

export const masterTypesApi = {
  /**
   * Get paginated list of master types
   */
  getAll: async (params?: PaginationParams): Promise<PaginatedResponse<MasterType>> => {
    const response = await apiClient.get<PaginatedResponse<MasterType>>('/master/types', {
      params,
    });
    return response.data;
  },

  /**
   * Get all master types tree (hierarchical)
   */
  getTree: async (): Promise<ApiResponse<MasterType[]>> => {
    const response = await apiClient.get<ApiResponse<MasterType[]>>('/master/types/tree');
    return response.data;
  },

  /**
   * Get single master type by ID
   */
  getById: async (id: number): Promise<ApiResponse<MasterType>> => {
    const response = await apiClient.get<ApiResponse<MasterType>>(`/master/types/${id}`);
    return response.data;
  },

  /**
   * Get master type by code
   */
  getByCode: async (code: string): Promise<ApiResponse<MasterType>> => {
    const response = await apiClient.get<ApiResponse<MasterType>>(
      `/master/types/code/${code}`
    );
    return response.data;
  },

  /**
   * Create new master type
   */
  create: async (data: MasterTypeFormData): Promise<ApiResponse<MasterType>> => {
    const response = await apiClient.post<ApiResponse<MasterType>>('/master/types', data);
    return response.data;
  },

  /**
   * Update existing master type
   */
  update: async (
    id: number,
    data: Partial<MasterTypeFormData>
  ): Promise<ApiResponse<MasterType>> => {
    const response = await apiClient.put<ApiResponse<MasterType>>(
      `/master/types/${id}`,
      data
    );
    return response.data;
  },

  /**
   * Delete master type
   */
  delete: async (id: number): Promise<ApiResponse<null>> => {
    const response = await apiClient.delete<ApiResponse<null>>(`/master/types/${id}`);
    return response.data;
  },

  /**
   * Get values for a master type
   */
  getValues: async (
    id: number,
    params?: PaginationParams
  ): Promise<PaginatedResponse<MasterValue>> => {
    const response = await apiClient.get<PaginatedResponse<MasterValue>>(
      `/master/types/${id}/values`,
      { params }
    );
    return response.data;
  },
};

export const masterValuesApi = {
  /**
   * Get single master value by ID
   */
  getById: async (id: number): Promise<ApiResponse<MasterValue>> => {
    const response = await apiClient.get<ApiResponse<MasterValue>>(`/master/values/${id}`);
    return response.data;
  },

  /**
   * Create new master value
   */
  create: async (data: MasterValueFormData): Promise<ApiResponse<MasterValue>> => {
    const response = await apiClient.post<ApiResponse<MasterValue>>('/master/values', data);
    return response.data;
  },

  /**
   * Update existing master value
   */
  update: async (
    id: number,
    data: Partial<MasterValueFormData>
  ): Promise<ApiResponse<MasterValue>> => {
    const response = await apiClient.put<ApiResponse<MasterValue>>(
      `/master/values/${id}`,
      data
    );
    return response.data;
  },

  /**
   * Delete master value
   */
  delete: async (id: number): Promise<ApiResponse<null>> => {
    const response = await apiClient.delete<ApiResponse<null>>(`/master/values/${id}`);
    return response.data;
  },

  /**
   * Get cascading values by type code
   */
  getCascade: async (
    typeCode: string,
    parentValueId?: number
  ): Promise<ApiResponse<MasterValue[]>> => {
    const response = await apiClient.get<ApiResponse<MasterValue[]>>(
      `/master/cascade/${typeCode}`,
      { params: { parent_value_id: parentValueId } }
    );
    return response.data;
  },
};

export default masterTypesApi;
