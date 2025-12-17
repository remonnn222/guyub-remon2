import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import {
  PlusIcon,
  PencilIcon,
  TrashIcon,
  ArrowPathIcon,
  FunnelIcon,
  MagnifyingGlassIcon,
} from '@heroicons/react/24/outline';
import {
  Button,
  Input,
  Select,
  DataTable,
  Pagination,
  Card,
  CardBody,
  Avatar,
  StatusBadge,
  Badge,
  ConfirmDialog,
  InlineLoader,
} from '@/components/ui';
import { usersApi } from '@/api/users';
import { useAuthStore } from '@/stores/authStore';
import { toast } from '@/stores/uiStore';
import { usePagination, useDebounce } from '@/hooks';
import { User, UserStatus, UserType, TableColumn } from '@/types';

const UsersListPage: React.FC = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { hasPermission, user: currentUser } = useAuthStore();

  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [typeFilter, setTypeFilter] = useState<string>('');
  const [showFilters, setShowFilters] = useState(false);
  const [selectedIds, setSelectedIds] = useState<number[]>([]);
  const [deleteConfirm, setDeleteConfirm] = useState<{
    isOpen: boolean;
    userId?: number;
    userName?: string;
  }>({ isOpen: false });

  const debouncedSearch = useDebounce(search, 300);
  const pagination = usePagination({ initialSortBy: 'created_at' });

  // Fetch users
  const { data, isLoading, isFetching } = useQuery({
    queryKey: [
      'users',
      pagination.params,
      debouncedSearch,
      statusFilter,
      typeFilter,
    ],
    queryFn: () =>
      usersApi.getAll({
        ...pagination.params,
        search: debouncedSearch || undefined,
        status: (statusFilter as UserStatus) || undefined,
        type: (typeFilter as UserType) || undefined,
      }),
    placeholderData: keepPreviousData,
  });

  // Safely access response data
  const users = data?.data ?? [];
  const meta = data?.meta;

  // Update pagination meta when data changes
  useEffect(() => {
    if (meta) {
      pagination.updateMeta(meta);
    }
  }, [meta]);

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: number) => usersApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success('User deleted', 'The user has been deleted successfully.');
      setDeleteConfirm({ isOpen: false });
    },
    onError: () => {
      toast.error('Delete failed', 'Failed to delete the user.');
    },
  });

  // Bulk delete mutation
  const bulkDeleteMutation = useMutation({
    mutationFn: (ids: number[]) => usersApi.bulkDelete(ids),
    onSuccess: (response) => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success(
        'Users deleted',
        `${response.data.affected} users have been deleted.`
      );
      setSelectedIds([]);
    },
    onError: () => {
      toast.error('Delete failed', 'Failed to delete the selected users.');
    },
  });

  const handleDelete = (user: User) => {
    if (user.id === currentUser?.id) {
      toast.error('Cannot delete', 'You cannot delete your own account.');
      return;
    }
    setDeleteConfirm({
      isOpen: true,
      userId: user.id,
      userName: user.name,
    });
  };

  const confirmDelete = () => {
    if (deleteConfirm.userId) {
      deleteMutation.mutate(deleteConfirm.userId);
    }
  };

  const handleBulkDelete = () => {
    if (selectedIds.includes(currentUser?.id || 0)) {
      toast.error('Cannot delete', 'You cannot delete your own account.');
      return;
    }
    bulkDeleteMutation.mutate(selectedIds);
  };

  const handleSelectRow = (id: string | number) => {
    setSelectedIds((prev) =>
      prev.includes(id as number)
        ? prev.filter((i) => i !== id)
        : [...prev, id as number]
    );
  };

  const handleSelectAll = (selected: boolean) => {
    if (selected && users.length > 0) {
      setSelectedIds(users.map((u: User) => u.id));
    } else {
      setSelectedIds([]);
    }
  };

  const columns: TableColumn<User>[] = [
    {
      key: 'name',
      label: 'User',
      sortable: true,
      render: (user) => (
        <div className="flex items-center gap-3">
          <Avatar name={user.name} src={user.avatar_url} size="sm" />
          <div>
            <p className="font-medium text-gray-900">{user.name}</p>
            <p className="text-sm text-gray-500">{user.email}</p>
          </div>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      sortable: true,
      render: (user) => <StatusBadge status={user.status} />,
    },
    {
      key: 'type',
      label: 'Type',
      sortable: true,
      render: (user) => {
        const typeValue = typeof user.type === 'object' ? user.type?.label || user.type?.value : user.type;
        return (
          <Badge variant="gray">
            {typeValue || 'N/A'}
          </Badge>
        );
      },
    },
    {
      key: 'roles',
      label: 'Roles',
      render: (user) => (
        <div className="flex flex-wrap gap-1">
          {user.roles?.slice(0, 2).map((role, index) => (
            <Badge key={typeof role === 'string' ? role : role.id || index} variant="primary" size="sm">
              {typeof role === 'string' ? role : role.name}
            </Badge>
          ))}
          {user.roles && user.roles.length > 2 && (
            <Badge variant="gray" size="sm">
              +{user.roles.length - 2}
            </Badge>
          )}
        </div>
      ),
    },
    {
      key: 'created_at',
      label: 'Created',
      sortable: true,
      render: (user) => (
        <span className="text-sm text-gray-500">
          {new Date(user.created_at).toLocaleDateString()}
        </span>
      ),
    },
    {
      key: 'actions',
      label: '',
      className: 'text-right',
      render: (user) => (
        <div className="flex items-center justify-end gap-2">
          {hasPermission('users.edit') && (
            <button
              onClick={() => navigate(`/users/${user.id}/edit`)}
              className="p-1 text-gray-400 hover:text-primary-600"
              title="Edit"
            >
              <PencilIcon className="h-5 w-5" />
            </button>
          )}
          {hasPermission('users.delete') && user.id !== currentUser?.id && (
            <button
              onClick={() => handleDelete(user)}
              className="p-1 text-gray-400 hover:text-red-600"
              title="Delete"
            >
              <TrashIcon className="h-5 w-5" />
            </button>
          )}
        </div>
      ),
    },
  ];

  const statusOptions = [
    { value: '', label: 'All Status' },
    { value: 'active', label: 'Active' },
    { value: 'inactive', label: 'Inactive' },
    { value: 'suspended', label: 'Suspended' },
  ];

  const typeOptions = [
    { value: '', label: 'All Types' },
    { value: 'internal', label: 'Internal' },
    { value: 'customer', label: 'Customer' },
    { value: 'agent', label: 'Agent' },
  ];

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="page-title">Users</h1>
          <p className="page-description">Manage user accounts and permissions</p>
        </div>
        {hasPermission('users.create') && (
          <Link to="/users/create">
            <Button leftIcon={<PlusIcon className="h-5 w-5" />}>
              Add User
            </Button>
          </Link>
        )}
      </div>

      {/* Filters */}
      <Card>
        <CardBody>
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <Input
                placeholder="Search users..."
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
            <div className="mt-4 pt-4 border-t border-gray-200 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <Select
                options={statusOptions}
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                placeholder="Status"
              />
              <Select
                options={typeOptions}
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                placeholder="Type"
              />
            </div>
          )}

          {/* Bulk actions */}
          {selectedIds.length > 0 && (
            <div className="mt-4 pt-4 border-t border-gray-200 flex items-center gap-4">
              <span className="text-sm text-gray-500">
                {selectedIds.length} selected
              </span>
              {hasPermission('users.delete') && (
                <Button
                  variant="danger"
                  size="sm"
                  onClick={handleBulkDelete}
                  loading={bulkDeleteMutation.isPending}
                >
                  Delete Selected
                </Button>
              )}
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setSelectedIds([])}
              >
                Clear Selection
              </Button>
            </div>
          )}
        </CardBody>

        {/* Data table */}
        {isLoading ? (
          <InlineLoader message="Loading users..." />
        ) : (
          <>
            <DataTable
              columns={columns}
              data={users}
              rowKey="id"
              sortBy={pagination.sortBy}
              sortOrder={pagination.sortOrder}
              onSort={pagination.changeSort}
              selectedRows={selectedIds}
              onSelectRow={handleSelectRow}
              onSelectAll={handleSelectAll}
              emptyMessage="No users found"
            />
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
          </>
        )}
      </Card>

      {/* Delete confirmation dialog */}
      <ConfirmDialog
        isOpen={deleteConfirm.isOpen}
        onClose={() => setDeleteConfirm({ isOpen: false })}
        onConfirm={confirmDelete}
        title="Delete User"
        message={`Are you sure you want to delete "${deleteConfirm.userName}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
};

export default UsersListPage;
