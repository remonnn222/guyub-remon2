import { useCallback, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '@/stores/authStore';
import { tokenManager } from '@/api/client';
import { LoginCredentials } from '@/types';

export function useAuth() {
  const navigate = useNavigate();
  const {
    user,
    isAuthenticated,
    isLoading,
    login: storeLogin,
    logout: storeLogout,
    fetchUser,
    hasPermission,
    hasRole,
    hasAnyPermission,
    hasAnyRole,
    isSuperAdmin,
  } = useAuthStore();

  // Initialize auth state on mount
  useEffect(() => {
    if (tokenManager.hasTokens() && !user) {
      fetchUser().catch(() => {
        // Token invalid, redirect to login
        navigate('/login', { replace: true });
      });
    }
  }, [fetchUser, navigate, user]);

  const login = useCallback(
    async (credentials: LoginCredentials) => {
      await storeLogin(credentials);
      navigate('/dashboard', { replace: true });
    },
    [storeLogin, navigate]
  );

  const logout = useCallback(async () => {
    await storeLogout();
    navigate('/login', { replace: true });
  }, [storeLogout, navigate]);

  return {
    user,
    isAuthenticated,
    isLoading,
    login,
    logout,
    hasPermission,
    hasRole,
    hasAnyPermission,
    hasAnyRole,
    isSuperAdmin,
  };
}

export default useAuth;
