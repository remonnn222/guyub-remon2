import { useState, useRef, useCallback, useEffect, useId } from 'react';
import { CameraIcon, UserIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { useMutation, useQuery } from '@tanstack/react-query';
import { assetsApi, UploadOptions } from '@/api/assets';
import { Asset } from '@/types';
import { Spinner } from './Spinner';

interface AvatarUploadProps {
  userId?: number;
  currentAvatarUrl?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  onUploadSuccess?: (asset: Asset) => void;
  onUploadError?: (error: string) => void;
  onRemove?: () => void;
  disabled?: boolean;
  className?: string;
}

const sizeClasses = {
  sm: 'h-16 w-16',
  md: 'h-24 w-24',
  lg: 'h-32 w-32',
  xl: 'h-40 w-40',
};

const iconSizeClasses = {
  sm: 'h-8 w-8',
  md: 'h-12 w-12',
  lg: 'h-16 w-16',
  xl: 'h-20 w-20',
};

const cameraSizeClasses = {
  sm: 'h-6 w-6',
  md: 'h-8 w-8',
  lg: 'h-10 w-10',
  xl: 'h-12 w-12',
};

export const AvatarUpload: React.FC<AvatarUploadProps> = ({
  userId,
  currentAvatarUrl,
  size = 'lg',
  onUploadSuccess,
  onUploadError,
  onRemove,
  disabled = false,
  className = '',
}) => {
  const [previewUrl, setPreviewUrl] = useState<string | null>(currentAvatarUrl || null);
  const [error, setError] = useState<string | null>(null);
  const [progress, setProgress] = useState(0);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const inputId = useId();

  // Fetch existing avatar if userId is provided
  const { data: avatarData } = useQuery({
    queryKey: ['user-avatar', userId],
    queryFn: () => assetsApi.getUserAvatar(userId!),
    enabled: !!userId && !currentAvatarUrl,
  });

  useEffect(() => {
    if (avatarData?.data?.url) {
      setPreviewUrl(avatarData.data.url);
    }
  }, [avatarData]);

  useEffect(() => {
    if (currentAvatarUrl) {
      setPreviewUrl(currentAvatarUrl);
    }
  }, [currentAvatarUrl]);

  const uploadMutation = useMutation({
    mutationFn: async (file: File) => {
      const options: UploadOptions = {
        kind: 'user_avatar',
        refId: userId?.toString(),
        onProgress: setProgress,
      };
      return assetsApi.upload(file, options);
    },
    onSuccess: (response) => {
      setProgress(0);
      setError(null);
      if (response.data) {
        setPreviewUrl(response.data.url);
        onUploadSuccess?.(response.data);
      }
    },
    onError: (err: Error) => {
      setProgress(0);
      const errorMessage = err.message || 'Upload failed';
      setError(errorMessage);
      onUploadError?.(errorMessage);
    },
  });

  const validateFile = useCallback((file: File): string | null => {
    // Check file size (max 2MB for avatars)
    const maxSizeBytes = 2 * 1024 * 1024;
    if (file.size > maxSizeBytes) {
      return 'Image must be less than 2MB';
    }

    // Check file type
    const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!allowedTypes.includes(file.type)) {
      return 'Only JPEG, PNG, GIF, and WebP images are allowed';
    }

    return null;
  }, []);

  const handleFile = useCallback(
    (file: File) => {
      const validationError = validateFile(file);
      if (validationError) {
        setError(validationError);
        onUploadError?.(validationError);
        return;
      }

      // Create preview
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewUrl(reader.result as string);
      };
      reader.readAsDataURL(file);

      setError(null);
      uploadMutation.mutate(file);
    },
    [validateFile, uploadMutation, onUploadError]
  );


  const handleFileChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const files = e.target.files;
      if (files && files.length > 0) {
        handleFile(files[0]);
      }
      // Reset input
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    },
    [handleFile]
  );

  const handleRemove = useCallback(
    (e: React.MouseEvent) => {
      e.stopPropagation();
      setPreviewUrl(null);
      setError(null);
      onRemove?.();
    },
    [onRemove]
  );

  const isLoading = uploadMutation.isPending;

  return (
    <div className={`relative inline-block ${className}`}>
      <input
        ref={fileInputRef}
        id={inputId}
        type="file"
        accept="image/jpeg,image/png,image/gif,image/webp"
        onChange={handleFileChange}
        className="sr-only"
        disabled={disabled || isLoading}
      />

      <label
        htmlFor={disabled || isLoading ? undefined : inputId}
        className={`
          ${sizeClasses[size]}
          relative rounded-full overflow-hidden block
          bg-gray-100 border-2 border-gray-200
          transition-all duration-200 group
          ${!disabled && !isLoading ? 'cursor-pointer hover:border-primary-400 hover:shadow-md' : ''}
          ${disabled || isLoading ? 'opacity-70 cursor-not-allowed' : ''}
          ${error ? 'border-red-300' : ''}
        `}
      >
        {/* Avatar Image or Placeholder */}
        {previewUrl ? (
          <img
            src={previewUrl}
            alt="Avatar"
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center bg-gray-200">
            <UserIcon className={`${iconSizeClasses[size]} text-gray-400`} />
          </div>
        )}

        {/* Loading Overlay */}
        {isLoading && (
          <div className="absolute inset-0 bg-black bg-opacity-50 flex flex-col items-center justify-center">
            <Spinner size="sm" className="text-white" />
            <span className="text-white text-xs mt-1">{progress}%</span>
          </div>
        )}

        {/* Camera Icon Overlay - pointer-events-none so clicks pass through to label */}
        {!isLoading && !disabled && (
          <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 flex items-center justify-center transition-all duration-200 pointer-events-none">
            <CameraIcon
              className={`${cameraSizeClasses[size]} text-white opacity-0 group-hover:opacity-100 transition-opacity`}
            />
          </div>
        )}
      </label>

      {/* Remove Button */}
      {previewUrl && onRemove && !isLoading && !disabled && (
        <button
          type="button"
          onClick={handleRemove}
          className="absolute -top-1 -right-1 p-1 bg-red-500 text-white rounded-full shadow-md hover:bg-red-600 transition-colors"
        >
          <XMarkIcon className="h-4 w-4" />
        </button>
      )}

      {/* Error Message */}
      {error && (
        <p className="absolute -bottom-6 left-0 right-0 text-center text-xs text-red-600 truncate">
          {error}
        </p>
      )}
    </div>
  );
};

export default AvatarUpload;
