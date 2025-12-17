import { Outlet } from 'react-router-dom';
import { TreeDeciduous } from 'lucide-react';
import { Toast } from '@/components/ui';

const AuthLayout: React.FC = () => {
  return (
    <div className="min-h-screen bg-stone-50 flex">
      {/* Left Side - Branding */}
      <div className="hidden lg:flex lg:w-1/2 bg-stone-900 relative overflow-hidden">
        {/* Pattern */}
        <div className="absolute inset-0 opacity-10">
          <div className="absolute inset-0" style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='60' height='60' viewBox='0 0 60 60'%3E%3Cpath d='M30 10 L30 50 M30 25 L20 15 M30 25 L40 15 M30 35 L18 25 M30 35 L42 25' stroke='%23ffffff' stroke-width='1' fill='none'/%3E%3C/svg%3E")`,
            backgroundSize: '60px 60px'
          }} />
        </div>

        {/* Content */}
        <div className="relative z-10 flex flex-col justify-between p-10 w-full">
          {/* Logo */}
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-amber-500 flex items-center justify-center">
              <TreeDeciduous className="w-4 h-4 text-white" />
            </div>
            <span className="text-lg font-semibold text-white">Guyub</span>
          </div>

          {/* Tagline */}
          <div className="max-w-md">
            <h1 className="text-2xl font-bold text-white mb-3">
              Manage Your Family Legacy
            </h1>
            <p className="text-sm text-stone-400 leading-relaxed">
              Build beautiful family trees, manage members, and preserve
              your family history for generations to come.
            </p>
          </div>

          {/* Footer */}
          <p className="text-xs text-stone-500">
            © {new Date().getFullYear()} Guyub Platform
          </p>
        </div>
      </div>

      {/* Right Side - Form */}
      <div className="flex-1 flex flex-col justify-center py-12 px-4 sm:px-6 lg:px-16">
        <div className="mx-auto w-full max-w-sm">
          {/* Mobile Logo */}
          <div className="lg:hidden flex justify-center mb-6">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-amber-500 flex items-center justify-center">
                <TreeDeciduous className="w-4 h-4 text-white" />
              </div>
              <span className="text-lg font-semibold text-stone-800">Guyub</span>
            </div>
          </div>

          {/* Form Container */}
          <Outlet />
        </div>
      </div>

      {/* Toast notifications */}
      <Toast />
    </div>
  );
};

export default AuthLayout;
