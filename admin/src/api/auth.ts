import apiClient, { tokenManager } from './client';
import { ApiResponse, AuthTokens, LoginCredentials, User } from '@/types';

export const authApi = {
  /**
   * Login with email and password
   */
  login: async (credentials: LoginCredentials): Promise<ApiResponse<{ user: User; tokens: AuthTokens }>> => {
    const response = await apiClient.post<ApiResponse<{ user: User; tokens: AuthTokens }>>(
      '/auth/login',
      credentials
    );

    // Store tokens
    if (response.data.success) {
      tokenManager.setTokens(response.data.data.tokens);
    }

    return response.data;
  },

  /**
   * Logout current user
   */
  logout: async (): Promise<void> => {
    try {
      await apiClient.post('/auth/logout');
    } finally {
      tokenManager.clearTokens();
    }
  },

  /**
   * Refresh access token
   */
  refresh: async (): Promise<ApiResponse<AuthTokens>> => {
    const refreshToken = tokenManager.getRefreshToken();
    const response = await apiClient.post<ApiResponse<AuthTokens>>('/auth/refresh', {
      refresh_token: refreshToken,
    });

    if (response.data.success) {
      tokenManager.setTokens(response.data.data);
    }

    return response.data;
  },

  /**
   * Get current authenticated user
   */
  me: async (): Promise<ApiResponse<User>> => {
    const response = await apiClient.get<ApiResponse<User>>('/auth/me');
    return response.data;
  },

  /**
   * Update current user profile
   */
  updateProfile: async (data: Partial<User>): Promise<ApiResponse<User>> => {
    const response = await apiClient.put<ApiResponse<User>>('/auth/profile', data);
    return response.data;
  },

  /**
   * Change password
   */
  changePassword: async (data: {
    current_password: string;
    new_password: string;
    new_password_confirmation: string;
  }): Promise<ApiResponse<null>> => {
    const response = await apiClient.put<ApiResponse<null>>('/auth/password', data);
    return response.data;
  },

  /**
   * Check if user is authenticated
   */
  isAuthenticated: (): boolean => {
    return tokenManager.hasTokens();
  },
};

export default authApi;
