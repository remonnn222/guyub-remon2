import { useState, useEffect } from 'react';
import { useQuery, keepPreviousData } from '@tanstack/react-query';
import {
  ClockIcon,
  ComputerDesktopIcon,
  DevicePhoneMobileIcon,
  GlobeAltIcon,
  FunnelIcon,
  MagnifyingGlassIcon,
  ArrowPathIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  CardBody,
  Badge,
  Input,
  Select,
  Button,
  Pagination,
  InlineLoader,
  Avatar,
} from '@/components/ui';
import { activityApi } from '@/api/audit';
import { usePagination, useDebounce } from '@/hooks';
import { ActivityLog, ActivityType } from '@/types';

const ActivityLogsPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [activityTypeFilter, setActivityTypeFilter] = useState<string>('');
  const [showFilters, setShowFilters] = useState(false);

  const debouncedSearch = useDebounce(search, 300);
  const pagination = usePagination({ initialSortBy: 'created_at', initialSortOrder: 'desc' });

  // Fetch activity logs
  const { data, isLoading, isFetching } = useQuery({
    queryKey: [
      'activity-logs',
      pagination.params,
      debouncedSearch,
      activityTypeFilter,
    ],
    queryFn: () =>
      activityApi.getAll({
        ...pagination.params,
        activity_type: activityTypeFilter as ActivityType || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  const activities = data?.data ?? [];
  const meta = data?.meta;

  // Update pagination meta when data changes
  useEffect(() => {
    if (meta) {
      pagination.updateMeta(meta);
    }
  }, [meta]);

  const getActivityBadge = (type: string) => {
    const badges: Record<string, { variant: 'success' | 'warning' | 'danger' | 'info' | 'gray'; label: string }> = {
      login: { variant: 'success', label: 'Login' },
      logout: { variant: 'gray', label: 'Logout' },
      failed_login: { variant: 'danger', label: 'Failed Login' },
      password_reset: { variant: 'warning', label: 'Password Reset' },
      profile_update: { variant: 'info', label: 'Profile Update' },
    };
    const badge = badges[type] || { variant: 'gray' as const, label: type };
    return <Badge variant={badge.variant}>{badge.label}</Badge>;
  };

  const getDeviceIcon = (deviceType: string | null) => {
    if (!deviceType) return <GlobeAltIcon className="h-5 w-5 text-gray-400" />;
    if (deviceType.toLowerCase().includes('mobile')) {
      return <DevicePhoneMobileIcon className="h-5 w-5 text-gray-400" />;
    }
    return <ComputerDesktopIcon className="h-5 w-5 text-gray-400" />;
  };

  const activityTypeOptions = [
    { value: '', label: 'All Activities' },
    { value: 'login', label: 'Login' },
    { value: 'logout', label: 'Logout' },
    { value: 'failed_login', label: 'Failed Login' },
    { value: 'password_reset', label: 'Password Reset' },
    { value: 'profile_update', label: 'Profile Update' },
  ];

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="page-title">Activity Logs</h1>
        <p className="page-description">Track user login and session activities</p>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-green-100 rounded-lg">
              <ClockIcon className="h-6 w-6 text-green-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{meta?.total || 0}</p>
              <p className="text-sm text-gray-500">Total Activities</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <ComputerDesktopIcon className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {activities.filter((a: ActivityLog) => a.activity_type === 'login').length}
              </p>
              <p className="text-sm text-gray-500">Logins (this page)</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-red-100 rounded-lg">
              <ClockIcon className="h-6 w-6 text-red-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {activities.filter((a: ActivityLog) => a.activity_type === 'failed_login').length}
              </p>
              <p className="text-sm text-gray-500">Failed (this page)</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-purple-100 rounded-lg">
              <DevicePhoneMobileIcon className="h-6 w-6 text-purple-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {activities.filter((a: ActivityLog) => a.device_type?.toLowerCase().includes('mobile')).length}
              </p>
              <p className="text-sm text-gray-500">Mobile (this page)</p>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Filters */}
      <Card>
        <CardBody>
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <Input
                placeholder="Search by user, IP address..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                leftIcon={<MagnifyingGlassIcon className="h-5 w-5" />}
              />
            </div>
            <div className="flex gap-2">
              <Button
                variant="secondary"
                leftIcon={<FunnelIcon className="h-5 w-5" />}
                onClick={() => setShowFilters(!showFilters)}
              >
                Filters
              </Button>
              {isFetching && (
                <Button variant="ghost" disabled>
                  <ArrowPathIcon className="h-5 w-5 animate-spin" />
                </Button>
              )}
            </div>
          </div>

          {showFilters && (
            <div className="mt-4 pt-4 border-t border-gray-200 grid grid-cols-1 sm:grid-cols-3 gap-4">
              <Select
                options={activityTypeOptions}
                value={activityTypeFilter}
                onChange={(e) => setActivityTypeFilter(e.target.value)}
                placeholder="Activity Type"
              />
            </div>
          )}
        </CardBody>
      </Card>

      {/* Activity List */}
      <Card>
        <CardBody>
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <ClockIcon className="h-5 w-5 text-primary-600" />
            Recent Activities
          </h3>

          {isLoading ? (
            <InlineLoader message="Loading activities..." />
          ) : activities.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <ClockIcon className="h-12 w-12 mx-auto mb-3 text-gray-300" />
              <p>No activity logs found</p>
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {activities.map((activity: ActivityLog) => (
                <div key={activity.id} className="py-4 flex items-start gap-4">
                  {/* User Avatar */}
                  <div className="flex-shrink-0">
                    <Avatar
                      name={activity.user?.name || `User ${activity.user_id}`}
                      size="md"
                    />
                  </div>

                  {/* Activity Details */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="font-medium text-gray-900">
                        {activity.user?.name || `User ${activity.user_id}`}
                      </span>
                      {getActivityBadge(activity.activity_type)}
                    </div>
                    <p className="text-sm text-gray-500 mt-1">
                      {activity.description || `${activity.activity_type.replace('_', ' ')} activity`}
                    </p>
                    <div className="flex items-center gap-4 mt-2 text-xs text-gray-400 flex-wrap">
                      <span className="flex items-center gap-1">
                        {getDeviceIcon(activity.device_type)}
                        {activity.browser || 'Unknown'} on {activity.platform || 'Unknown'}
                      </span>
                      <span className="flex items-center gap-1">
                        <GlobeAltIcon className="h-4 w-4" />
                        {activity.ip_address || 'Unknown IP'}
                      </span>
                      {activity.location && (
                        <span>{activity.location}</span>
                      )}
                    </div>
                  </div>

                  {/* Timestamp */}
                  <div className="flex-shrink-0 text-right">
                    <p className="text-sm text-gray-500">
                      {new Date(activity.created_at).toLocaleDateString()}
                    </p>
                    <p className="text-xs text-gray-400">
                      {new Date(activity.created_at).toLocaleTimeString()}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardBody>

        {/* Pagination */}
        {pagination.paginationInfo && (
          <Pagination
            currentPage={pagination.paginationInfo.currentPage}
            totalPages={pagination.paginationInfo.totalPages}
            totalItems={pagination.paginationInfo.total}
            from={pagination.paginationInfo.from}
            to={pagination.paginationInfo.to}
            onPageChange={pagination.goToPage}
            perPage={pagination.perPage}
            onPerPageChange={pagination.changePerPage}
          />
        )}
      </Card>
    </div>
  );
};

export default ActivityLogsPage;
