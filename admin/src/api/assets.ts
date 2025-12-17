import apiClient from './client';
import { ApiResponse, Asset } from '@/types';

export const assetsApi = {
  /**
   * Upload file
   */
  upload: async (
    file: File,
    options?: {
      kind?: string;
      refId?: number;
    }
  ): Promise<ApiResponse<Asset>> => {
    const formData = new FormData();
    formData.append('file', file);
    if (options?.kind) {
      formData.append('kind', options.kind);
    }
    if (options?.refId) {
      formData.append('ref_id', options.refId.toString());
    }

    const response = await apiClient.post<ApiResponse<Asset>>('/assets/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return response.data;
  },

  /**
   * Get asset by ID
   */
  getById: async (id: string): Promise<ApiResponse<Asset>> => {
    const response = await apiClient.get<ApiResponse<Asset>>(`/assets/${id}`);
    return response.data;
  },

  /**
   * Get assets by reference
   */
  getByRef: async (refId: number, kind: string): Promise<ApiResponse<Asset[]>> => {
    const response = await apiClient.get<ApiResponse<Asset[]>>('/assets/by-ref', {
      params: { ref_id: refId, kind },
    });
    return response.data;
  },

  /**
   * Delete asset
   */
  delete: async (id: string): Promise<ApiResponse<null>> => {
    const response = await apiClient.delete<ApiResponse<null>>(`/assets/${id}`);
    return response.data;
  },

  /**
   * Get asset URL
   */
  getUrl: (id: string): string => {
    const baseUrl = import.meta.env.VITE_ASSETS_URL || 'http://localhost:8080/assets';
    return `${baseUrl}/${id}`;
  },
};

export default assetsApi;
