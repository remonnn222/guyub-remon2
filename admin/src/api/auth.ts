import apiClient, { tokenManager } from './client';
import { ApiResponse, AuthTokens, LoginCredentials, User } from '@/types';

// Backend login response structure (tokens are flat, not nested)
interface LoginApiResponse {
  user: User;
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

export const authApi = {
  /**
   * Login with email and password
   */
  login: async (credentials: LoginCredentials): Promise<ApiResponse<{ user: User; tokens: AuthTokens }>> => {
    const response = await apiClient.post<ApiResponse<LoginApiResponse>>(
      '/auth/login',
      credentials
    );

    // Store tokens (extract from flat structure)
    if (response.data.success) {
      const { access_token, refresh_token, token_type, expires_in } = response.data.data;
      const tokens: AuthTokens = { access_token, refresh_token, token_type, expires_in };
      tokenManager.setTokens(tokens);

      // Return in expected format
      return {
        ...response.data,
        data: {
          user: response.data.data.user,
          tokens,
        },
      };
    }

    return response.data as unknown as ApiResponse<{ user: User; tokens: AuthTokens }>;
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
    const response = await apiClient.post<ApiResponse<LoginApiResponse>>('/auth/refresh', {
      refresh_token: refreshToken,
    });

    if (response.data.success) {
      const { access_token, refresh_token, token_type, expires_in } = response.data.data;
      const tokens: AuthTokens = { access_token, refresh_token, token_type, expires_in };
      tokenManager.setTokens(tokens);

      return {
        ...response.data,
        data: tokens,
      };
    }

    return response.data as unknown as ApiResponse<AuthTokens>;
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
