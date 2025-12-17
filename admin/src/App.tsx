import { useEffect } from 'react';
import { RouterProvider } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import router from './router';
import { useAuthStore } from '@/stores/authStore';
import { tokenManager } from '@/api/client';
import { LoadingOverlay } from '@/components/ui';

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 30000, // 30 seconds
    },
  },
});

function AppContent() {
  const { fetchUser, isLoading } = useAuthStore();

  // Fetch user on app load if token exists
  useEffect(() => {
    if (tokenManager.hasTokens()) {
      fetchUser().catch(() => {
        // Token invalid, will redirect via ProtectedRoute
      });
    }
  }, [fetchUser]);

  // Show loading while fetching initial user
  if (tokenManager.hasTokens() && isLoading) {
    return <LoadingOverlay message="Loading..." />;
  }

  return <RouterProvider router={router} />;
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AppContent />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}

export default App;
