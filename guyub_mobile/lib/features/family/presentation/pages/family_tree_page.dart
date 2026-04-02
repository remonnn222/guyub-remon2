import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/family.dart';
import '../providers/family_provider.dart';
import '../providers/family_state.dart';
import '../widgets/family_tree_graph.dart';
import '../widgets/family_tree_list.dart';
import '../widgets/person_detail_sheet.dart';
import '../widgets/add_person_dialog.dart';
import '../widgets/add_relationship_dialog.dart';

class FamilyTreePage extends ConsumerStatefulWidget {
  final int familyId;

  const FamilyTreePage({super.key, required this.familyId});

  @override
  ConsumerState<FamilyTreePage> createState() => _FamilyTreePageState();
}

class _FamilyTreePageState extends ConsumerState<FamilyTreePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyTreeProvider(widget.familyId));
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // Auto-switch view mode based on screen size
    final TreeViewMode viewMode = ref.watch(treeViewModeProvider);
    final showGraphView = switch (viewMode) {
      TreeViewMode.auto => isTablet,
      TreeViewMode.graph => true,
      TreeViewMode.list => false,
    };

    return Scaffold(
      appBar: _buildAppBar(state, showGraphView),
      body: _buildBody(state, showGraphView),
      floatingActionButton: _buildFAB(state),
    );
  }

  PreferredSizeWidget _buildAppBar(FamilyTreeState state, bool showGraphView) {
    final title = switch (state) {
      FamilyTreeLoaded(:final treeData) => treeData.family.name,
      _ => 'Pohon Keluarga',
    };

    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        // View mode toggle
        IconButton(
          icon: Icon(showGraphView ? Icons.list : Icons.account_tree),
          tooltip: showGraphView ? 'Tampilan List' : 'Tampilan Pohon',
          onPressed: () {
            ref.read(treeViewModeProvider.notifier).toggle(showGraphView);
          },
        ),
        // Refresh
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () =>
              ref.read(familyTreeProvider(widget.familyId).notifier).refresh(),
        ),
        // More options
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, state),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Bagikan'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Ekspor'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Pengaturan'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(FamilyTreeState state, bool showGraphView) {
    switch (state) {
      case FamilyTreeInitial():
      case FamilyTreeLoading():
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat pohon keluarga...'),
            ],
          ),
        );

      case FamilyTreeError(:final message):
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
              Text(message, textAlign: TextAlign.center),
              AppSpacing.verticalLG,
              ElevatedButton(
                onPressed: () => ref
                    .read(familyTreeProvider(widget.familyId).notifier)
                    .refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );

      case FamilyTreeLoaded(
        :final treeData,
        :final isOffline,
        :final selectedPerson,
      ):
        if (treeData.persons.isEmpty) {
          return _buildEmptyTree(treeData.family);
        }

        return Column(
          children: [
            // Offline indicator
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
                      'Mode Offline - Perubahan akan disinkronkan',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // Tree stats bar
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    Icons.people,
                    '${treeData.persons.length}',
                    'Anggota',
                  ),
                  _buildStat(
                    Icons.family_restroom,
                    '${_countGenerations(treeData)}',
                    'Generasi',
                  ),
                  _buildStat(
                    Icons.favorite,
                    '${_countMarriages(treeData)}',
                    'Pernikahan',
                  ),
                ],
              ),
            ),

            // Tree visualization
            Expanded(
              child: showGraphView
                  ? FamilyTreeGraph(
                      treeData: treeData,
                      selectedPerson: selectedPerson,
                      onPersonSelected: (person) => _showPersonDetail(person),
                      onPositionsChanged: (positions) {
                        ref
                            .read(familyTreeProvider(widget.familyId).notifier)
                            .updatePositions(positions);
                      },
                    )
                  : FamilyTreeList(
                      treeData: treeData,
                      selectedPerson: selectedPerson,
                      onPersonSelected: (person) => _showPersonDetail(person),
                    ),
            ),
          ],
        );
    }
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmptyTree(Family family) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            AppSpacing.verticalLG,
            const Text(
              'Pohon Keluarga Kosong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.verticalSM,
            const Text(
              'Mulai dengan menambahkan anggota keluarga pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            AppSpacing.verticalXL,
            ElevatedButton.icon(
              onPressed: () => _showAddPersonDialog(family.id),
              icon: const Icon(Icons.person_add),
              label: const Text('Tambah Anggota Pertama'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFAB(FamilyTreeState state) {
    if (state is! FamilyTreeLoaded || state.treeData.persons.isEmpty) {
      return null;
    }

    return FloatingActionButton(
      onPressed: () => _showAddOptions(state.treeData),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showAddOptions(FamilyTreeData treeData) {
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
                  child: Icon(Icons.person_add, color: Colors.white),
                ),
                title: const Text('Tambah Anggota Baru'),
                subtitle: const Text('Tambahkan anggota keluarga baru'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddPersonDialog(treeData.family.id);
                },
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info.withValues(alpha: 0.2),
                  child: const Icon(Icons.link, color: AppColors.info),
                ),
                title: const Text('Buat Hubungan'),
                subtitle: const Text('Hubungkan dua anggota keluarga'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddRelationshipDialog(treeData);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPersonDialog(int familyId) {
    showDialog(
      context: context,
      builder: (context) => AddPersonDialog(
        familyId: familyId,
        onPersonAdded: () {
          ref.read(familyTreeProvider(widget.familyId).notifier).refresh();
        },
      ),
    );
  }

  void _showAddRelationshipDialog(FamilyTreeData treeData) {
    showDialog(
      context: context,
      builder: (context) => AddRelationshipDialog(
        persons: treeData.persons,
        onRelationshipAdded: () {
          ref.read(familyTreeProvider(widget.familyId).notifier).refresh();
        },
      ),
    );
  }

  void _showPersonDetail(Person person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => PersonDetailSheet(
          person: person,
          scrollController: scrollController,
          onEdit: () {
            Navigator.pop(context);
            // Navigate to edit page
          },
          onAddRelative: (type) {
            Navigator.pop(context);
            // Show add relative dialog
          },
          onDelete: () {
            Navigator.pop(context);
            _confirmDeletePerson(person);
          },
        ),
      ),
    );
  }

  void _confirmDeletePerson(Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anggota?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${person.fullName}"? '
          'Semua hubungan dengan anggota lain juga akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(personFormProvider.notifier).deletePerson(person.id);
              ref.read(familyTreeProvider(widget.familyId).notifier).refresh();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, FamilyTreeState state) {
    switch (action) {
      case 'share':
        if (state is FamilyTreeLoaded) {
          _showShareDialog(state.treeData.family);
        }
        break;
      case 'export':
    
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur ekspor akan segera hadir')),
        );
        break;
      case 'settings':
        break;
    }
  }

  void _showShareDialog(Family family) {
    final inviteCode = family.inviteCode ?? '';
    final familyName = family.name;
    final shareUrl = 'https://guyub.id/invite/$inviteCode';

    final shareMessage =
        'Yuk bergabung ke keluarga $familyName di Guyub!\n'
        'Kode undangan: $inviteCode\n'
        'Link: $shareUrl';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bagikan Keluarga'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Undang anggota keluarga lain untuk bergabung:'),
            AppSpacing.verticalMD,
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kode Undangan:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SelectableText(
                    inviteCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  AppSpacing.verticalSM,
                  const Text(
                    'Link:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SelectableText(
                    shareUrl,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (inviteCode.isNotEmpty) ...[
            TextButton(
              onPressed: () async {
                // Copy to clipboard
                await _copyToClipboard(inviteCode);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Salin Kode'),
            ),
            TextButton(
              onPressed: () async {
                // Share using system share sheet
                await Share.share(
                  shareMessage,
                  subject: 'Undangan Bergabung Keluarga $familyName',
                );
                if (mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Bagikan'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kode $text disalin ke clipboard')),
      );
    }
  }

  int _countGenerations(FamilyTreeData treeData) {
    if (treeData.persons.isEmpty) return 0;
    final levels = treeData.persons.map((p) => p.generationLevel).toSet();
    return levels.length;
  }

  int _countMarriages(FamilyTreeData treeData) {
    return treeData.relationships
        .where((r) => r.type == RelationshipType.spouse)
        .length;
  }
}
