import { forwardRef, ButtonHTMLAttributes } from 'react';
import { clsx } from 'clsx';
import { Loader2 } from 'lucide-react';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      loading = false,
      leftIcon,
      rightIcon,
      className,
      disabled,
      children,
      ...props
    },
    ref
  ) => {
    const baseStyles =
      'inline-flex items-center justify-center font-medium rounded-md transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-offset-1 disabled:opacity-50 disabled:cursor-not-allowed';

    const variants = {
      primary: 'bg-stone-900 text-white hover:bg-stone-800 focus:ring-stone-400',
      secondary:
        'bg-white text-stone-700 border border-stone-200 hover:bg-stone-50 focus:ring-stone-300',
      danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-400',
      ghost: 'text-stone-600 hover:bg-stone-100 focus:ring-stone-300',
    };

    const sizes = {
      sm: 'px-2.5 py-1 text-[11px] gap-1',
      md: 'px-3 py-1.5 text-xs gap-1.5',
      lg: 'px-4 py-2 text-sm gap-2',
    };

    const iconSizes = {
      sm: 'w-3 h-3',
      md: 'w-3.5 h-3.5',
      lg: 'w-4 h-4',
    };

    return (
      <button
        ref={ref}
        className={clsx(baseStyles, variants[variant], sizes[size], className)}
        disabled={disabled || loading}
        {...props}
      >
        {loading ? (
          <>
            <Loader2 className={clsx('animate-spin', iconSizes[size])} />
            <span>Loading...</span>
          </>
        ) : (
          <>
            {leftIcon && <span className={iconSizes[size]}>{leftIcon}</span>}
            {children}
            {rightIcon && <span className={iconSizes[size]}>{rightIcon}</span>}
          </>
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';

export default Button;
