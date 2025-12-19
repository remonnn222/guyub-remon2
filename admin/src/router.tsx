import { createBrowserRouter, Navigate } from 'react-router-dom';
import { MainLayout, AuthLayout } from '@/layouts';
import {
  LandingPage,
  LoginPage,
  DashboardPage,
  UsersListPage,
  UserFormPage,
  RolesListPage,
  MasterDataPage,
  AuditLogsPage,
  ActivityLogsPage,
  AnalyticsPage,
  ProfilePage,
  NotFoundPage,
  FamilyTreePage,
  FamiliesListPage,
} from '@/pages';
import { ProtectedRoute, GuestRoute } from '@/components/shared/RouteGuards';

const router = createBrowserRouter([
  // Public landing page with tree preview
  {
    path: '/',
    element: <LandingPage />,
  },
  // Auth routes (guest only)
  {
    element: <GuestRoute />,
    children: [
      {
        element: <AuthLayout />,
        children: [
          {
            path: 'login',
            element: <LoginPage />,
          },
        ],
      },
    ],
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <MainLayout />,
        children: [
          {
            path: 'dashboard',
            element: <DashboardPage />,
          },
          {
            path: 'users',
            children: [
              {
                index: true,
                element: <UsersListPage />,
              },
              {
                path: 'create',
                element: <UserFormPage />,
              },
              {
                path: ':id/edit',
                element: <UserFormPage />,
              },
            ],
          },
          {
            path: 'roles',
            children: [
              {
                index: true,
                element: <RolesListPage />,
              },
              {
                path: 'create',
                element: <div>Create Role</div>,
              },
              {
                path: ':id/edit',
                element: <div>Edit Role</div>,
              },
            ],
          },
          {
            path: 'master',
            children: [
              {
                index: true,
                element: <MasterDataPage />,
              },
            ],
          },
          {
            path: 'audit',
            element: <AuditLogsPage />,
          },
          {
            path: 'activity',
            element: <ActivityLogsPage />,
          },
          {
            path: 'analytics',
            element: <AnalyticsPage />,
          },
          {
            path: 'profile',
            element: <ProfilePage />,
          },
          {
            path: 'families',
            children: [
              {
                index: true,
                element: <FamiliesListPage />,
              },
              {
                path: ':id/tree',
                element: <FamilyTreePage />,
              },
            ],
          },
        ],
      },
    ],
  },
  // Family Tree standalone page (full screen)
  {
    path: 'tree/:id',
    element: <FamilyTreePage />,
  },
  // Demo page for family tree (no auth required)
  {
    path: 'demo/tree',
    element: <FamilyTreePage />,
  },
  {
    path: '*',
    element: <NotFoundPage />,
  },
]);

export default router;
