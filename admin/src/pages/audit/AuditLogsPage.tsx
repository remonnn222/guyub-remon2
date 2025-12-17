import React, { useState, useEffect } from 'react';
import { useQuery, keepPreviousData } from '@tanstack/react-query';
import {
  DocumentMagnifyingGlassIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
  ArrowPathIcon,
  FunnelIcon,
  MagnifyingGlassIcon,
  ChevronDownIcon,
  ChevronUpIcon,
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
import { auditApi } from '@/api/audit';
import { usePagination, useDebounce } from '@/hooks';
import { AuditLog, AuditEvent } from '@/types';

const AuditLogsPage: React.FC = () => {
  const [search, setSearch] = useState('');
  const [eventFilter, setEventFilter] = useState<string>('');
  const [typeFilter, setTypeFilter] = useState<string>('');
  const [showFilters, setShowFilters] = useState(false);
  const [expandedLog, setExpandedLog] = useState<number | null>(null);

  const debouncedSearch = useDebounce(search, 300);
  const pagination = usePagination({ initialSortBy: 'created_at', initialSortOrder: 'desc' });

  // Fetch audit logs
  const { data, isLoading, isFetching } = useQuery({
    queryKey: [
      'audit-logs',
      pagination.params,
      debouncedSearch,
      eventFilter,
      typeFilter,
    ],
    queryFn: () =>
      auditApi.getAll({
        ...pagination.params,
        event: eventFilter as AuditEvent || undefined,
        auditable_type: typeFilter || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  const audits = data?.data ?? [];
  const meta = data?.meta;

  // Update pagination meta when data changes
  useEffect(() => {
    if (meta) {
      pagination.updateMeta(meta);
    }
  }, [meta]);

  const getEventBadge = (event: string) => {
    const badges: Record<string, { variant: 'success' | 'warning' | 'danger' | 'info' | 'gray'; label: string; icon: React.ReactNode }> = {
      created: { variant: 'success', label: 'Created', icon: <PlusIcon className="h-3 w-3" /> },
      updated: { variant: 'info', label: 'Updated', icon: <PencilIcon className="h-3 w-3" /> },
      deleted: { variant: 'danger', label: 'Deleted', icon: <TrashIcon className="h-3 w-3" /> },
      restored: { variant: 'warning', label: 'Restored', icon: <ArrowPathIcon className="h-3 w-3" /> },
    };
    const badge = badges[event] || { variant: 'gray' as const, label: event, icon: null };
    return (
      <Badge variant={badge.variant}>
        <span className="flex items-center gap-1">
          {badge.icon}
          {badge.label}
        </span>
      </Badge>
    );
  };

  const formatEntityType = (type: string) => {
    return type.split('\\').pop() || type;
  };

  const eventOptions = [
    { value: '', label: 'All Events' },
    { value: 'created', label: 'Created' },
    { value: 'updated', label: 'Updated' },
    { value: 'deleted', label: 'Deleted' },
    { value: 'restored', label: 'Restored' },
  ];

  const typeOptions = [
    { value: '', label: 'All Types' },
    { value: 'User', label: 'User' },
    { value: 'Role', label: 'Role' },
    { value: 'Permission', label: 'Permission' },
    { value: 'MasterType', label: 'Master Type' },
    { value: 'MasterValue', label: 'Master Value' },
  ];

  const renderChanges = (oldValues: Record<string, unknown> | null, newValues: Record<string, unknown> | null) => {
    if (!oldValues && !newValues) return <span className="text-gray-400">-</span>;

    const allKeys = new Set([
      ...Object.keys(oldValues || {}),
      ...Object.keys(newValues || {}),
    ]);

    const changedKeys = Array.from(allKeys).filter(key => {
      if (['password', 'remember_token', 'updated_at', 'created_at', 'roles', 'email_verified_at', 'deleted_at'].includes(key)) return false;
      const oldVal = oldValues?.[key];
      const newVal = newValues?.[key];
      return JSON.stringify(oldVal) !== JSON.stringify(newVal);
    });

    if (changedKeys.length === 0) return <span className="text-gray-400">No visible changes</span>;

    return (
      <div className="space-y-1">
        {changedKeys.slice(0, 3).map(key => (
          <div key={key} className="text-xs">
            <span className="font-medium text-gray-600">{key}:</span>{' '}
            {oldValues?.[key] !== undefined && (
              <span className="text-red-600 line-through mr-1">
                {String(oldValues[key]).substring(0, 20)}
              </span>
            )}
            {newValues?.[key] !== undefined && (
              <span className="text-green-600">
                {String(newValues[key]).substring(0, 20)}
              </span>
            )}
          </div>
        ))}
        {changedKeys.length > 3 && (
          <span className="text-xs text-gray-400">+{changedKeys.length - 3} more</span>
        )}
      </div>
    );
  };

  // Calculate actual total pages
  const actualTotalPages = meta ? Math.ceil(meta.total / meta.per_page) : 1;

  return (
    <div className="space-y-4">
      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
        <div>
          <h1 className="page-title">Audit Logs</h1>
          <p className="page-description">Track all data changes across the system</p>
        </div>
        {isFetching && (
          <Button variant="ghost" disabled size="sm">
            <ArrowPathIcon className="h-4 w-4 animate-spin" />
          </Button>
        )}
      </div>

      {/* Filters */}
      <Card>
        <CardBody className="py-3">
          <div className="flex flex-col sm:flex-row gap-3">
            <div className="flex-1">
              <Input
                placeholder="Search by user, entity..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                leftIcon={<MagnifyingGlassIcon className="h-4 w-4" />}
              />
            </div>
            <Button
              variant="secondary"
              size="sm"
              leftIcon={<FunnelIcon className="h-4 w-4" />}
              onClick={() => setShowFilters(!showFilters)}
            >
              Filters
            </Button>
          </div>

          {showFilters && (
            <div className="mt-3 pt-3 border-t border-gray-200 grid grid-cols-1 sm:grid-cols-2 gap-3">
              <Select
                options={eventOptions}
                value={eventFilter}
                onChange={(e) => setEventFilter(e.target.value)}
                placeholder="Event Type"
              />
              <Select
                options={typeOptions}
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                placeholder="Entity Type"
              />
            </div>
          )}
        </CardBody>
      </Card>

      {/* Audit Table */}
      <Card>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Event
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Entity
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Changes
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  IP Address
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-4 py-8">
                    <InlineLoader message="Loading audit logs..." />
                  </td>
                </tr>
              ) : audits.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-4 py-8 text-center text-gray-500">
                    <DocumentMagnifyingGlassIcon className="h-10 w-10 mx-auto mb-2 text-gray-300" />
                    <p>No audit logs found</p>
                  </td>
                </tr>
              ) : (
                audits.map((audit: AuditLog) => (
                  <React.Fragment key={audit.id}>
                    <tr
                      className="hover:bg-gray-50 cursor-pointer"
                      onClick={() => setExpandedLog(expandedLog === audit.id ? null : audit.id)}
                    >
                      <td className="px-4 py-3 whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <Avatar name={audit.user?.name || 'System'} size="sm" />
                          <span className="text-sm font-medium text-gray-900">
                            {audit.user?.name || 'System'}
                          </span>
                        </div>
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap">
                        {getEventBadge(audit.event)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap">
                        <div className="flex items-center gap-2">
                          <Badge variant="gray">{formatEntityType(audit.auditable_type)}</Badge>
                          {audit.auditable_id && (
                            <span className="text-xs text-gray-500">#{audit.auditable_id}</span>
                          )}
                        </div>
                      </td>
                      <td className="px-4 py-3">
                        {renderChanges(audit.old_values, audit.new_values)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                        {audit.ip_address || '-'}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap">
                        <div className="text-sm text-gray-900">
                          {new Date(audit.created_at).toLocaleDateString()}
                        </div>
                        <div className="text-xs text-gray-500">
                          {new Date(audit.created_at).toLocaleTimeString()}
                        </div>
                      </td>
                    </tr>
                    {expandedLog === audit.id && (
                      <tr>
                        <td colSpan={6} className="px-4 py-3 bg-gray-50">
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <h4 className="text-xs font-semibold text-gray-500 uppercase mb-2">Old Values</h4>
                              <pre className="text-xs bg-red-50 p-2 rounded overflow-auto max-h-40">
                                {audit.old_values ? JSON.stringify(audit.old_values, null, 2) : 'N/A'}
                              </pre>
                            </div>
                            <div>
                              <h4 className="text-xs font-semibold text-gray-500 uppercase mb-2">New Values</h4>
                              <pre className="text-xs bg-green-50 p-2 rounded overflow-auto max-h-40">
                                {audit.new_values ? JSON.stringify(audit.new_values, null, 2) : 'N/A'}
                              </pre>
                            </div>
                          </div>
                          {audit.url && (
                            <div className="mt-2 text-xs text-gray-500">
                              <span className="font-medium">URL:</span> {audit.url}
                            </div>
                          )}
                        </td>
                      </tr>
                    )}
                  </React.Fragment>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {meta && meta.total > 0 && (
          <Pagination
            currentPage={meta.current_page}
            totalPages={actualTotalPages}
            totalItems={meta.total}
            from={meta.from}
            to={meta.to}
            onPageChange={pagination.goToPage}
            perPage={pagination.perPage}
            onPerPageChange={pagination.changePerPage}
          />
        )}
      </Card>
    </div>
  );
};

export default AuditLogsPage;
