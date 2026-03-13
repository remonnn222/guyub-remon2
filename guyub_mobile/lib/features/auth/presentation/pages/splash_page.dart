import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Splash Page
/// Shows app branding while checking authentication status
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _checkAuthAndNavigate();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Check auth state and navigate
    final authState = ref.read(authProvider);

    switch (authState) {
      case AuthStateInitial():
      case AuthStateLoading():
        // Still checking/loading - wait for state change
        break;
      case AuthStateAuthenticated():
        // Check if biometric is enabled and perform biometric auth
        final biometricService = sl<BiometricService>();
        final isBiometricEnabled =
            await biometricService.isBiometricLoginEnabled;

        if (isBiometricEnabled) {
          final result = await biometricService.authenticate(
            reason: 'Verifikasi untuk melanjutkan',
            biometricOnly: true,
          );

          if (result.isSuccess) {
            context.go('/dashboard');
          } else {
            // Biometric failed, go to login
            context.go('/login');
          }
        } else {
          context.go('/dashboard');
        }
      case AuthStateUnauthenticated():
      case AuthStateError():
        context.go('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) async {
      switch (next) {
        case AuthStateInitial():
        case AuthStateLoading():
          break;
        case AuthStateAuthenticated():
          // Check if biometric is enabled and perform biometric auth
          final biometricService = sl<BiometricService>();
          final isBiometricEnabled =
              await biometricService.isBiometricLoginEnabled;

          if (isBiometricEnabled) {
            final result = await biometricService.authenticate(
              reason: 'Verifikasi untuk melanjutkan',
              biometricOnly: true,
            );

            if (result.isSuccess) {
              context.go('/dashboard');
            } else {
              // Biometric failed, go to login
              context.go('/login');
            }
          } else {
            context.go('/dashboard');
          }
        case AuthStateUnauthenticated():
        case AuthStateError():
          context.go('/login');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSpacing.borderRadiusXxl,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),

                    AppSpacing.height24,

                    // App Name
                    Text(
                      'Guyub',
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    AppSpacing.height8,

                    // Tagline
                    Text(
                      'Family Tree Platform',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),

                    AppSpacing.height48,

                    // Loading indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
