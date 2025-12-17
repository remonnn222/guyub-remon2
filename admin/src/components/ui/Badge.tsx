import { clsx } from 'clsx';

export interface BadgeProps {
  variant?: 'success' | 'warning' | 'danger' | 'info' | 'gray' | 'primary';
  size?: 'sm' | 'md';
  children: React.ReactNode;
  className?: string;
}

const Badge: React.FC<BadgeProps> = ({
  variant = 'gray',
  size = 'md',
  children,
  className,
}) => {
  const variants = {
    success: 'bg-green-100 text-green-800',
    warning: 'bg-amber-100 text-amber-800',
    danger: 'bg-red-100 text-red-800',
    info: 'bg-blue-100 text-blue-800',
    gray: 'bg-gray-100 text-gray-800',
    primary: 'bg-primary-100 text-primary-800',
  };

  const sizes = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-0.5 text-xs',
  };

  return (
    <span
      className={clsx(
        'inline-flex items-center rounded-full font-medium',
        variants[variant],
        sizes[size],
        className
      )}
    >
      {children}
    </span>
  );
};

// Status-specific badges
export const StatusBadge: React.FC<{ status: string | { value: string; label: string } }> = ({ status }) => {
  const statusVariants: Record<string, BadgeProps['variant']> = {
    active: 'success',
    inactive: 'gray',
    suspended: 'danger',
    pending: 'warning',
  };

  // Handle both string and object status
  const statusValue = typeof status === 'object' ? status?.value : status;
  const statusLabel = typeof status === 'object' ? status?.label : status;

  if (!statusValue) {
    return <Badge variant="gray">N/A</Badge>;
  }

  return (
    <Badge variant={statusVariants[statusValue.toLowerCase()] || 'gray'}>
      {statusLabel || statusValue.charAt(0).toUpperCase() + statusValue.slice(1)}
    </Badge>
  );
};

export default Badge;
