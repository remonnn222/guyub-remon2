import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import {
  Squares2X2Icon,
  FolderIcon,
  TagIcon,
  ChevronRightIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  CardBody,
  Badge,
  Button,
  Pagination,
  InlineLoader,
  Input,
  Spinner,
} from '@/components/ui';
import { masterTypesApi, masterValuesApi } from '@/api/master';
import { usePagination } from '@/hooks';
import { MasterType, MasterValue, MasterTypeFormData, MasterValueFormData } from '@/types';
import { toast } from '@/stores/uiStore';

// Type Form Modal Component
interface TypeFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  type?: MasterType | null;
  types: MasterType[];
  onSubmit: (data: MasterTypeFormData) => void;
  isSubmitting: boolean;
}

const TypeFormModal: React.FC<TypeFormModalProps> = ({
  isOpen,
  onClose,
  type,
  types,
  onSubmit,
  isSubmitting,
}) => {
  const [formData, setFormData] = useState<MasterTypeFormData>({
    code: '',
    name: '',
    description: '',
    is_active: true,
    sort_order: 0,
    parent_id: null,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (type) {
      setFormData({
        code: type.code,
        name: type.name,
        description: type.description || '',
        is_active: type.is_active,
        sort_order: type.sort_order,
        parent_id: type.parent_id || null,
      });
    } else {
      setFormData({
        code: '',
        name: '',
        description: '',
        is_active: true,
        sort_order: 0,
        parent_id: null,
      });
    }
    setErrors({});
  }, [type, isOpen]);

  const validate = (): boolean => {
    const newErrors: Record<string, string> = {};
    if (!formData.code.trim()) {
      newErrors.code = 'Code is required';
    } else if (!/^[A-Z_]+$/.test(formData.code)) {
      newErrors.code = 'Code must be uppercase letters and underscores only';
    }
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onSubmit(formData);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/50" onClick={onClose} />
      <div className="relative bg-white rounded-xl shadow-xl max-w-md w-full mx-4 max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between p-4 border-b">
          <h3 className="text-lg font-semibold">
            {type ? 'Edit Type' : 'Create Type'}
          </h3>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 rounded">
            <XMarkIcon className="h-5 w-5" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Code *
            </label>
            <Input
              value={formData.code}
              onChange={(e) =>
                setFormData({ ...formData, code: e.target.value.toUpperCase() })
              }
              placeholder="e.g., PROVINCE"
              error={errors.code}
              disabled={!!type}
            />
            <p className="text-xs text-gray-500 mt-1">Uppercase letters and underscores only</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Name *
            </label>
            <Input
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g., Province"
              error={errors.name}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={formData.description || ''}
              onChange={(e) =>
                setFormData({ ...formData, description: e.target.value })
              }
              placeholder="Optional description"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              rows={2}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Parent Type
            </label>
            <select
              value={formData.parent_id || ''}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  parent_id: e.target.value ? Number(e.target.value) : null,
                })
              }
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="">No Parent</option>
              {types
                .filter((t) => t.id !== type?.id)
                .map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.name}
                  </option>
                ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Sort Order
            </label>
            <Input
              type="number"
              value={formData.sort_order?.toString() || '0'}
              onChange={(e) =>
                setFormData({ ...formData, sort_order: Number(e.target.value) })
              }
              min={0}
            />
          </div>
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="type-is-active"
              checked={formData.is_active}
              onChange={(e) =>
                setFormData({ ...formData, is_active: e.target.checked })
              }
              className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            />
            <label htmlFor="type-is-active" className="text-sm text-gray-700">
              Active
            </label>
          </div>
          <div className="flex gap-3 pt-4">
            <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
              Cancel
            </Button>
            <Button type="submit" variant="primary" className="flex-1" disabled={isSubmitting}>
              {isSubmitting && <Spinner size="sm" className="mr-2" />}
              {type ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Value Form Modal Component
interface ValueFormModalProps {
  isOpen: boolean;
  onClose: () => void;
  value?: MasterValue | null;
  typeId: number;
  typeName: string;
  values: MasterValue[];
  onSubmit: (data: MasterValueFormData) => void;
  isSubmitting: boolean;
}

const ValueFormModal: React.FC<ValueFormModalProps> = ({
  isOpen,
  onClose,
  value,
  typeId,
  typeName,
  values,
  onSubmit,
  isSubmitting,
}) => {
  const [formData, setFormData] = useState<MasterValueFormData>({
    type_id: typeId,
    code: '',
    name: '',
    description: '',
    is_active: true,
    sort_order: 0,
    parent_value_id: null,
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (value) {
      setFormData({
        type_id: value.type_id,
        code: value.code,
        name: value.name,
        description: value.description || '',
        is_active: value.is_active,
        sort_order: value.sort_order,
        parent_value_id: value.parent_value_id || null,
      });
    } else {
      setFormData({
        type_id: typeId,
        code: '',
        name: '',
        description: '',
        is_active: true,
        sort_order: 0,
        parent_value_id: null,
      });
    }
    setErrors({});
  }, [value, typeId, isOpen]);

  const validate = (): boolean => {
    const newErrors: Record<string, string> = {};
    if (!formData.code.trim()) {
      newErrors.code = 'Code is required';
    }
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validate()) {
      onSubmit(formData);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/50" onClick={onClose} />
      <div className="relative bg-white rounded-xl shadow-xl max-w-md w-full mx-4 max-h-[90vh] overflow-y-auto">
        <div className="flex items-center justify-between p-4 border-b">
          <div>
            <h3 className="text-lg font-semibold">
              {value ? 'Edit Value' : 'Create Value'}
            </h3>
            <p className="text-sm text-gray-500">Type: {typeName}</p>
          </div>
          <button onClick={onClose} className="p-1 hover:bg-gray-100 rounded">
            <XMarkIcon className="h-5 w-5" />
          </button>
        </div>
        <form onSubmit={handleSubmit} className="p-4 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Code *
            </label>
            <Input
              value={formData.code}
              onChange={(e) => setFormData({ ...formData, code: e.target.value })}
              placeholder="e.g., JKT"
              error={errors.code}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Name *
            </label>
            <Input
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g., Jakarta"
              error={errors.name}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={formData.description || ''}
              onChange={(e) =>
                setFormData({ ...formData, description: e.target.value })
              }
              placeholder="Optional description"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              rows={2}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Parent Value
            </label>
            <select
              value={formData.parent_value_id || ''}
              onChange={(e) =>
                setFormData({
                  ...formData,
                  parent_value_id: e.target.value ? Number(e.target.value) : null,
                })
              }
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
              <option value="">No Parent</option>
              {values
                .filter((v) => v.id !== value?.id)
                .map((v) => (
                  <option key={v.id} value={v.id}>
                    {v.name}
                  </option>
                ))}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Sort Order
            </label>
            <Input
              type="number"
              value={formData.sort_order?.toString() || '0'}
              onChange={(e) =>
                setFormData({ ...formData, sort_order: Number(e.target.value) })
              }
              min={0}
            />
          </div>
          <div className="flex items-center gap-2">
            <input
              type="checkbox"
              id="value-is-active"
              checked={formData.is_active}
              onChange={(e) =>
                setFormData({ ...formData, is_active: e.target.checked })
              }
              className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            />
            <label htmlFor="value-is-active" className="text-sm text-gray-700">
              Active
            </label>
          </div>
          <div className="flex gap-3 pt-4">
            <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
              Cancel
            </Button>
            <Button type="submit" variant="primary" className="flex-1" disabled={isSubmitting}>
              {isSubmitting && <Spinner size="sm" className="mr-2" />}
              {value ? 'Update' : 'Create'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};

// Delete Confirmation Dialog
interface DeleteDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirm: () => void;
  title: string;
  message: string;
  isDeleting: boolean;
}

const DeleteDialog: React.FC<DeleteDialogProps> = ({
  isOpen,
  onClose,
  onConfirm,
  title,
  message,
  isDeleting,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/50" onClick={onClose} />
      <div className="relative bg-white rounded-xl shadow-xl max-w-sm w-full mx-4">
        <div className="p-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="p-2 bg-red-100 rounded-full">
              <TrashIcon className="h-6 w-6 text-red-600" />
            </div>
            <h3 className="text-lg font-semibold">{title}</h3>
          </div>
          <p className="text-gray-600 mb-6">{message}</p>
          <div className="flex gap-3">
            <Button type="button" variant="secondary" onClick={onClose} className="flex-1">
              Cancel
            </Button>
            <Button
              type="button"
              variant="danger"
              onClick={onConfirm}
              className="flex-1"
              disabled={isDeleting}
            >
              {isDeleting && <Spinner size="sm" className="mr-2" />}
              Delete
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
};

const MasterDataPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [selectedType, setSelectedType] = useState<MasterType | null>(null);
  const pagination = usePagination({ initialSortBy: 'sort_order', initialSortOrder: 'asc' });

  // Type modal state
  const [isTypeModalOpen, setIsTypeModalOpen] = useState(false);
  const [editingType, setEditingType] = useState<MasterType | null>(null);
  const [deleteTypeDialog, setDeleteTypeDialog] = useState<MasterType | null>(null);

  // Value modal state
  const [isValueModalOpen, setIsValueModalOpen] = useState(false);
  const [editingValue, setEditingValue] = useState<MasterValue | null>(null);
  const [deleteValueDialog, setDeleteValueDialog] = useState<MasterValue | null>(null);

  // Fetch master types
  const { data: typesData, isLoading: typesLoading } = useQuery({
    queryKey: ['master-types'],
    queryFn: () => masterTypesApi.getAll({ per_page: 100, sort_by: 'sort_order', sort_order: 'asc' }),
  });

  // Fetch values for selected type
  const { data: valuesData, isLoading: valuesLoading } = useQuery({
    queryKey: ['master-values', selectedType?.id, pagination.params],
    queryFn: () => masterTypesApi.getValues(selectedType!.id, pagination.params),
    enabled: !!selectedType,
    placeholderData: keepPreviousData,
  });

  const types = typesData?.data ?? [];
  const values = valuesData?.data ?? [];
  const valuesMeta = valuesData?.meta;

  // Helper to extract error message from API response
  // Note: Our axios interceptor transforms errors into ApiErrorResponse with message directly
  const getErrorMessage = (error: unknown): string => {
    if (error && typeof error === 'object') {
      // Handle transformed error from axios interceptor (ApiErrorResponse)
      if ('message' in error) {
        const err = error as { message?: string };
        if (err.message) return err.message;
      }
      // Handle raw axios error (fallback)
      if ('response' in error) {
        const axiosError = error as { response?: { data?: { message?: string; error?: string } } };
        const data = axiosError.response?.data;
        if (data?.message) return data.message;
        if (data?.error) return data.error;
      }
    }
    return 'An error occurred';
  };

  // Type mutations
  const createTypeMutation = useMutation({
    mutationFn: (data: MasterTypeFormData) => masterTypesApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['master-types'] });
      setIsTypeModalOpen(false);
      setEditingType(null);
      toast.success('Type Created', 'Master type has been created successfully');
    },
    onError: (error) => {
      toast.error('Failed to Create Type', getErrorMessage(error));
    },
  });

  const updateTypeMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<MasterTypeFormData> }) =>
      masterTypesApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['master-types'] });
      setIsTypeModalOpen(false);
      setEditingType(null);
      toast.success('Type Updated', 'Master type has been updated successfully');
    },
    onError: (error) => {
      toast.error('Failed to Update Type', getErrorMessage(error));
    },
  });

  const deleteTypeMutation = useMutation({
    mutationFn: (id: number) => masterTypesApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['master-types'] });
      if (selectedType?.id === deleteTypeDialog?.id) {
        setSelectedType(null);
      }
      setDeleteTypeDialog(null);
      toast.success('Type Deleted', 'Master type has been deleted successfully');
    },
    onError: (error) => {
      toast.error('Failed to Delete Type', getErrorMessage(error));
    },
  });

  // Value mutations
  const createValueMutation = useMutation({
    mutationFn: (data: MasterValueFormData) => masterValuesApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['master-values', selectedType?.id] });
      setIsValueModalOpen(false);
      setEditingValue(null);
      toast.success('Value Created', 'Master value has been created successfully');
    },
    onError: (error) => {
      toast.error('Failed to Create Value', getErrorMessage(error));
    },
  });

  const updateValueMutation = useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<MasterValueFormData> }) =>
      masterValuesApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['master-values', selectedType?.id] });
      setIsValueModalOpen(false);
      setEditingValue(null);
      toast.success('Value Updated', 'Master value has been updated successfully');
    },
    onError: (error) => {
      toast.error('Failed to Update Value', getErrorMessage(error));
    },
  });

  const deleteValueMutation = useMutation({
    mutationFn: (id: number) => masterValuesApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['master-values', selectedType?.id] });
      setDeleteValueDialog(null);
      toast.success('Value Deleted', 'Master value has been deleted successfully');
    },
    onError: (error) => {
      toast.error('Failed to Delete Value', getErrorMessage(error));
    },
  });

  // Update pagination meta when data changes
  useEffect(() => {
    if (valuesMeta) {
      pagination.updateMeta(valuesMeta);
    }
  }, [valuesMeta]);

  // Select first type by default
  useEffect(() => {
    if (types.length > 0 && !selectedType) {
      setSelectedType(types[0]);
    }
  }, [types, selectedType]);

  const handleTypeSubmit = (data: MasterTypeFormData) => {
    if (editingType) {
      updateTypeMutation.mutate({ id: editingType.id, data });
    } else {
      createTypeMutation.mutate(data);
    }
  };

  const handleValueSubmit = (data: MasterValueFormData) => {
    if (editingValue) {
      updateValueMutation.mutate({ id: editingValue.id, data });
    } else {
      createValueMutation.mutate(data);
    }
  };

  const openEditType = (type: MasterType) => {
    setEditingType(type);
    setIsTypeModalOpen(true);
  };

  const openCreateType = () => {
    setEditingType(null);
    setIsTypeModalOpen(true);
  };

  const openEditValue = (value: MasterValue) => {
    setEditingValue(value);
    setIsValueModalOpen(true);
  };

  const openCreateValue = () => {
    setEditingValue(null);
    setIsValueModalOpen(true);
  };

  const getStatusBadge = (isActive: boolean) => {
    return isActive ? (
      <Badge variant="success">Active</Badge>
    ) : (
      <Badge variant="gray">Inactive</Badge>
    );
  };

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="page-title">Master Data</h1>
          <p className="page-description">Manage master data types and values</p>
        </div>
        <Button
          variant="primary"
          leftIcon={<PlusIcon className="h-5 w-5" />}
          onClick={openCreateType}
        >
          Add Type
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-primary-100 rounded-lg">
              <Squares2X2Icon className="h-6 w-6 text-primary-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{types.length}</p>
              <p className="text-sm text-gray-500">Total Types</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-blue-100 rounded-lg">
              <TagIcon className="h-6 w-6 text-blue-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">{valuesMeta?.total || 0}</p>
              <p className="text-sm text-gray-500">Values in Selected Type</p>
            </div>
          </CardBody>
        </Card>
        <Card>
          <CardBody className="flex items-center gap-4">
            <div className="p-3 bg-green-100 rounded-lg">
              <FolderIcon className="h-6 w-6 text-green-600" />
            </div>
            <div>
              <p className="text-2xl font-bold text-gray-900">
                {types.filter(t => t.is_active).length}
              </p>
              <p className="text-sm text-gray-500">Active Types</p>
            </div>
          </CardBody>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Types List */}
        <div className="lg:col-span-1">
          <Card>
            <CardBody>
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold flex items-center gap-2">
                  <FolderIcon className="h-5 w-5 text-primary-600" />
                  Types
                </h3>
              </div>
              {typesLoading ? (
                <InlineLoader message="Loading types..." />
              ) : types.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <FolderIcon className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                  <p>No master types found</p>
                  <Button
                    variant="primary"
                    size="sm"
                    className="mt-3"
                    leftIcon={<PlusIcon className="h-4 w-4" />}
                    onClick={openCreateType}
                  >
                    Add First Type
                  </Button>
                </div>
              ) : (
                <div className="space-y-2">
                  {types.map((type: MasterType) => (
                    <div
                      key={type.id}
                      className={`p-3 rounded-lg cursor-pointer transition-colors ${
                        selectedType?.id === type.id
                          ? 'bg-primary-50 border border-primary-200'
                          : 'bg-gray-50 hover:bg-gray-100 border border-transparent'
                      }`}
                    >
                      <div
                        className="flex items-center justify-between"
                        onClick={() => setSelectedType(type)}
                      >
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2">
                            <p className="font-medium text-gray-900 truncate">
                              {type.name}
                            </p>
                            {getStatusBadge(type.is_active)}
                          </div>
                          <p className="text-xs text-gray-500 font-mono mt-1">
                            {type.code}
                          </p>
                          {type.description && (
                            <p className="text-sm text-gray-500 truncate mt-1">
                              {type.description}
                            </p>
                          )}
                        </div>
                        <ChevronRightIcon className="h-5 w-5 text-gray-400 flex-shrink-0" />
                      </div>
                      <div className="flex gap-1 mt-2 pt-2 border-t border-gray-200">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            openEditType(type);
                          }}
                          className="p-1.5 text-gray-500 hover:text-primary-600 hover:bg-primary-50 rounded"
                          title="Edit Type"
                        >
                          <PencilIcon className="h-4 w-4" />
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setDeleteTypeDialog(type);
                          }}
                          className="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded"
                          title="Delete Type"
                        >
                          <TrashIcon className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardBody>
          </Card>
        </div>

        {/* Values List */}
        <div className="lg:col-span-2">
          <Card>
            <CardBody>
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold flex items-center gap-2">
                  <TagIcon className="h-5 w-5 text-primary-600" />
                  Values
                  {selectedType && (
                    <Badge variant="primary" className="ml-2">
                      {selectedType.name}
                    </Badge>
                  )}
                </h3>
                {selectedType && (
                  <Button
                    variant="primary"
                    size="sm"
                    leftIcon={<PlusIcon className="h-4 w-4" />}
                    onClick={openCreateValue}
                  >
                    Add Value
                  </Button>
                )}
              </div>

              {!selectedType ? (
                <div className="text-center py-12 text-gray-500">
                  <TagIcon className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                  <p>Select a type to view its values</p>
                </div>
              ) : valuesLoading ? (
                <InlineLoader message="Loading values..." />
              ) : values.length === 0 ? (
                <div className="text-center py-12 text-gray-500">
                  <TagIcon className="h-12 w-12 mx-auto mb-3 text-gray-300" />
                  <p>No values found for this type</p>
                  <Button
                    variant="primary"
                    size="sm"
                    className="mt-3"
                    leftIcon={<PlusIcon className="h-4 w-4" />}
                    onClick={openCreateValue}
                  >
                    Add First Value
                  </Button>
                </div>
              ) : (
                <>
                  <div className="overflow-x-auto">
                    <table className="w-full">
                      <thead>
                        <tr className="border-b border-gray-200">
                          <th className="text-left py-3 px-4 text-sm font-semibold text-gray-700">
                            Code
                          </th>
                          <th className="text-left py-3 px-4 text-sm font-semibold text-gray-700">
                            Name
                          </th>
                          <th className="text-left py-3 px-4 text-sm font-semibold text-gray-700">
                            Description
                          </th>
                          <th className="text-left py-3 px-4 text-sm font-semibold text-gray-700">
                            Order
                          </th>
                          <th className="text-left py-3 px-4 text-sm font-semibold text-gray-700">
                            Status
                          </th>
                          <th className="text-right py-3 px-4 text-sm font-semibold text-gray-700">
                            Actions
                          </th>
                        </tr>
                      </thead>
                      <tbody>
                        {values.map((value: MasterValue) => (
                          <tr
                            key={value.id}
                            className="border-b border-gray-100 hover:bg-gray-50"
                          >
                            <td className="py-3 px-4">
                              <span className="font-mono text-sm text-gray-600">
                                {value.code}
                              </span>
                            </td>
                            <td className="py-3 px-4">
                              <span className="font-medium text-gray-900">
                                {value.name}
                              </span>
                            </td>
                            <td className="py-3 px-4">
                              <span className="text-sm text-gray-500 truncate block max-w-xs">
                                {value.description || '-'}
                              </span>
                            </td>
                            <td className="py-3 px-4">
                              <span className="text-sm text-gray-500">
                                {value.sort_order}
                              </span>
                            </td>
                            <td className="py-3 px-4">
                              {getStatusBadge(value.is_active)}
                            </td>
                            <td className="py-3 px-4 text-right">
                              <div className="flex justify-end gap-1">
                                <button
                                  onClick={() => openEditValue(value)}
                                  className="p-1.5 text-gray-500 hover:text-primary-600 hover:bg-primary-50 rounded"
                                  title="Edit Value"
                                >
                                  <PencilIcon className="h-4 w-4" />
                                </button>
                                <button
                                  onClick={() => setDeleteValueDialog(value)}
                                  className="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded"
                                  title="Delete Value"
                                >
                                  <TrashIcon className="h-4 w-4" />
                                </button>
                              </div>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>

                  {/* Pagination */}
                  {pagination.paginationInfo && (
                    <div className="mt-4">
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
                    </div>
                  )}
                </>
              )}
            </CardBody>
          </Card>
        </div>
      </div>

      {/* Type Form Modal */}
      <TypeFormModal
        isOpen={isTypeModalOpen}
        onClose={() => {
          setIsTypeModalOpen(false);
          setEditingType(null);
        }}
        type={editingType}
        types={types}
        onSubmit={handleTypeSubmit}
        isSubmitting={createTypeMutation.isPending || updateTypeMutation.isPending}
      />

      {/* Value Form Modal */}
      {selectedType && (
        <ValueFormModal
          isOpen={isValueModalOpen}
          onClose={() => {
            setIsValueModalOpen(false);
            setEditingValue(null);
          }}
          value={editingValue}
          typeId={selectedType.id}
          typeName={selectedType.name}
          values={values}
          onSubmit={handleValueSubmit}
          isSubmitting={createValueMutation.isPending || updateValueMutation.isPending}
        />
      )}

      {/* Delete Type Confirmation */}
      <DeleteDialog
        isOpen={!!deleteTypeDialog}
        onClose={() => setDeleteTypeDialog(null)}
        onConfirm={() => deleteTypeMutation.mutate(deleteTypeDialog!.id)}
        title="Delete Type"
        message={`Are you sure you want to delete "${deleteTypeDialog?.name}"? This will also delete all values associated with this type.`}
        isDeleting={deleteTypeMutation.isPending}
      />

      {/* Delete Value Confirmation */}
      <DeleteDialog
        isOpen={!!deleteValueDialog}
        onClose={() => setDeleteValueDialog(null)}
        onConfirm={() => deleteValueMutation.mutate(deleteValueDialog!.id)}
        title="Delete Value"
        message={`Are you sure you want to delete "${deleteValueDialog?.name}"?`}
        isDeleting={deleteValueMutation.isPending}
      />
    </div>
  );
};

export default MasterDataPage;
