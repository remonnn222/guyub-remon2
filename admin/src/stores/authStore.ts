import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { authApi } from '@/api/auth';
import { tokenManager } from '@/api/client';
import { AuthState, LoginCredentials, User } from '@/types';

interface AuthStore extends AuthState {
  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => Promise<void>;
  fetchUser: () => Promise<void>;
  setUser: (user: User | null) => void;
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
  hasAnyPermission: (permissions: string[]) => boolean;
  hasAnyRole: (roles: string[]) => boolean;
  isSuperAdmin: () => boolean;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      // Initial state
      user: null,
      tokens: null,
      isAuthenticated: false,
      isLoading: false,

      // Actions
      login: async (credentials: LoginCredentials) => {
        set({ isLoading: true });
        try {
          const response = await authApi.login(credentials);
          set({
            user: response.data.user,
            tokens: response.data.tokens,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          set({ isLoading: false });
          throw error;
        }
      },

      logout: async () => {
        set({ isLoading: true });
        try {
          await authApi.logout();
        } finally {
          tokenManager.clearTokens();
          set({
            user: null,
            tokens: null,
            isAuthenticated: false,
            isLoading: false,
          });
        }
      },

      fetchUser: async () => {
        if (!tokenManager.hasTokens()) {
          set({ user: null, isAuthenticated: false });
          return;
        }

        set({ isLoading: true });
        try {
          const response = await authApi.me();
          set({
            user: response.data,
            isAuthenticated: true,
            isLoading: false,
          });
        } catch (error) {
          tokenManager.clearTokens();
          set({
            user: null,
            tokens: null,
            isAuthenticated: false,
            isLoading: false,
          });
          throw error;
        }
      },

      setUser: (user: User | null) => {
        set({ user, isAuthenticated: !!user });
      },

      hasPermission: (permission: string) => {
        const { user } = get();
        if (!user) return false;

        // Super admin bypasses all permission checks
        if (user.roles?.some((role) => role.name === 'super_admin')) {
          return true;
        }

        // Check direct permissions
        if (user.permissions?.some((p) => p.name === permission)) {
          return true;
        }

        // Check role permissions
        return user.roles?.some((role) =>
          role.permissions?.some((p) => p.name === permission)
        ) ?? false;
      },

      hasRole: (role: string) => {
        const { user } = get();
        return user?.roles?.some((r) => r.name === role) ?? false;
      },

      hasAnyPermission: (permissions: string[]) => {
        const { hasPermission } = get();
        return permissions.some((permission) => hasPermission(permission));
      },

      hasAnyRole: (roles: string[]) => {
        const { hasRole } = get();
        return roles.some((role) => hasRole(role));
      },

      isSuperAdmin: () => {
        const { hasRole } = get();
        return hasRole('super_admin');
      },
    }),
    {
      name: 'guyub-auth',
      partialize: (state) => ({
        user: state.user,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);

export default useAuthStore;
