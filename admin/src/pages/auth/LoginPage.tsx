import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { Eye, EyeOff, Zap, ArrowRight, Loader2 } from 'lucide-react';
import { useAuthStore } from '@/stores/authStore';
import { toast } from '@/stores/uiStore';
import { LoginCredentials, ApiErrorResponse } from '@/types';

// Demo credentials for quick fill
const DEMO_CREDENTIALS = {
  email: 'admin@guyub.id',
  password: 'Admin@123',
};

const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const { login, isLoading } = useAuthStore();
  const [showPassword, setShowPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError,
    setValue,
  } = useForm<LoginCredentials>({
    defaultValues: {
      email: '',
      password: '',
      remember: false,
    },
  });

  const onSubmit = async (data: LoginCredentials) => {
    try {
      await login(data);
      toast.success('Welcome back!', 'You have successfully logged in.');
      navigate('/dashboard', { replace: true });
    } catch (error) {
      const apiError = error as ApiErrorResponse;
      if (apiError.errors) {
        Object.entries(apiError.errors).forEach(([field, messages]) => {
          setError(field as keyof LoginCredentials, {
            message: messages[0],
          });
        });
      } else {
        toast.error('Login failed', apiError.message || 'Invalid credentials');
      }
    }
  };

  // Quick login handler - fills and submits immediately
  const handleQuickLogin = async () => {
    setValue('email', DEMO_CREDENTIALS.email);
    setValue('password', DEMO_CREDENTIALS.password);
    setValue('remember', true);

    try {
      await login({
        email: DEMO_CREDENTIALS.email,
        password: DEMO_CREDENTIALS.password,
        remember: true,
      });
      toast.success('Welcome back!', 'Logged in with demo account.');
      navigate('/dashboard', { replace: true });
    } catch (error) {
      const apiError = error as ApiErrorResponse;
      toast.error('Login failed', apiError.message || 'Invalid credentials');
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="text-center lg:text-left">
        <h2 className="text-xl font-bold text-stone-900">Sign in</h2>
        <p className="mt-1 text-sm text-stone-500">
          Enter your credentials to access the admin panel
        </p>
      </div>

      {/* Quick Fill Button */}
      <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
        <div className="flex items-center justify-between gap-3">
          <div className="flex items-center gap-2 min-w-0">
            <div className="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center flex-shrink-0">
              <Zap className="w-4 h-4 text-amber-600" />
            </div>
            <div className="min-w-0">
              <p className="text-xs font-medium text-amber-800">Demo Account</p>
              <p className="text-[10px] text-amber-600 truncate">{DEMO_CREDENTIALS.email}</p>
            </div>
          </div>
          <button
            type="button"
            onClick={handleQuickLogin}
            disabled={isLoading}
            className="px-3 py-1.5 text-xs font-medium text-amber-700 hover:text-amber-800 bg-amber-100 hover:bg-amber-200 rounded-md transition-colors flex items-center gap-1 flex-shrink-0"
          >
            {isLoading ? (
              <Loader2 className="w-3 h-3 animate-spin" />
            ) : (
              <>
                Quick Login
                <ArrowRight className="w-3 h-3" />
              </>
            )}
          </button>
        </div>
      </div>

      {/* Divider */}
      <div className="relative">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-stone-200" />
        </div>
        <div className="relative flex justify-center text-xs">
          <span className="px-2 bg-stone-50 text-stone-400">or continue with email</span>
        </div>
      </div>

      {/* Login Form */}
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        {/* Email Field */}
        <div>
          <label htmlFor="email" className="block text-xs font-medium text-stone-700 mb-1">
            Email address
          </label>
          <input
            id="email"
            type="email"
            autoComplete="email"
            {...register('email', {
              required: 'Email is required',
              pattern: {
                value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                message: 'Invalid email address',
              },
            })}
            className={`w-full px-3 py-2 text-sm border rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-colors ${
              errors.email ? 'border-red-300' : 'border-stone-200'
            }`}
            placeholder="admin@guyub.id"
          />
          {errors.email && (
            <p className="mt-1 text-xs text-red-500">{errors.email.message}</p>
          )}
        </div>

        {/* Password Field */}
        <div>
          <label htmlFor="password" className="block text-xs font-medium text-stone-700 mb-1">
            Password
          </label>
          <div className="relative">
            <input
              id="password"
              type={showPassword ? 'text' : 'password'}
              autoComplete="current-password"
              {...register('password', {
                required: 'Password is required',
                minLength: {
                  value: 6,
                  message: 'Password must be at least 6 characters',
                },
              })}
              className={`w-full px-3 py-2 pr-10 text-sm border rounded-lg bg-white focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500 transition-colors ${
                errors.password ? 'border-red-300' : 'border-stone-200'
              }`}
              placeholder="••••••••"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-stone-400 hover:text-stone-600"
            >
              {showPassword ? (
                <EyeOff className="w-4 h-4" />
              ) : (
                <Eye className="w-4 h-4" />
              )}
            </button>
          </div>
          {errors.password && (
            <p className="mt-1 text-xs text-red-500">{errors.password.message}</p>
          )}
        </div>

        {/* Remember & Forgot */}
        <div className="flex items-center justify-between">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="checkbox"
              {...register('remember')}
              className="w-3.5 h-3.5 rounded border-stone-300 text-amber-500 focus:ring-amber-500/20"
            />
            <span className="text-xs text-stone-600">Remember me</span>
          </label>
          <a href="#" className="text-xs text-amber-600 hover:text-amber-700 font-medium">
            Forgot password?
          </a>
        </div>

        {/* Submit Button */}
        <button
          type="submit"
          disabled={isLoading}
          className="w-full py-2.5 px-4 text-sm font-medium text-white bg-stone-900 hover:bg-stone-800 rounded-lg transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
        >
          {isLoading ? (
            <>
              <Loader2 className="w-4 h-4 animate-spin" />
              Signing in...
            </>
          ) : (
            'Sign in'
          )}
        </button>
      </form>

      {/* Footer */}
      <p className="text-center text-xs text-stone-400">
        Need help?{' '}
        <a href="#" className="text-amber-600 hover:text-amber-700 font-medium">
          Contact support
        </a>
      </p>
    </div>
  );
};

export default LoginPage;
