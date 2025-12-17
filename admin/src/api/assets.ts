import apiClient from './client';
import { ApiResponse, Asset, AssetKind } from '@/types';

export interface UploadOptions {
  kind: AssetKind;
  refId?: string;
  title?: string;
  onProgress?: (progress: number) => void;
}

export const assetsApi = {
  /**
   * Upload file
   */
  upload: async (
    file: File,
    options: UploadOptions
  ): Promise<ApiResponse<Asset>> => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('kind', options.kind);

    if (options.refId) {
      formData.append('ref_id', options.refId);
    }
    if (options.title) {
      formData.append('title', options.title);
    }

    const response = await apiClient.post<ApiResponse<Asset>>('/assets/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: (progressEvent) => {
        if (options.onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
          options.onProgress(progress);
        }
      },
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
  getByRef: async (refId: string, kind?: AssetKind): Promise<ApiResponse<Asset[]>> => {
    const params: Record<string, string> = { ref_id: refId };
    if (kind) {
      params.kind = kind;
    }
    const response = await apiClient.get<ApiResponse<Asset[]>>('/assets/by-ref', { params });
    return response.data;
  },

  /**
   * Get user avatar
   */
  getUserAvatar: async (userId: number): Promise<ApiResponse<{ url: string }>> => {
    const response = await apiClient.get<ApiResponse<{ url: string }>>(`/assets/user/${userId}/avatar`);
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
   * Link asset to reference
   */
  linkToRef: async (id: string, refId: string): Promise<ApiResponse<null>> => {
    const response = await apiClient.post<ApiResponse<null>>(`/assets/${id}/link`, { ref_id: refId });
    return response.data;
  },
};

export default assetsApi;
