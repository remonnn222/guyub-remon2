import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme/app_colors.dart';
import '../../config/routes/route_names.dart';
import '../../features/family/presentation/providers/family_provider.dart';

/// Main Layout with Bottom Navigation Bar
class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: child, bottomNavigationBar: const _BottomNavBar());
  }
}

class _BottomNavBar extends ConsumerWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final pendingSyncCount = ref.watch(pendingSyncCountProvider).value ?? 0;

    Widget _badgeIcon(IconData iconData, bool isSelected) {
      final baseIcon = Icon(
        iconData,
        color: isSelected ? AppColors.primary : null,
      );

      if (pendingSyncCount <= 0) {
        return baseIcon;
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          baseIcon,
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Center(
                child: Text(
                  pendingSyncCount > 9 ? '9+' : pendingSyncCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return NavigationBar(
      selectedIndex: _getSelectedIndex(location),
      onDestinationSelected: (index) => _onItemTapped(context, index),
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.primary),
          label: 'Beranda',
        ),
        const NavigationDestination(
          icon: Icon(Icons.family_restroom_outlined),
          selectedIcon: Icon(Icons.family_restroom, color: AppColors.primary),
          label: 'Keluarga',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: AppColors.primary),
          label: 'Profil',
        ),
        NavigationDestination(
          icon: _badgeIcon(
            Icons.settings_outlined,
            _getSelectedIndex(location) == 3,
          ),
          selectedIcon: _badgeIcon(
            Icons.settings,
            _getSelectedIndex(location) == 3,
          ),
          label: 'Pengaturan',
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith(RouteNames.families)) {
      return 1;
    } else if (location.startsWith(RouteNames.profile)) {
      return 2;
    } else if (location.startsWith(RouteNames.settings)) {
      return 3;
    }
    return 0; // Dashboard
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
        break;
      case 1:
        context.go(RouteNames.families);
        break;
      case 2:
        context.go(RouteNames.profile);
        break;
      case 3:
        context.go(RouteNames.settings);
        break;
    }
  }
}
