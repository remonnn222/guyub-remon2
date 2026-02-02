import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/family.dart';
import '../providers/family_provider.dart';
import '../providers/family_state.dart';
import '../widgets/family_card.dart';
import '../widgets/create_family_dialog.dart';
import '../widgets/join_family_dialog.dart';

class FamilyListPage extends ConsumerStatefulWidget {
  const FamilyListPage({super.key});

  @override
  ConsumerState<FamilyListPage> createState() => _FamilyListPageState();
}

class _FamilyListPageState extends ConsumerState<FamilyListPage> {
  @override
  void initState() {
    super.initState();
    // Load families on init
    Future.microtask(() {
      ref.read(familyListProvider.notifier).loadFamilies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keluarga Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(familyListProvider.notifier).loadFamilies(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(familyListProvider.notifier).loadFamilies(),
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody(FamilyListState state) {
    switch (state) {
      case FamilyListInitial():
      case FamilyListLoading():
        return const Center(
          child: CircularProgressIndicator(),
        );

      case FamilyListError(:final message):
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger,
              ),
              AppSpacing.verticalMD,
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              AppSpacing.verticalLG,
              AppButton(
                label: 'Coba Lagi',
                onPressed: () => ref.read(familyListProvider.notifier).loadFamilies(),
              ),
            ],
          ),
        );

      case FamilyListLoaded(:final families, :final isOffline):
        if (families.isEmpty) {
          return _buildEmptyState();
        }
        return Column(
          children: [
            if (isOffline)
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingXS,
                color: AppColors.warning.withValues(alpha: 0.2),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Text(
                      'Mode Offline',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: AppSpacing.paddingMD,
                itemCount: families.length,
                itemBuilder: (context, index) {
                  final family = families[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: FamilyCard(
                      family: family,
                      onTap: () => _navigateToTree(family),
                      onEdit: () => _editFamily(family),
                      onDelete: () => _confirmDelete(family),
                    ),
                  );
                },
              ),
            ),
          ],
        );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            AppSpacing.verticalLG,
            const Text(
              'Belum Ada Keluarga',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSM,
            const Text(
              'Buat silsilah keluarga baru atau gabung dengan keluarga yang sudah ada.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            AppSpacing.verticalXL,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  label: 'Buat Keluarga',
                  leftIcon: Icons.add,
                  onPressed: () => _showCreateFamilyDialog(context),
                ),
                AppSpacing.horizontalMD,
                AppButton(
                  label: 'Gabung',
                  leftIcon: Icons.group_add,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _showJoinFamilyDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.add, color: Colors.white),
                ),
                title: const Text('Buat Keluarga Baru'),
                subtitle: const Text('Mulai silsilah keluarga dari awal'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateFamilyDialog(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info.withValues(alpha: 0.2),
                  child: const Icon(Icons.group_add, color: AppColors.info),
                ),
                title: const Text('Gabung Keluarga'),
                subtitle: const Text('Masukkan kode undangan'),
                onTap: () {
                  Navigator.pop(context);
                  _showJoinFamilyDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateFamilyDialog(
        onCreated: (params) {
          ref.read(familyListProvider.notifier).createFamily(params);
        },
      ),
    );
  }

  void _showJoinFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => JoinFamilyDialog(
        onJoin: (inviteCode) {
          ref.read(familyListProvider.notifier).joinFamily(inviteCode);
        },
      ),
    );
  }

  void _navigateToTree(Family family) {
    context.push(
      RouteNames.buildPath(RouteNames.familyTree, {'id': family.id.toString()}),
    );
  }

  void _editFamily(Family family) {
    context.push(
      RouteNames.buildPath(RouteNames.familyEdit, {'id': family.id.toString()}),
    );
  }

  void _confirmDelete(Family family) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Keluarga?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${family.name}"? Semua data akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(familyListProvider.notifier).deleteFamily(family.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
