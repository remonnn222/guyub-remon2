import { useQuery } from '@tanstack/react-query';
import {
  UsersIcon,
  ShieldCheckIcon,
  KeyIcon,
  ChartBarIcon,
  ArrowTrendingUpIcon,
  ClockIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  CardBody,
  InlineLoader,
} from '@/components/ui';
import apiClient from '@/api/client';

interface DashboardStats {
  total_users: number;
  active_users: number;
  total_roles: number;
  total_permissions: number;
  recent_activities: Array<{
    id: number;
    user_id: number;
    activity_type: string;
    description: string;
    ip_address: string;
    created_at: string;
  }>;
  user_growth: Array<{ label: string; value: number }>;
  activity_trends: Array<{ label: string; value: number }>;
}

const AnalyticsPage: React.FC = () => {
  const { data, isLoading } = useQuery({
    queryKey: ['analytics-dashboard'],
    queryFn: async () => {
      const response = await apiClient.get<{ success: boolean; data: DashboardStats }>('/analytics/dashboard');
      return response.data;
    },
  });

  const stats = data?.data;

  if (isLoading) {
    return <InlineLoader message="Loading analytics..." />;
  }

  const statCards = [
    {
      title: 'Total Users',
      value: stats?.total_users || 0,
      icon: UsersIcon,
      color: 'bg-blue-100 text-blue-600',
      change: '+12%',
      changeType: 'positive',
    },
    {
      title: 'Active Users',
      value: stats?.active_users || 0,
      icon: ArrowTrendingUpIcon,
      color: 'bg-green-100 text-green-600',
      change: `${Math.round(((stats?.active_users || 0) / (stats?.total_users || 1)) * 100)}%`,
      changeType: 'neutral',
    },
    {
      title: 'Total Roles',
      value: stats?.total_roles || 0,
      icon: ShieldCheckIcon,
      color: 'bg-purple-100 text-purple-600',
    },
    {
      title: 'Permissions',
      value: stats?.total_permissions || 0,
      icon: KeyIcon,
      color: 'bg-amber-100 text-amber-600',
    },
  ];

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="page-title">Analytics</h1>
        <p className="page-description">System metrics and usage statistics</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((stat) => (
          <Card key={stat.title}>
            <CardBody className="flex items-center gap-4">
              <div className={`p-3 rounded-lg ${stat.color}`}>
                <stat.icon className="h-6 w-6" />
              </div>
              <div className="flex-1">
                <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                <p className="text-sm text-gray-500">{stat.title}</p>
              </div>
              {stat.change && (
                <span className={`text-sm font-medium ${
                  stat.changeType === 'positive' ? 'text-green-600' : 'text-gray-500'
                }`}>
                  {stat.change}
                </span>
              )}
            </CardBody>
          </Card>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Growth Chart */}
        <Card>
          <CardBody>
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <ChartBarIcon className="h-5 w-5 text-primary-600" />
              User Growth
            </h3>
            <div className="h-64 flex items-end gap-2 px-4">
              {(stats?.user_growth || []).map((item, index) => (
                <div key={index} className="flex-1 flex flex-col items-center gap-2">
                  <div
                    className="w-full bg-primary-500 rounded-t transition-all hover:bg-primary-600"
                    style={{ height: `${Math.max(item.value * 20, 10)}px` }}
                  />
                  <span className="text-xs text-gray-500">{item.label}</span>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>

        {/* Activity Trends Chart */}
        <Card>
          <CardBody>
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <ArrowTrendingUpIcon className="h-5 w-5 text-primary-600" />
              Activity Trends
            </h3>
            <div className="h-64 flex items-end gap-2 px-4">
              {(stats?.activity_trends || []).map((item, index) => (
                <div key={index} className="flex-1 flex flex-col items-center gap-2">
                  <div
                    className="w-full bg-blue-500 rounded-t transition-all hover:bg-blue-600"
                    style={{ height: `${Math.max(item.value * 20, 10)}px` }}
                  />
                  <span className="text-xs text-gray-500">{item.label}</span>
                </div>
              ))}
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card>
        <CardBody>
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <ClockIcon className="h-5 w-5 text-primary-600" />
            Recent Activity
          </h3>
          <div className="divide-y divide-gray-100">
            {(stats?.recent_activities || []).map((activity) => (
              <div key={activity.id} className="py-3 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 rounded-full bg-primary-500" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {activity.activity_type.replace('_', ' ')}
                    </p>
                    <p className="text-xs text-gray-500">
                      {activity.description || `User ${activity.user_id}`} - {activity.ip_address}
                    </p>
                  </div>
                </div>
                <span className="text-xs text-gray-400">
                  {new Date(activity.created_at).toLocaleString()}
                </span>
              </div>
            ))}
            {(!stats?.recent_activities || stats.recent_activities.length === 0) && (
              <p className="py-8 text-center text-gray-500">No recent activity</p>
            )}
          </div>
        </CardBody>
      </Card>
    </div>
  );
};

export default AnalyticsPage;
