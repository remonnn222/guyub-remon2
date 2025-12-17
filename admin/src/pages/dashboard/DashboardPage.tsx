import { useQuery } from '@tanstack/react-query';
import {
  UsersIcon,
  ShieldCheckIcon,
  DocumentTextIcon,
  ClockIcon,
} from '@heroicons/react/24/outline';
import { Card, CardBody, InlineLoader, Avatar, Badge } from '@/components/ui';
import { analyticsApi } from '@/api/audit';
import { useAuthStore } from '@/stores/authStore';

interface StatCardProps {
  title: string;
  value: string | number;
  icon: React.ComponentType<React.SVGProps<SVGSVGElement>>;
  change?: string;
  changeType?: 'increase' | 'decrease';
}

const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  icon: Icon,
  change,
  changeType,
}) => {
  return (
    <Card>
      <CardBody>
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-gray-500">{title}</p>
            <p className="mt-1 text-3xl font-semibold text-gray-900">{value}</p>
            {change && (
              <p
                className={`mt-1 text-sm ${
                  changeType === 'increase' ? 'text-green-600' : 'text-red-600'
                }`}
              >
                {changeType === 'increase' ? '+' : '-'}
                {change} from last month
              </p>
            )}
          </div>
          <div className="p-3 bg-primary-50 rounded-lg">
            <Icon className="h-8 w-8 text-primary-600" />
          </div>
        </div>
      </CardBody>
    </Card>
  );
};

const DashboardPage: React.FC = () => {
  const { user } = useAuthStore();

  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: () => analyticsApi.getDashboardStats(),
    staleTime: 60000, // 1 minute
  });

  if (isLoading) {
    return <InlineLoader message="Loading dashboard..." />;
  }

  const dashboardStats = stats?.data;

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="page-header">
        <h1 className="page-title">Dashboard</h1>
        <p className="page-description">
          Welcome back, {user?.name}! Here&apos;s what&apos;s happening.
        </p>
      </div>

      {/* Stats grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Users"
          value={dashboardStats?.total_users ?? 0}
          icon={UsersIcon}
          change="12%"
          changeType="increase"
        />
        <StatCard
          title="Active Users"
          value={dashboardStats?.active_users ?? 0}
          icon={UsersIcon}
        />
        <StatCard
          title="Total Roles"
          value={dashboardStats?.total_roles ?? 0}
          icon={ShieldCheckIcon}
        />
        <StatCard
          title="Permissions"
          value={dashboardStats?.total_permissions ?? 0}
          icon={DocumentTextIcon}
        />
      </div>

      {/* Recent activities */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">
              Recent Activities
            </h3>
          </div>
          <CardBody>
            {dashboardStats?.recent_activities?.length ? (
              <div className="space-y-4">
                {dashboardStats.recent_activities.slice(0, 5).map((activity) => (
                  <div key={activity.id} className="flex items-start gap-4">
                    <Avatar
                      name={activity.user?.name || 'Unknown'}
                      src={activity.user?.avatar}
                      size="sm"
                    />
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-gray-900">
                        <span className="font-medium">
                          {activity.user?.name || 'Unknown'}
                        </span>{' '}
                        {activity.description || activity.activity_type}
                      </p>
                      <p className="text-xs text-gray-500">
                        {new Date(activity.created_at).toLocaleString()}
                      </p>
                    </div>
                    <Badge variant="gray" size="sm">
                      {activity.activity_type}
                    </Badge>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-sm text-gray-500 text-center py-8">
                No recent activities
              </p>
            )}
          </CardBody>
        </Card>

        {/* Quick actions */}
        <Card>
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">Quick Actions</h3>
          </div>
          <CardBody>
            <div className="grid grid-cols-2 gap-4">
              <a
                href="/users/create"
                className="flex items-center gap-3 p-4 rounded-lg border border-gray-200 hover:border-primary-300 hover:bg-primary-50 transition-colors"
              >
                <UsersIcon className="h-6 w-6 text-primary-600" />
                <span className="text-sm font-medium text-gray-900">
                  Add User
                </span>
              </a>
              <a
                href="/roles/create"
                className="flex items-center gap-3 p-4 rounded-lg border border-gray-200 hover:border-primary-300 hover:bg-primary-50 transition-colors"
              >
                <ShieldCheckIcon className="h-6 w-6 text-primary-600" />
                <span className="text-sm font-medium text-gray-900">
                  Create Role
                </span>
              </a>
              <a
                href="/audit"
                className="flex items-center gap-3 p-4 rounded-lg border border-gray-200 hover:border-primary-300 hover:bg-primary-50 transition-colors"
              >
                <DocumentTextIcon className="h-6 w-6 text-primary-600" />
                <span className="text-sm font-medium text-gray-900">
                  View Audit Logs
                </span>
              </a>
              <a
                href="/activity"
                className="flex items-center gap-3 p-4 rounded-lg border border-gray-200 hover:border-primary-300 hover:bg-primary-50 transition-colors"
              >
                <ClockIcon className="h-6 w-6 text-primary-600" />
                <span className="text-sm font-medium text-gray-900">
                  Activity History
                </span>
              </a>
            </div>
          </CardBody>
        </Card>
      </div>
    </div>
  );
};

export default DashboardPage;
