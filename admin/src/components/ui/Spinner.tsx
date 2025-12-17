import { clsx } from 'clsx';

export interface SpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

const Spinner: React.FC<SpinnerProps> = ({ size = 'md', className }) => {
  const sizes = {
    sm: 'h-4 w-4 border-2',
    md: 'h-6 w-6 border-2',
    lg: 'h-8 w-8 border-[3px]',
  };

  return (
    <div
      className={clsx(
        'animate-spin rounded-full border-current border-t-transparent',
        sizes[size],
        className
      )}
      role="status"
      aria-label="Loading"
    >
      <span className="sr-only">Loading...</span>
    </div>
  );
};

export const LoadingOverlay: React.FC<{ message?: string }> = ({
  message = 'Loading...',
}) => {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-white bg-opacity-75">
      <div className="text-center">
        <Spinner size="lg" className="text-primary-600 mx-auto" />
        <p className="mt-3 text-sm text-gray-600">{message}</p>
      </div>
    </div>
  );
};

export const InlineLoader: React.FC<{ message?: string }> = ({
  message = 'Loading...',
}) => {
  return (
    <div className="flex items-center justify-center py-12">
      <div className="text-center">
        <Spinner size="md" className="text-primary-600 mx-auto" />
        {message && <p className="mt-2 text-sm text-gray-500">{message}</p>}
      </div>
    </div>
  );
};

export { Spinner };
export default Spinner;
