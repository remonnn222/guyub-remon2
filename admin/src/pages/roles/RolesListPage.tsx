import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  ShieldCheckIcon,
  UsersIcon,
  KeyIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  CardBody,
  Badge,
  Button,
  Modal,
  Input,
  InlineLoader,
  ConfirmDialog,
} from '@/components/ui';
import { rolesApi, permissionsApi } from '@/api/roles';
import { Role, Permission, RoleFormData } from '@/types';

const RolesListPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [editingRole, setEditingRole] = useState<Role | null>(null);
  const [formData, setFormData] = useState<RoleFormData>({
    name: '',
    description: '',
    level: 50,
    permission_ids: [],
  });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});

  // Fetch roles
  const { data: rolesData, isLoading: rolesLoading } = useQuery({
    queryKey: ['roles'],
    queryFn: () => rolesApi.getAll(),
  });

  // Fetch permissions
  const { data: permissionsData } = useQuery({
    queryKey: ['permissions'],
    queryFn: () => permissionsApi.getAll(),
  });

  const roles = rolesData?.data ?? [];
  const permissions = permissionsData?.data ?? [];

  // Group permissions by module
  const groupedPermissions = permissions.reduce((acc: Record<string, Permission[]>, perm: Permission) => {
    const module = perm.name.split('.')[0];
    if (!acc[module]) acc[module] = [];
    acc[module].push(perm);
    return acc;
  }, {});

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: RoleFormData) => rolesApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      closeModal();
    },
    onError: (error: any) => {
      if (error.response?.data?.errors) {
        setFormErrors(error.response.data.errors);
      }
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<RoleFormData> }) =>
      rolesApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      closeModal();
    },
    onError: (error: any) => {
      if (error.response?.data?.errors) {
        setFormErrors(error.response.data.errors);
      }
    },
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: number) => rolesApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
      setIsDeleteOpen(false);
      setEditingRole(null);
      if (selectedRole?.id === editingRole?.id) {
        setSelectedRole(null);
      }
    },
  });

  // Update permissions mutation
  const updatePermissionsMutation = useMutation({
    mutationFn: ({ id, permissionIds }: { id: number; permissionIds: number[] }) =>
      rolesApi.updatePermissions(id, permissionIds),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['roles'] });
    },
  });

  const openCreateModal = () => {
    setEditingRole(null);
    setFormData({
      name: '',
      description: '',
      level: 50,
      permission_ids: [],
    });
    setFormErrors({});
    setIsModalOpen(true);
  };

  const openEditModal = (role: Role) => {
    setEditingRole(role);
    setFormData({
      name: role.name,
      description: role.description || '',
      level: role.level,
      permission_ids: role.permissions?.map((p) => p.id) || [],
    });
    setFormErrors({});
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingRole(null);
    setFormErrors({});
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const errors: Record<string, string> = {};

    if (!formData.name.trim()) {
      errors.name = 'Name is required';
    }

    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      return;
    }

    if (editingRole) {
      updateMutation.mutate({ id: editingRole.id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const handlePermissionToggle = (permissionId: number) => {
    setFormData((prev) => ({
      ...prev,
      permission_ids: prev.permission_ids.includes(permissionId)
        ? prev.permission_ids.filter((id) => id !== permissionId)
        : [...prev.permission_ids, permissionId],
    }));
  };

  const handleModuleToggle = (modulePermissions: Permission[]) => {
    const moduleIds = modulePermissions.map((p) => p.id);
    const allSelected = moduleIds.every((id) => formData.permission_ids.includes(id));

    if (allSelected) {
      setFormData((prev) => ({
        ...prev,
        permission_ids: prev.permission_ids.filter((id) => !moduleIds.includes(id)),
      }));
    } else {
      setFormData((prev) => ({
        ...prev,
        permission_ids: [...new Set([...prev.permission_ids, ...moduleIds])],
      }));
    }
  };

  const handleRolePermissionToggle = (permissionId: number) => {
    if (!selectedRole) return;

    const currentPermissionIds = selectedRole.permissions?.map((p) => p.id) || [];
    const newPermissionIds = currentPermissionIds.includes(permissionId)
      ? currentPermissionIds.filter((id) => id !== permissionId)
      : [...currentPermissionIds, permissionId];

    updatePermissionsMutation.mutate({
      id: selectedRole.id,
      permissionIds: newPermissionIds,
    });
  };

  const getLevelBadge = (level: number) => {
    if (level >= 90) return <Badge variant="danger">Super</Badge>;
    if (level >= 70) return <Badge variant="warning">Admin</Badge>;
    if (level >= 50) return <Badge variant="info">Staff</Badge>;
    return <Badge variant="gray">User</Badge>;
  };

  const isSystemRole = (roleName: string) => {
    return ['super_admin', 'admin'].includes(roleName);
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="page-title">Roles & Permissions</h1>
          <p className="page-description">Manage user roles and their permissions</p>
        </div>
        <Button
          variant="primary"
          leftIcon={<PlusIcon className="h-5 w-5" />}
          onClick={openCreateModal}
        >
          Add Role
        </Button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Roles List */}
        <div className="lg:col-span-1">
          <Card>
            <CardBody>
              <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <ShieldCheckIcon className="h-5 w-5 text-primary-600" />
                Roles
              </h3>
              {rolesLoading ? (
                <InlineLoader message="Loading roles..." />
              ) : (
                <div className="space-y-2">
                  {roles.map((role: Role) => (
                    <div
                      key={role.id}
                      className={`p-3 rounded-lg transition-colors ${
                        selectedRole?.id === role.id
                          ? 'bg-primary-50 border border-primary-200'
                          : 'bg-gray-50 hover:bg-gray-100 border border-transparent'
                      }`}
                    >
                      <div
                        className="cursor-pointer"
                        onClick={() => setSelectedRole(role)}
                      >
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex-1 min-w-0">
                            <p className="font-medium text-gray-900 capitalize truncate">
                              {role.name.replace('_', ' ')}
                            </p>
                            <p className="text-sm text-gray-500 line-clamp-2">
                              {role.description || 'No description'}
                            </p>
                          </div>
                          <div className="flex-shrink-0">
                            {getLevelBadge(role.level)}
                          </div>
                        </div>
                        <div className="mt-2 flex items-center gap-4 text-xs text-gray-500">
                          <span className="flex items-center gap-1">
                            <UsersIcon className="h-3 w-3" />
                            {role.users_count || 0} users
                          </span>
                          <span className="flex items-center gap-1">
                            <KeyIcon className="h-3 w-3" />
                            {role.permissions?.length || 0} permissions
                          </span>
                        </div>
                      </div>
                      {/* Action buttons */}
                      <div className="mt-2 pt-2 border-t border-gray-200 flex gap-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => openEditModal(role)}
                          leftIcon={<PencilIcon className="h-4 w-4" />}
                        >
                          Edit
                        </Button>
                        {!isSystemRole(role.name) && (
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-red-600 hover:text-red-700 hover:bg-red-50"
                            onClick={() => {
                              setEditingRole(role);
                              setIsDeleteOpen(true);
                            }}
                            leftIcon={<TrashIcon className="h-4 w-4" />}
                          >
                            Delete
                          </Button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardBody>
          </Card>
        </div>

        {/* Permission Matrix */}
        <div className="lg:col-span-2">
          <Card>
            <CardBody>
              <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
                <KeyIcon className="h-5 w-5 text-primary-600" />
                Permissions
                {selectedRole && (
                  <Badge variant="primary" className="ml-2">
                    {selectedRole.name.replace('_', ' ')}
                  </Badge>
                )}
                {updatePermissionsMutation.isPending && (
                  <span className="text-sm text-gray-500 ml-2">Saving...</span>
                )}
              </h3>

              {!selectedRole ? (
                <div className="text-center py-12 text-gray-500">
                  <ShieldCheckIcon className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                  <p>Select a role to view and edit its permissions</p>
                </div>
              ) : (
                <div className="space-y-6">
                  {Object.entries(groupedPermissions).map(([module, perms]) => {
                    const rolePermissionIds = selectedRole.permissions?.map((p) => p.id) || [];
                    const moduleIds = (perms as Permission[]).map((p) => p.id);
                    const allSelected = moduleIds.every((id) => rolePermissionIds.includes(id));
                    const someSelected = moduleIds.some((id) => rolePermissionIds.includes(id));

                    return (
                      <div key={module}>
                        <div className="flex items-center gap-2 mb-2">
                          <input
                            type="checkbox"
                            checked={allSelected}
                            ref={(el) => {
                              if (el) el.indeterminate = someSelected && !allSelected;
                            }}
                            onChange={() => {
                              const newIds = allSelected
                                ? rolePermissionIds.filter((id) => !moduleIds.includes(id))
                                : [...new Set([...rolePermissionIds, ...moduleIds])];
                              updatePermissionsMutation.mutate({
                                id: selectedRole.id,
                                permissionIds: newIds,
                              });
                            }}
                            className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                          />
                          <h4 className="text-sm font-semibold text-gray-700 uppercase tracking-wider">
                            {module}
                          </h4>
                        </div>
                        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-2">
                          {(perms as Permission[]).map((perm) => {
                            const action = perm.name.split('.')[1];
                            const isGranted = rolePermissionIds.includes(perm.id);

                            return (
                              <label
                                key={perm.id}
                                className={`flex items-center gap-2 px-3 py-2 rounded text-sm cursor-pointer transition-colors ${
                                  isGranted
                                    ? 'bg-green-50 text-green-700 border border-green-200'
                                    : 'bg-gray-50 text-gray-500 border border-gray-200 hover:bg-gray-100'
                                }`}
                              >
                                <input
                                  type="checkbox"
                                  checked={isGranted}
                                  onChange={() => handleRolePermissionToggle(perm.id)}
                                  className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                                />
                                {action}
                              </label>
                            );
                          })}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </CardBody>
          </Card>
        </div>
      </div>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-primary-100 rounded-lg">
              <ShieldCheckIcon className="h-6 w-6 text-primary-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{roles.length}</p>
              <p className="text-sm text-gray-500">Total Roles</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <KeyIcon className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{permissions.length}</p>
              <p className="text-sm text-gray-500">Total Permissions</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-amber-100 rounded-lg">
              <UsersIcon className="h-6 w-6 text-amber-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {roles.reduce((sum: number, r: Role) => sum + (r.users_count || 0), 0)}
              </p>
              <p className="text-sm text-gray-500">Users with Roles</p>
            </div>
          </CardBody>
        </Card>
      </div>

      {/* Create/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={closeModal}
        title={editingRole ? 'Edit Role' : 'Create Role'}
        size="lg"
      >
        <form onSubmit={handleSubmit}>
          <div className="space-y-4">
            <Input
              label="Role Name"
              name="name"
              value={formData.name}
              onChange={(e) => setFormData((prev) => ({ ...prev, name: e.target.value }))}
              error={formErrors.name}
              required
              disabled={editingRole && isSystemRole(editingRole.name)}
            />
            <Input
              label="Description"
              name="description"
              value={formData.description || ''}
              onChange={(e) => setFormData((prev) => ({ ...prev, description: e.target.value }))}
            />
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Level (1-100)
              </label>
              <input
                type="range"
                min="1"
                max="100"
                value={formData.level}
                onChange={(e) =>
                  setFormData((prev) => ({ ...prev, level: parseInt(e.target.value) }))
                }
                className="w-full"
              />
              <div className="flex justify-between text-xs text-gray-500 mt-1">
                <span>User</span>
                <span>Level: {formData.level}</span>
                <span>Super</span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Permissions
              </label>
              <div className="max-h-64 overflow-y-auto border border-gray-200 rounded-lg p-3 space-y-4">
                {Object.entries(groupedPermissions).map(([module, perms]) => {
                  const moduleIds = (perms as Permission[]).map((p) => p.id);
                  const allSelected = moduleIds.every((id) =>
                    formData.permission_ids.includes(id)
                  );

                  return (
                    <div key={module}>
                      <label className="flex items-center gap-2 mb-2 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={allSelected}
                          onChange={() => handleModuleToggle(perms as Permission[])}
                          className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                        />
                        <span className="text-sm font-semibold text-gray-700 uppercase">
                          {module}
                        </span>
                      </label>
                      <div className="ml-6 flex flex-wrap gap-2">
                        {(perms as Permission[]).map((perm) => {
                          const action = perm.name.split('.')[1];
                          return (
                            <label
                              key={perm.id}
                              className="flex items-center gap-1 text-sm cursor-pointer"
                            >
                              <input
                                type="checkbox"
                                checked={formData.permission_ids.includes(perm.id)}
                                onChange={() => handlePermissionToggle(perm.id)}
                                className="w-3 h-3 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                              />
                              {action}
                            </label>
                          );
                        })}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="flex justify-end gap-3 mt-6">
            <Button type="button" variant="secondary" onClick={closeModal}>
              Cancel
            </Button>
            <Button type="submit" variant="primary" disabled={isSubmitting}>
              {isSubmitting ? 'Saving...' : editingRole ? 'Update Role' : 'Create Role'}
            </Button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation */}
      <ConfirmDialog
        isOpen={isDeleteOpen}
        onClose={() => setIsDeleteOpen(false)}
        onConfirm={() => editingRole && deleteMutation.mutate(editingRole.id)}
        title="Delete Role"
        message={`Are you sure you want to delete the role "${editingRole?.name}"? This action cannot be undone.`}
        confirmLabel="Delete"
        variant="danger"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
};

export default RolesListPage;
