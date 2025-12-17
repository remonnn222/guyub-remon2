import { clsx } from 'clsx';

export interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export const Card: React.FC<CardProps> = ({ children, className }) => {
  return (
    <div className={clsx('card', className)}>
      {children}
    </div>
  );
};

export interface CardHeaderProps {
  title?: string;
  description?: string;
  action?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
}

export const CardHeader: React.FC<CardHeaderProps> = ({
  title,
  description,
  action,
  children,
  className,
}) => {
  return (
    <div className={clsx('card-header', className)}>
      {children || (
        <div className="flex items-center justify-between">
          <div>
            {title && (
              <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
            )}
            {description && (
              <p className="mt-1 text-sm text-gray-500">{description}</p>
            )}
          </div>
          {action && <div>{action}</div>}
        </div>
      )}
    </div>
  );
};

export interface CardBodyProps {
  children: React.ReactNode;
  className?: string;
  noPadding?: boolean;
}

export const CardBody: React.FC<CardBodyProps> = ({
  children,
  className,
  noPadding = false,
}) => {
  return (
    <div className={clsx(!noPadding && 'card-body', className)}>
      {children}
    </div>
  );
};

export interface CardFooterProps {
  children: React.ReactNode;
  className?: string;
}

export const CardFooter: React.FC<CardFooterProps> = ({
  children,
  className,
}) => {
  return <div className={clsx('card-footer', className)}>{children}</div>;
};

export default Card;
