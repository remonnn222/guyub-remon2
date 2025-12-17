import { Fragment } from 'react';
import { Transition } from '@headlessui/react';
import {
  CheckCircleIcon,
  ExclamationCircleIcon,
  ExclamationTriangleIcon,
  InformationCircleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import { clsx } from 'clsx';
import { useUIStore } from '@/stores/uiStore';

const Toast: React.FC = () => {
  const { toasts, removeToast } = useUIStore();

  const icons = {
    success: CheckCircleIcon,
    error: ExclamationCircleIcon,
    warning: ExclamationTriangleIcon,
    info: InformationCircleIcon,
  };

  const colors = {
    success: 'bg-green-50 border-green-200',
    error: 'bg-red-50 border-red-200',
    warning: 'bg-amber-50 border-amber-200',
    info: 'bg-blue-50 border-blue-200',
  };

  const iconColors = {
    success: 'text-green-500',
    error: 'text-red-500',
    warning: 'text-amber-500',
    info: 'text-blue-500',
  };

  return (
    <div
      aria-live="assertive"
      className="fixed inset-0 flex items-end px-4 py-6 pointer-events-none sm:p-6 sm:items-start z-50"
    >
      <div className="w-full flex flex-col items-center space-y-4 sm:items-end">
        {toasts.map((toast) => {
          const Icon = icons[toast.type];

          return (
            <Transition
              key={toast.id}
              show={true}
              as={Fragment}
              enter="transform ease-out duration-300 transition"
              enterFrom="translate-y-2 opacity-0 sm:translate-y-0 sm:translate-x-2"
              enterTo="translate-y-0 opacity-100 sm:translate-x-0"
              leave="transition ease-in duration-100"
              leaveFrom="opacity-100"
              leaveTo="opacity-0"
            >
              <div
                className={clsx(
                  'max-w-sm w-full shadow-lg rounded-lg pointer-events-auto border',
                  colors[toast.type]
                )}
              >
                <div className="p-4">
                  <div className="flex items-start">
                    <div className="flex-shrink-0">
                      <Icon
                        className={clsx('h-5 w-5', iconColors[toast.type])}
                        aria-hidden="true"
                      />
                    </div>
                    <div className="ml-3 w-0 flex-1">
                      <p className="text-sm font-medium text-gray-900">
                        {toast.title}
                      </p>
                      {toast.message && (
                        <p className="mt-1 text-sm text-gray-500">
                          {toast.message}
                        </p>
                      )}
                    </div>
                    <div className="ml-4 flex-shrink-0 flex">
                      <button
                        className="rounded-md inline-flex text-gray-400 hover:text-gray-500 focus:outline-none"
                        onClick={() => removeToast(toast.id)}
                      >
                        <span className="sr-only">Close</span>
                        <XMarkIcon className="h-5 w-5" aria-hidden="true" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </Transition>
          );
        })}
      </div>
    </div>
  );
};

export default Toast;
