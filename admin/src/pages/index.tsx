// Landing page
export { default as LandingPage } from './landing/LandingPage';

// Auth pages
export { default as LoginPage } from './auth/LoginPage';

// Dashboard
export { default as DashboardPage } from './dashboard/DashboardPage';

// Users
export { default as UsersListPage } from './users/UsersListPage';
export { default as UserFormPage } from './users/UserFormPage';

// Family Tree
export { default as FamilyTreePage } from './family/FamilyTreePage';

// Roles & Admin
export { default as RolesListPage } from './roles/RolesListPage';
export { default as MasterDataPage } from './master/MasterDataPage';
export { default as AuditLogsPage } from './audit/AuditLogsPage';
export { default as ActivityLogsPage } from './activity/ActivityLogsPage';
export { default as AnalyticsPage } from './analytics/AnalyticsPage';

// Profile
export { default as ProfilePage } from './profile/ProfilePage';

// Placeholder pages
export const FamiliesListPage = () => <div>Families List</div>;
export const NotFoundPage = () => (
  <div className="flex flex-col items-center justify-center min-h-[400px]">
    <h1 className="text-4xl font-bold text-gray-900">404</h1>
    <p className="mt-2 text-gray-600">Page not found</p>
    <a href="/dashboard" className="mt-4 text-primary-600 hover:underline">
      Go to Dashboard
    </a>
  </div>
);
