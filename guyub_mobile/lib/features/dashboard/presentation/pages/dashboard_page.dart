import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../../family/presentation/providers/family_state.dart';

/// Dashboard Page
/// Shows user welcome, family statistics, and quick actions
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final familyState = ref.watch(familyListProvider);

    // Get user data
    final user = switch (authState) {
      AuthStateAuthenticated(:final user) => user,
      _ => null,
    };

    // Get family count
    final familyCount = switch (familyState) {
      FamilyListLoaded(:final families) => families.length,
      _ => 0,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guyub'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikasi akan segera hadir')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(familyListProvider.notifier).loadFamilies();
        },
        child: ListView(
          padding: AppSpacing.paddingLG,
          children: [
            // Welcome card
            _WelcomeCard(user: user),
            AppSpacing.verticalLG,

            // Stats section
            _StatsSection(familyCount: familyCount),
            AppSpacing.verticalLG,

            // Quick actions
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSM,
            _QuickActionsGrid(),
            AppSpacing.verticalLG,

            // Recent families
            if (familyState is FamilyListLoaded &&
                familyState.families.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Keluarga Terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/families'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              AppSpacing.verticalSM,
              _RecentFamiliesList(
                families: familyState.families.take(3).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final dynamic user;

  const _WelcomeCard({this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Pengguna';
    final greeting = _getGreeting();

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: user?.avatarUrl != null
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user?.avatarUrl == null
                ? Text(
                    _getInitials(name),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          AppSpacing.horizontalMD,
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _StatsSection extends StatelessWidget {
  final int familyCount;

  const _StatsSection({required this.familyCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.family_restroom,
            value: '$familyCount',
            label: 'Keluarga',
            color: AppColors.primary,
          ),
        ),
        AppSpacing.horizontalMD,
        const Expanded(
          child: _StatCard(
            icon: Icons.people,
            value: '-',
            label: 'Anggota',
            color: AppColors.info,
          ),
        ),
        AppSpacing.horizontalMD,
        const Expanded(
          child: _StatCard(
            icon: Icons.account_tree,
            value: '-',
            label: 'Generasi',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.family_restroom,
            label: 'Keluarga Saya',
            color: AppColors.primary,
            onTap: () => context.go('/families'),
          ),
        ),
        AppSpacing.horizontalMD,
        Expanded(
          child: _QuickActionCard(
            icon: Icons.event,
            label: 'Event',
            color: AppColors.success,
            onTap: () => context.go('/events'),
          ),
        ),
        AppSpacing.horizontalMD,
        Expanded(
          child: _QuickActionCard(
            icon: Icons.person_add,
            label: 'Buat Keluarga',
            color: AppColors.info,
            onTap: () => context.go('/families'),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentFamiliesList extends StatelessWidget {
  final List<dynamic> families;

  const _RecentFamiliesList({required this.families});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: families.map((family) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
              child: const Icon(
                Icons.family_restroom,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              family.name ?? 'Keluarga',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              family.description ?? 'Tidak ada deskripsi',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/families/${family.id}/tree'),
          ),
        );
      }).toList(),
    );
  }
}
