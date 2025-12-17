import { useState, useRef, useCallback } from 'react';
import { CloudArrowUpIcon, XMarkIcon, DocumentIcon } from '@heroicons/react/24/outline';
import { useMutation } from '@tanstack/react-query';
import { assetsApi, UploadOptions } from '@/api/assets';
import { Asset, AssetKind } from '@/types';
import { Spinner } from './Spinner';

interface FileUploadProps {
  kind: AssetKind;
  refId?: string;
  accept?: string;
  maxSize?: number; // in MB
  onUploadSuccess?: (asset: Asset) => void;
  onUploadError?: (error: string) => void;
  className?: string;
  disabled?: boolean;
  label?: string;
  hint?: string;
}

export const FileUpload: React.FC<FileUploadProps> = ({
  kind,
  refId,
  accept = 'image/*',
  maxSize = 2,
  onUploadSuccess,
  onUploadError,
  className = '',
  disabled = false,
  label = 'Upload a file',
  hint,
}) => {
  const [isDragging, setIsDragging] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const uploadMutation = useMutation({
    mutationFn: async (file: File) => {
      const options: UploadOptions = {
        kind,
        refId,
        onProgress: setProgress,
      };
      return assetsApi.upload(file, options);
    },
    onSuccess: (response) => {
      setProgress(0);
      setError(null);
      if (response.data) {
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

  const validateFile = useCallback(
    (file: File): string | null => {
      // Check file size
      const maxSizeBytes = maxSize * 1024 * 1024;
      if (file.size > maxSizeBytes) {
        return `File size must be less than ${maxSize}MB`;
      }

      // Check file type if accept is specified
      if (accept && accept !== '*') {
        const acceptTypes = accept.split(',').map((t) => t.trim());
        const isValid = acceptTypes.some((type) => {
          if (type.endsWith('/*')) {
            const category = type.split('/')[0];
            return file.type.startsWith(category + '/');
          }
          return file.type === type || file.name.endsWith(type);
        });
        if (!isValid) {
          return 'Invalid file type';
        }
      }

      return null;
    },
    [accept, maxSize]
  );

  const handleFile = useCallback(
    (file: File) => {
      const validationError = validateFile(file);
      if (validationError) {
        setError(validationError);
        onUploadError?.(validationError);
        return;
      }

      setError(null);
      uploadMutation.mutate(file);
    },
    [validateFile, uploadMutation, onUploadError]
  );

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  }, []);

  const handleDragLeave = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  }, []);

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      e.stopPropagation();
      setIsDragging(false);

      if (disabled || uploadMutation.isPending) return;

      const files = e.dataTransfer.files;
      if (files.length > 0) {
        handleFile(files[0]);
      }
    },
    [disabled, uploadMutation.isPending, handleFile]
  );

  const handleClick = useCallback(() => {
    if (!disabled && !uploadMutation.isPending) {
      fileInputRef.current?.click();
    }
  }, [disabled, uploadMutation.isPending]);

  const handleFileChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const files = e.target.files;
      if (files && files.length > 0) {
        handleFile(files[0]);
      }
      // Reset input so same file can be selected again
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    },
    [handleFile]
  );

  const isLoading = uploadMutation.isPending;

  return (
    <div className={className}>
      <input
        ref={fileInputRef}
        type="file"
        accept={accept}
        onChange={handleFileChange}
        className="hidden"
        disabled={disabled || isLoading}
      />

      <div
        onClick={handleClick}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        className={`
          relative border-2 border-dashed rounded-lg p-6 text-center cursor-pointer
          transition-colors duration-200
          ${isDragging ? 'border-primary-500 bg-primary-50' : 'border-gray-300 hover:border-gray-400'}
          ${disabled || isLoading ? 'opacity-50 cursor-not-allowed' : ''}
          ${error ? 'border-red-300 bg-red-50' : ''}
        `}
      >
        {isLoading ? (
          <div className="flex flex-col items-center">
            <Spinner size="lg" className="mb-2" />
            <p className="text-sm text-gray-600">Uploading... {progress}%</p>
            <div className="w-full max-w-xs mt-2 bg-gray-200 rounded-full h-2">
              <div
                className="bg-primary-600 h-2 rounded-full transition-all duration-300"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>
        ) : (
          <>
            <CloudArrowUpIcon className="mx-auto h-12 w-12 text-gray-400" />
            <p className="mt-2 text-sm font-medium text-gray-900">{label}</p>
            <p className="mt-1 text-xs text-gray-500">
              Drag and drop or click to browse
            </p>
            {hint && <p className="mt-1 text-xs text-gray-400">{hint}</p>}
          </>
        )}
      </div>

      {error && (
        <div className="mt-2 flex items-center text-sm text-red-600">
          <XMarkIcon className="h-4 w-4 mr-1" />
          {error}
        </div>
      )}
    </div>
  );
};

// Preview component for uploaded files
interface FilePreviewProps {
  asset: Asset;
  onRemove?: () => void;
  className?: string;
}

export const FilePreview: React.FC<FilePreviewProps> = ({
  asset,
  onRemove,
  className = '',
}) => {
  return (
    <div className={`relative group ${className}`}>
      {asset.is_image ? (
        <img
          src={asset.url}
          alt={asset.original_filename}
          className="w-full h-full object-cover rounded-lg"
        />
      ) : (
        <div className="w-full h-full flex flex-col items-center justify-center bg-gray-100 rounded-lg p-4">
          <DocumentIcon className="h-12 w-12 text-gray-400" />
          <p className="mt-2 text-xs text-gray-600 text-center truncate max-w-full">
            {asset.original_filename}
          </p>
          <p className="text-xs text-gray-400">{asset.human_size}</p>
        </div>
      )}

      {onRemove && (
        <button
          type="button"
          onClick={onRemove}
          className="absolute -top-2 -right-2 p-1 bg-red-500 text-white rounded-full opacity-0 group-hover:opacity-100 transition-opacity shadow-md hover:bg-red-600"
        >
          <XMarkIcon className="h-4 w-4" />
        </button>
      )}
    </div>
  );
};

export default FileUpload;
