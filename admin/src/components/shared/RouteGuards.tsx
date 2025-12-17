import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuthStore } from '@/stores/authStore';
import { tokenManager } from '@/api/client';
import { LoadingOverlay } from '@/components/ui';

/**
 * Protected route - only accessible when authenticated
 */
export const ProtectedRoute: React.FC = () => {
  const location = useLocation();
  const { isAuthenticated, isLoading } = useAuthStore();
  const hasToken = tokenManager.hasTokens();

  // Show loading while checking auth
  if (isLoading) {
    return <LoadingOverlay message="Checking authentication..." />;
  }

  // If no token, redirect to login
  if (!hasToken) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // If has token but not authenticated yet, show loading
  if (!isAuthenticated) {
    return <LoadingOverlay message="Loading user data..." />;
  }

  return <Outlet />;
};

/**
 * Guest route - only accessible when NOT authenticated
 */
export const GuestRoute: React.FC = () => {
  const location = useLocation();
  const { isAuthenticated } = useAuthStore();
  const hasToken = tokenManager.hasTokens();

  // If authenticated, redirect to dashboard or previous location
  if (hasToken && isAuthenticated) {
    const from = (location.state as { from?: Location })?.from?.pathname || '/dashboard';
    return <Navigate to={from} replace />;
  }

  return <Outlet />;
};

/**
 * Permission-based route guard
 */
interface PermissionRouteProps {
  permission: string;
  fallback?: React.ReactNode;
}

export const PermissionRoute: React.FC<PermissionRouteProps> = ({
  permission,
  fallback,
}) => {
  const { hasPermission, isSuperAdmin } = useAuthStore();

  if (!isSuperAdmin() && !hasPermission(permission)) {
    return (
      fallback || (
        <div className="flex flex-col items-center justify-center min-h-[400px]">
          <h1 className="text-2xl font-bold text-gray-900">Access Denied</h1>
          <p className="mt-2 text-gray-600">
            You don&apos;t have permission to access this page.
          </p>
          <a href="/dashboard" className="mt-4 text-primary-600 hover:underline">
            Go to Dashboard
          </a>
        </div>
      )
    );
  }

  return <Outlet />;
};

export default ProtectedRoute;
