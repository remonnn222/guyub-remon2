import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  ArrowLeftIcon,
  UserIcon,
  EnvelopeIcon,
  PhoneIcon,
  KeyIcon,
  ChevronDownIcon,
  ChevronUpIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  CardBody,
  Button,
  Input,
  Select,
  Spinner,
  AvatarUpload,
} from '@/components/ui';
import { usersApi } from '@/api/users';
import { rolesApi } from '@/api/roles';
import { assetsApi } from '@/api/assets';
import { UserStatus, UserType, UserFormData, Asset } from '@/types';

interface FormErrors {
  name?: string;
  email?: string;
  phone?: string;
  password?: string;
  password_confirmation?: string;
  status?: string;
  type?: string;
  role_ids?: string;
}

const UserFormPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const isEdit = Boolean(id);

  const [formData, setFormData] = useState<UserFormData>({
    name: '',
    email: '',
    phone: '',
    password: '',
    password_confirmation: '',
    status: UserStatus.ACTIVE,
    type: UserType.CUSTOMER,
    role_ids: [],
    two_factor_enabled: false,
  });

  const [errors, setErrors] = useState<FormErrors>({});
  const [avatarAsset, setAvatarAsset] = useState<Asset | null>(null);
  const [avatarUrl, setAvatarUrl] = useState<string | undefined>(undefined);
  const [showPassword, setShowPassword] = useState(!isEdit);

  // Fetch user data for edit mode
  const { data: userData, isLoading: userLoading } = useQuery({
    queryKey: ['user', id],
    queryFn: () => usersApi.getById(Number(id)),
    enabled: isEdit,
  });

  // Fetch user avatar for edit mode
  const { data: avatarData } = useQuery({
    queryKey: ['user-avatar', id],
    queryFn: () => assetsApi.getUserAvatar(Number(id)),
    enabled: isEdit,
  });

  // Set avatar URL when fetched
  useEffect(() => {
    if (avatarData?.data?.url) {
      setAvatarUrl(avatarData.data.url);
    }
  }, [avatarData]);

  // Fetch roles for dropdown
  const { data: rolesData } = useQuery({
    queryKey: ['roles-dropdown'],
    queryFn: () => rolesApi.getAllForDropdown(),
  });

  const roles = rolesData?.data ?? [];

  // Populate form data when editing
  useEffect(() => {
    if (userData?.data) {
      const user = userData.data;
      const statusValue = typeof user.status === 'object' && user.status !== null
        ? (user.status as { value: string }).value
        : user.status;
      const typeValue = typeof user.type === 'object' && user.type !== null
        ? (user.type as { value: string }).value
        : user.type;
      setFormData({
        name: user.name,
        email: user.email,
        phone: user.phone || '',
        password: '',
        password_confirmation: '',
        status: statusValue as UserStatus,
        type: typeValue as UserType,
        role_ids: user.roles?.map((r) => r.id) || [],
        two_factor_enabled: user.two_factor_enabled,
      });
    }
  }, [userData]);

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: UserFormData) => usersApi.create(data),
    onSuccess: async (response) => {
      if (avatarAsset && response.data?.id) {
        try {
          await assetsApi.linkToRef(avatarAsset.id, response.data.id.toString());
        } catch (err) {
          console.error('Failed to link avatar:', err);
        }
      }
      queryClient.invalidateQueries({ queryKey: ['users'] });
      navigate('/users');
    },
    onError: (error: any) => {
      if (error.response?.data?.errors) {
        setErrors(error.response.data.errors);
      }
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: (data: Partial<UserFormData>) => usersApi.update(Number(id), data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      queryClient.invalidateQueries({ queryKey: ['user', id] });
      navigate('/users');
    },
    onError: (error: any) => {
      if (error.response?.data?.errors) {
        setErrors(error.response.data.errors);
      }
    },
  });

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value, type } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? (e.target as HTMLInputElement).checked : value,
    }));
    if (errors[name as keyof FormErrors]) {
      setErrors((prev) => ({ ...prev, [name]: undefined }));
    }
  };

  const validateForm = (): boolean => {
    const newErrors: FormErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Invalid email format';
    }

    if (!isEdit && !formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password && formData.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    if (formData.password && formData.password !== formData.password_confirmation) {
      newErrors.password_confirmation = 'Passwords do not match';
    }

    if (formData.role_ids.length === 0) {
      newErrors.role_ids = 'At least one role is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    const submitData: Record<string, unknown> = {
      name: formData.name,
      email: formData.email,
      status: formData.status,
      type: formData.type,
      role_ids: formData.role_ids,
    };

    if (formData.phone && formData.phone.trim()) {
      submitData.phone = formData.phone.trim();
    }

    if (formData.password && formData.password.trim()) {
      submitData.password = formData.password;
    }

    if (isEdit) {
      updateMutation.mutate(submitData as Partial<UserFormData>);
    } else {
      createMutation.mutate(submitData as UserFormData);
    }
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  if (isEdit && userLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Spinner size="lg" />
      </div>
    );
  }

  const statusOptions = [
    { value: UserStatus.ACTIVE, label: 'Active' },
    { value: UserStatus.INACTIVE, label: 'Inactive' },
    { value: UserStatus.SUSPENDED, label: 'Suspended' },
  ];

  const typeOptions = [
    { value: UserType.INTERNAL, label: 'Internal' },
    { value: UserType.CUSTOMER, label: 'Customer' },
    { value: UserType.AGENT, label: 'Agent' },
  ];

  return (
    <div className="h-full flex flex-col">
      {/* Header with actions */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => navigate('/users')}
            leftIcon={<ArrowLeftIcon className="h-4 w-4" />}
          >
            Back
          </Button>
          <div className="border-l border-gray-300 pl-4">
            <h1 className="text-xl font-semibold text-gray-900">
              {isEdit ? 'Edit User' : 'Create User'}
            </h1>
          </div>
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="secondary"
            size="sm"
            onClick={() => navigate('/users')}
          >
            Cancel
          </Button>
          <Button
            type="submit"
            variant="primary"
            size="sm"
            disabled={isSubmitting}
            onClick={handleSubmit}
          >
            {isSubmitting && <Spinner size="sm" className="mr-2" />}
            {isEdit ? 'Update' : 'Create'}
          </Button>
        </div>
      </div>

      {/* Form */}
      <form onSubmit={handleSubmit} className="flex-1">
        <Card className="h-full">
          <CardBody className="p-6">
            <div className="flex gap-6">
              {/* Left: Avatar */}
              <div className="flex-shrink-0">
                <AvatarUpload
                  userId={isEdit ? Number(id) : undefined}
                  currentAvatarUrl={avatarUrl}
                  size="lg"
                  onUploadSuccess={(asset) => {
                    setAvatarAsset(asset);
                    setAvatarUrl(asset.url);
                    queryClient.invalidateQueries({ queryKey: ['user-avatar', id] });
                  }}
                  onUploadError={(error) => {
                    console.error('Avatar upload error:', error);
                  }}
                  onRemove={() => {
                    setAvatarAsset(null);
                    setAvatarUrl(undefined);
                  }}
                  disabled={isSubmitting}
                />
              </div>

              {/* Right: Form fields */}
              <div className="flex-1 grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-x-6 gap-y-4">
                {/* Row 1: Basic info */}
                <Input
                  label="Full Name"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  error={errors.name}
                  required
                  leftIcon={<UserIcon className="h-4 w-4" />}
                />
                <Input
                  label="Email Address"
                  name="email"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                  error={errors.email}
                  required
                  leftIcon={<EnvelopeIcon className="h-4 w-4" />}
                />
                <Input
                  label="Phone Number"
                  name="phone"
                  value={formData.phone || ''}
                  onChange={handleChange}
                  error={errors.phone}
                  leftIcon={<PhoneIcon className="h-4 w-4" />}
                />

                {/* Row 2: Status, Type, Roles */}
                <Select
                  label="Status"
                  name="status"
                  value={formData.status}
                  onChange={handleChange}
                  options={statusOptions}
                  error={errors.status}
                />
                <Select
                  label="User Type"
                  name="type"
                  value={formData.type}
                  onChange={handleChange}
                  options={typeOptions}
                  error={errors.type}
                />
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Roles <span className="text-red-500">*</span>
                  </label>
                  <div className="flex flex-wrap gap-2 p-2 border rounded-lg bg-gray-50 min-h-[42px]">
                    {roles.map((role) => (
                      <label
                        key={role.id}
                        className={`
                          inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium cursor-pointer transition-colors
                          ${formData.role_ids.includes(role.id)
                            ? 'bg-primary-100 text-primary-700 ring-1 ring-primary-300'
                            : 'bg-white text-gray-600 ring-1 ring-gray-200 hover:bg-gray-100'
                          }
                        `}
                      >
                        <input
                          type="checkbox"
                          checked={formData.role_ids.includes(role.id)}
                          onChange={(e) => {
                            if (e.target.checked) {
                              setFormData((prev) => ({
                                ...prev,
                                role_ids: [...prev.role_ids, role.id],
                              }));
                            } else {
                              setFormData((prev) => ({
                                ...prev,
                                role_ids: prev.role_ids.filter((rid) => rid !== role.id),
                              }));
                            }
                          }}
                          className="sr-only"
                        />
                        {role.name}
                      </label>
                    ))}
                  </div>
                  {errors.role_ids && (
                    <p className="mt-1 text-xs text-red-600">{errors.role_ids}</p>
                  )}
                </div>
              </div>
            </div>

            {/* Password Section - Collapsible for edit mode */}
            <div className="mt-6 pt-4 border-t">
              {isEdit ? (
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="flex items-center gap-2 text-sm font-medium text-gray-700 hover:text-gray-900"
                >
                  <KeyIcon className="h-4 w-4" />
                  Change Password
                  {showPassword ? (
                    <ChevronUpIcon className="h-4 w-4" />
                  ) : (
                    <ChevronDownIcon className="h-4 w-4" />
                  )}
                </button>
              ) : (
                <div className="flex items-center gap-2 text-sm font-medium text-gray-700 mb-3">
                  <KeyIcon className="h-4 w-4" />
                  Password
                </div>
              )}

              {showPassword && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-3">
                  <Input
                    label={isEdit ? "New Password" : "Password"}
                    name="password"
                    type="password"
                    value={formData.password || ''}
                    onChange={handleChange}
                    error={errors.password}
                    required={!isEdit}
                    placeholder={isEdit ? "Leave blank to keep current" : ""}
                  />
                  <Input
                    label="Confirm Password"
                    name="password_confirmation"
                    type="password"
                    value={formData.password_confirmation || ''}
                    onChange={handleChange}
                    error={errors.password_confirmation}
                    required={!isEdit}
                  />
                </div>
              )}
            </div>
          </CardBody>
        </Card>
      </form>
    </div>
  );
};

export default UserFormPage;
