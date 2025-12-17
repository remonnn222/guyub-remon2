// Auth pages
export { default as LoginPage } from './auth/LoginPage';

// Dashboard
export { default as DashboardPage } from './dashboard/DashboardPage';

// Users
export { default as UsersListPage } from './users/UsersListPage';

// Family Tree
export { default as FamilyTreePage } from './family/FamilyTreePage';

// Placeholder pages for other modules
export const RolesListPage = () => <div>Roles List</div>;
export const MasterDataPage = () => <div>Master Data</div>;
export const AuditLogsPage = () => <div>Audit Logs</div>;
export const ActivityLogsPage = () => <div>Activity Logs</div>;
export const AnalyticsPage = () => <div>Analytics</div>;
export const ProfilePage = () => <div>Profile</div>;
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
