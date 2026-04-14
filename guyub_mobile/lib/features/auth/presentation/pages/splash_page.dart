 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/constants/app_constants.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/deep_link_service.dart';
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

    final router = GoRouter.of(context);

    // Check if onboarding is completed
    final prefs = await SharedPreferences.getInstance();
    final isOnboardingCompleted =
        prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

    if (!isOnboardingCompleted) {
      router.go(RouteNames.onboarding);
      return;
    }

    final authState = ref.read(authProvider);
    switch (authState) {
      case AuthStateInitial():
      case AuthStateLoading():
      case AuthStateUnauthenticated():
      case AuthStateError():
        router.go('/login');
        return;
      case AuthStateAuthenticated():
        final deepLinkService = sl<DeepLinkService>();
        if (deepLinkService.hasPendingDeepLink()) {
          final pendingLink = deepLinkService.getAndClearPendingDeepLink();
          if (pendingLink != null) {
            _navigatePendingDeepLink(router, pendingLink);
            return;
          }
        }
        router.go('/dashboard');
        return;
    }
  }

  void _navigatePendingDeepLink(GoRouter router, Uri uri) {
    final path = uri.path;
    if (path.startsWith('/family/')) {
      final inviteCode = path.split('/').last;
      if (inviteCode.isNotEmpty) {
        router.go('/family/$inviteCode');
        return;
      }
    }

    if (path.startsWith('/event/')) {
      final eventId = path.split('/').last;
      if (eventId.isNotEmpty) {
        router.go('/event/$eventId');
        return;
      }
    }

    if (path == '/login') {
      router.go('/login');
      return;
    }

    router.go('/dashboard');
  }

  void _handleAuthState(BuildContext currentContext, AuthState authState) {
    switch (authState) {
      case AuthStateInitial():
      case AuthStateLoading():
        return;
      case AuthStateAuthenticated():
        final deepLinkService = sl<DeepLinkService>();
        if (deepLinkService.hasPendingDeepLink()) {
          final pendingLink = deepLinkService.getAndClearPendingDeepLink();
          if (pendingLink != null) {
            deepLinkService.navigateToDeepLink(currentContext, pendingLink);
            return;
          }
        }
        if (!mounted) return;
        GoRouter.of(currentContext).go('/dashboard');
        return;
      case AuthStateUnauthenticated():
      case AuthStateError():
        if (!mounted) return;
        GoRouter.of(currentContext).go('/login');
        return;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentContext = context;

    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      _handleAuthState(currentContext, next);
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
