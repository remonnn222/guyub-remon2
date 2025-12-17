import { useState, useEffect } from 'react';
import { useMutation, useQueryClient, useQuery } from '@tanstack/react-query';
import {
  UserIcon,
  EnvelopeIcon,
  PhoneIcon,
  KeyIcon,
  ShieldCheckIcon,
} from '@heroicons/react/24/outline';
import {
  Card,
  CardBody,
  Button,
  Input,
  Spinner,
  AvatarUpload,
  Badge,
} from '@/components/ui';
import { useAuthStore } from '@/stores/authStore';
import { toast } from '@/stores/uiStore';
import { usersApi } from '@/api/users';
import { assetsApi } from '@/api/assets';
import { Asset } from '@/types';

interface ProfileFormData {
  name: string;
  email: string;
  phone: string;
}

interface PasswordFormData {
  current_password: string;
  password: string;
  password_confirmation: string;
}

const ProfilePage: React.FC = () => {
  const queryClient = useQueryClient();
  const { user, fetchUser } = useAuthStore();
  const [profileData, setProfileData] = useState<ProfileFormData>({
    name: '',
    email: '',
    phone: '',
  });
  const [passwordData, setPasswordData] = useState<PasswordFormData>({
    current_password: '',
    password: '',
    password_confirmation: '',
  });
  const [profileErrors, setProfileErrors] = useState<Record<string, string>>({});
  const [passwordErrors, setPasswordErrors] = useState<Record<string, string>>({});
  const [avatarAsset, setAvatarAsset] = useState<Asset | null>(null);
  const [avatarUrl, setAvatarUrl] = useState<string | undefined>(undefined);

  // Fetch current user data
  const { data: userData, isLoading } = useQuery({
    queryKey: ['profile', user?.id],
    queryFn: () => usersApi.getById(user!.id),
    enabled: !!user?.id,
  });

  // Fetch user avatar
  const { data: avatarData } = useQuery({
    queryKey: ['user-avatar', user?.id],
    queryFn: () => assetsApi.getUserAvatar(user!.id),
    enabled: !!user?.id,
  });

  useEffect(() => {
    if (avatarData?.data?.url) {
      setAvatarUrl(avatarData.data.url);
    }
  }, [avatarData]);

  useEffect(() => {
    if (userData?.data) {
      setProfileData({
        name: userData.data.name || '',
        email: userData.data.email || '',
        phone: userData.data.phone || '',
      });
    }
  }, [userData]);

  // Update profile mutation
  const updateProfileMutation = useMutation({
    mutationFn: (data: ProfileFormData) => usersApi.update(user!.id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['profile', user?.id] });
      fetchUser();
      toast.success('Profile Updated', 'Your profile has been updated successfully');
    },
    onError: (error: any) => {
      if (error.response?.data?.errors) {
        setProfileErrors(error.response.data.errors);
      } else {
        toast.error('Update Failed', error.response?.data?.message || 'Failed to update profile');
      }
    },
  });

  // Change password mutation
  const changePasswordMutation = useMutation({
    mutationFn: (data: PasswordFormData) => usersApi.changePassword(user!.id, data),
    onSuccess: () => {
      setPasswordData({
        current_password: '',
        password: '',
        password_confirmation: '',
      });
      toast.success('Password Changed', 'Your password has been changed successfully');
    },
    onError: (error: any) => {
      if (error.response?.data?.errors) {
        setPasswordErrors(error.response.data.errors);
      } else {
        toast.error('Password Change Failed', error.response?.data?.message || 'Failed to change password');
      }
    },
  });

  const handleProfileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setProfileData((prev) => ({ ...prev, [name]: value }));
    if (profileErrors[name]) {
      setProfileErrors((prev) => ({ ...prev, [name]: '' }));
    }
  };

  const handlePasswordChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setPasswordData((prev) => ({ ...prev, [name]: value }));
    if (passwordErrors[name]) {
      setPasswordErrors((prev) => ({ ...prev, [name]: '' }));
    }
  };

  const validateProfile = () => {
    const errors: Record<string, string> = {};
    if (!profileData.name.trim()) {
      errors.name = 'Name is required';
    }
    if (!profileData.email.trim()) {
      errors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(profileData.email)) {
      errors.email = 'Invalid email format';
    }
    setProfileErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const validatePassword = () => {
    const errors: Record<string, string> = {};
    if (!passwordData.current_password) {
      errors.current_password = 'Current password is required';
    }
    if (!passwordData.password) {
      errors.password = 'New password is required';
    } else if (passwordData.password.length < 8) {
      errors.password = 'Password must be at least 8 characters';
    }
    if (passwordData.password !== passwordData.password_confirmation) {
      errors.password_confirmation = 'Passwords do not match';
    }
    setPasswordErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleProfileSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateProfile()) {
      updateProfileMutation.mutate(profileData);
    }
  };

  const handlePasswordSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validatePassword()) {
      changePasswordMutation.mutate(passwordData);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Spinner size="lg" />
      </div>
    );
  }

  const currentUser = userData?.data;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div>
        <h1 className="page-title">Profile Settings</h1>
        <p className="page-description">Manage your account information and security settings</p>
      </div>

      {/* Profile Card */}
      <Card>
        <CardBody>
          <div className="flex items-start gap-6">
            {/* Avatar */}
            <div className="flex-shrink-0">
              <AvatarUpload
                userId={user?.id}
                currentAvatarUrl={avatarUrl}
                size="xl"
                onUploadSuccess={(asset) => {
                  setAvatarAsset(asset);
                  setAvatarUrl(asset.url);
                  queryClient.invalidateQueries({ queryKey: ['user-avatar', user?.id] });
                  toast.success('Photo Updated', 'Profile photo has been updated');
                }}
                onUploadError={(error) => {
                  toast.error('Upload Failed', error);
                }}
                onRemove={() => {
                  setAvatarAsset(null);
                  setAvatarUrl(undefined);
                }}
              />
            </div>

            {/* User Info Display */}
            <div className="flex-1">
              <h2 className="text-2xl font-bold text-gray-900">{currentUser?.name}</h2>
              <p className="text-gray-500">{currentUser?.email}</p>
              <div className="mt-2 flex flex-wrap gap-2">
                {currentUser?.roles?.map((role) => (
                  <Badge key={role.id} variant="primary">
                    {role.name}
                  </Badge>
                ))}
              </div>
              <div className="mt-4 flex items-center gap-4 text-sm text-gray-500">
                <span className="flex items-center gap-1">
                  <ShieldCheckIcon className="h-4 w-4" />
                  Member since {new Date(currentUser?.created_at || '').toLocaleDateString()}
                </span>
              </div>
            </div>
          </div>
        </CardBody>
      </Card>

      {/* Edit Profile Form */}
      <Card>
        <CardBody>
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <UserIcon className="h-5 w-5 text-primary-600" />
            Personal Information
          </h3>
          <form onSubmit={handleProfileSubmit}>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <Input
                label="Full Name"
                name="name"
                value={profileData.name}
                onChange={handleProfileChange}
                error={profileErrors.name}
                required
                leftIcon={<UserIcon className="h-4 w-4" />}
              />
              <Input
                label="Email Address"
                name="email"
                type="email"
                value={profileData.email}
                onChange={handleProfileChange}
                error={profileErrors.email}
                required
                leftIcon={<EnvelopeIcon className="h-4 w-4" />}
              />
              <Input
                label="Phone Number"
                name="phone"
                value={profileData.phone}
                onChange={handleProfileChange}
                error={profileErrors.phone}
                leftIcon={<PhoneIcon className="h-4 w-4" />}
              />
            </div>
            <div className="mt-4 flex justify-end">
              <Button
                type="submit"
                variant="primary"
                disabled={updateProfileMutation.isPending}
              >
                {updateProfileMutation.isPending && <Spinner size="sm" className="mr-2" />}
                Save Changes
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>

      {/* Change Password Form */}
      <Card>
        <CardBody>
          <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <KeyIcon className="h-5 w-5 text-primary-600" />
            Change Password
          </h3>
          <form onSubmit={handlePasswordSubmit}>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Input
                label="Current Password"
                name="current_password"
                type="password"
                value={passwordData.current_password}
                onChange={handlePasswordChange}
                error={passwordErrors.current_password}
                required
              />
              <Input
                label="New Password"
                name="password"
                type="password"
                value={passwordData.password}
                onChange={handlePasswordChange}
                error={passwordErrors.password}
                required
              />
              <Input
                label="Confirm New Password"
                name="password_confirmation"
                type="password"
                value={passwordData.password_confirmation}
                onChange={handlePasswordChange}
                error={passwordErrors.password_confirmation}
                required
              />
            </div>
            <div className="mt-4 flex justify-end">
              <Button
                type="submit"
                variant="primary"
                disabled={changePasswordMutation.isPending}
              >
                {changePasswordMutation.isPending && <Spinner size="sm" className="mr-2" />}
                Change Password
              </Button>
            </div>
          </form>
        </CardBody>
      </Card>
    </div>
  );
};

export default ProfilePage;
