import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../core/utils/input_sanitizer.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Login Page
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Check rate limiter first
    final rateLimiter = ref.read(loginRateLimiterProvider);

    if (rateLimiter.isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rateLimiter.lockoutMessage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      // Record attempt before login
      rateLimiter.recordAttempt();

      // Show warning if low attempts remaining
      final warning = rateLimiter.warningMessage;
      if (warning.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(warning), backgroundColor: AppColors.warning),
        );
      }

      // Sanitize email before sending
      final sanitizedEmail = InputSanitizer.sanitizeEmail(
        _emailController.text,
      );

      ref
          .read(authProvider.notifier)
          .login(
            sanitizedEmail,
            _passwordController.text,
            rememberMe: _rememberMe,
          );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final biometricService = sl<BiometricService>();

    // Check if biometric is enabled
    final isEnabled = await biometricService.isBiometricLoginEnabled;
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login biometrik belum diaktifkan')),
      );
      return;
    }

    // Attempt biometric authentication
    final result = await biometricService.authenticate(
      reason: 'Masuk dengan biometrik',
      biometricOnly: true,
    );

    if (result.isSuccess) {
      // Get stored credentials and login
      final credentials = await biometricService.getBiometricCredentials();
      if (credentials != null) {
        final (email, password) = credentials;
        ref
            .read(authProvider.notifier)
            .login(email, password, rememberMe: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kredensial biometrik tidak ditemukan')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);
    final error = ref.watch(authErrorProvider);

    // Navigate on successful login and reset rate limiter
    ref.listen(authProvider, (previous, next) async {
      if (next is AuthStateAuthenticated) {
        // Reset rate limiter on successful login
        ref.read(loginRateLimiterProvider).reset();

        // Check if biometric should be offered
        final biometricService = sl<BiometricService>();
        final isSupported = await biometricService.isSupported;
        final isEnabled = await biometricService.isBiometricLoginEnabled;

        if (isSupported && !isEnabled) {
          // Show biometric enable dialog
          _showEnableBiometricDialog(
            context,
            _emailController.text,
            _passwordController.text,
          );
        } else {
          // Navigate to dashboard
          context.go('/dashboard');
        }
      }
    });

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Memproses login...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingPage,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Brand
                      _buildHeader(),

                      AppSpacing.height32,

                      // Login Form
                      _buildLoginForm(isLoading),

                      // Error Message
                      if (error != null) ...[
                        AppSpacing.height16,
                        _buildErrorMessage(error),
                      ],

                      AppSpacing.height24,

                      // Login Button
                      AppButton(
                        label: 'Masuk',
                        onPressed: isLoading ? null : _handleLogin,
                        isLoading: isLoading,
                        isFullWidth: true,
                      ),

                      AppSpacing.height16,

                      // Biometric Login Button
                      FutureBuilder<bool>(
                        future: sl<BiometricService>().isBiometricLoginEnabled,
                        builder: (context, snapshot) {
                          if (snapshot.data == true) {
                            return Column(
                              children: [
                                const Text(
                                  'atau',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                AppSpacing.height8,
                                IconButton(
                                  onPressed: isLoading
                                      ? null
                                      : _handleBiometricLogin,
                                  icon: const Icon(
                                    Icons.fingerprint,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Login dengan biometrik',
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      AppSpacing.height16,

                      // Footer Links
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: AppSpacing.borderRadiusXl,
          ),
          child: const Icon(
            Icons.account_tree_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.height16,
        Text(
          'Guyub',
          style: AppTypography.headlineLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.height4,
        Text(
          'Family Tree Platform',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.height32,
        Text('Masuk ke Akun Anda', style: AppTypography.titleLarge),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      children: [
        // Email Field
        AppTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Masukkan email Anda',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_outlined,
          enabled: !isLoading,
          validator: (value) => InputValidators.combine(value, [
            (v) => InputValidators.required(v, 'Email'),
            InputValidators.email,
          ]),
        ),

        AppSpacing.height16,

        // Password Field
        AppTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Masukkan password Anda',
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.lock_outline,
          enabled: !isLoading,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.iconSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) => InputValidators.combine(value, [
            (v) => InputValidators.required(v, 'Password'),
            (v) => InputValidators.minLength(v, 6, 'Password'),
          ]),
          onFieldSubmitted: (_) => _handleLogin(),
        ),

        AppSpacing.height16,

        // Remember Me Checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
              activeColor: AppColors.primary,
            ),
            const Text('Ingat Saya'),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: AppSpacing.paddingAll12,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          AppSpacing.width8,
          Expanded(
            child: Text(
              error,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Forgot Password
        TextButton(
          onPressed: () {
            // TODO: Navigate to forgot password
          },
          child: Text(
            'Lupa Password?',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
          ),
        ),
        AppSpacing.height16,
        // Version Info
        Text('Guyub v1.0.0', style: AppTypography.caption),
      ],
    );
  }

  Future<void> _showEnableBiometricDialog(
    BuildContext context,
    String email,
    String password,
  ) async {
    final biometricService = sl<BiometricService>();
    final availableBiometrics = await biometricService.getAvailableBiometrics();

    String biometricType = 'sidik jari';
    if (availableBiometrics.contains(AppBiometricType.faceId)) {
      biometricType = 'Face ID';
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aktifkan Login Biometrik'),
        content: Text(
          'Apakah Anda ingin mengaktifkan login dengan $biometricType? '
          'Ini akan memungkinkan Anda masuk lebih cepat di lain waktu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nanti Saja'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aktifkan'),
          ),
        ],
      ),
    );

    if (result == true) {
      final enableResult = await biometricService.enableBiometricLogin(
        email: email,
        password: password,
      );

      if (enableResult) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login biometrik berhasil diaktifkan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengaktifkan login biometrik'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    // Navigate to dashboard regardless
    context.go('/dashboard');
  }
}
