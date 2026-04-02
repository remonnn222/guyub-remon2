import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/family/presentation/pages/family_list_page.dart';
import '../../features/family/presentation/pages/family_tree_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/di/injection_container.dart';
import '../../shared/layouts/main_layout.dart';
import 'route_names.dart';

/// Router Provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RouteNames.login;
      final isSplash = state.matchedLocation == RouteNames.splash;

      // Don't redirect on splash page - it handles its own navigation
      if (isSplash) return null;

      final isAuthenticated = switch (authState) {
        AuthStateAuthenticated() => true,
        _ => false,
      };

      // Check for pending deep link after login
      if (isAuthenticated) {
        final deepLinkService = sl<DeepLinkService>();
        if (deepLinkService.hasPendingDeepLink()) {
          final pendingLink = deepLinkService.getAndClearPendingDeepLink();
          if (pendingLink != null) {
            // Schedule navigation for next frame to avoid context issues
            Future.microtask(() {
              // This will be handled by the page that loads after authentication
            });
            return null; // Don't redirect, let deep link handle navigation
          }
        }
        return RouteNames.dashboard;
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isLoggingIn) {
        return RouteNames.login;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main Shell Route with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),

          // Family List
          GoRoute(
            path: RouteNames.families,
            name: 'families',
            builder: (context, state) => const FamilyListPage(),
          ),

          // Profile
          GoRoute(
            path: RouteNames.profile,
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),

          // Edit Profile
          GoRoute(
            path: RouteNames.editProfile,
            name: 'edit-profile',
            builder: (context, state) => const EditProfilePage(),
          ),

          // Change Password
          GoRoute(
            path: RouteNames.changePassword,
            name: 'change-password',
            builder: (context, state) => const ChangePasswordPage(),
          ),

          // Settings
          GoRoute(
            path: RouteNames.settings,
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),

      // Family Tree (full screen, no bottom nav)
      GoRoute(
        path: '${RouteNames.families}/:id/tree',
        name: 'family-tree',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return FamilyTreePage(familyId: id);
        },
      ),

      // Family Detail
      GoRoute(
        path: '${RouteNames.families}/:id',
        name: 'family-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return FamilyTreePage(familyId: id);
        },
      ),

      // Person Routes
      GoRoute(
        path: '${RouteNames.persons}/:id',
        name: 'person-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return _PlaceholderPage(title: 'Detail Person: $id');
        },
      ),

      // Deep Link Routes
      GoRoute(
        path: '/family/:inviteCode',
        name: 'deep-link-family',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode']!;
          // TODO: Navigate to family tree or join family dialog
          return _PlaceholderPage(title: 'Family Invite: $inviteCode');
        },
      ),

      GoRoute(
        path: '/event/:eventId',
        name: 'deep-link-event',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return _PlaceholderPage(title: 'Event Detail: $eventId');
        },
      ),

      GoRoute(
        path: '/invite/:inviteCode',
        name: 'deep-link-invite',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode']!;
          // Show join family dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showJoinFamilyDialog(context, inviteCode);
          });
          return const DashboardPage(); // Return dashboard as base page
        },
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Halaman tidak ditemukan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.dashboard),
              child: const Text('Kembali ke Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Show join family dialog for deep link
void _showJoinFamilyDialog(BuildContext context, String inviteCode) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Bergabung ke Keluarga'),
      content: Text(
        'Apakah Anda ingin bergabung ke keluarga dengan kode undangan: $inviteCode?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Implement join family logic
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur bergabung keluarga akan segera hadir'),
              ),
            );
          },
          child: const Text('Bergabung'),
        ),
      ],
    ),
  );
}

/// Placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Halaman ini sedang dalam pengembangan',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
