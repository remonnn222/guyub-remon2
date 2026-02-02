import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../domain/entities/family.dart';

/// Person Detail Bottom Sheet
class PersonDetailSheet extends StatelessWidget {
  final Person person;
  final ScrollController scrollController;
  final VoidCallback? onEdit;
  final void Function(RelationshipType type)? onAddRelative;
  final VoidCallback? onDelete;

  const PersonDetailSheet({
    super.key,
    required this.person,
    required this.scrollController,
    this.onEdit,
    this.onAddRelative,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = _getNodeColor(person.gender);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ListView(
        controller: scrollController,
        padding: AppSpacing.paddingLG,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Avatar and name header
          Row(
            children: [
              _buildAvatar(nodeColor),
              AppSpacing.horizontalLG,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: nodeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            person.genderDisplay,
                            style: TextStyle(
                              fontSize: 12,
                              color: nodeColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!person.isAlive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Almarhum/ah',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalLG,

          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
              AppSpacing.horizontalSM,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddRelativeOptions(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Tambah'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.info,
                  ),
                ),
              ),
              AppSpacing.horizontalSM,
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                ),
                child: const Icon(Icons.delete, size: 18),
              ),
            ],
          ),
          AppSpacing.verticalLG,

          // Info sections
          const Divider(),
          AppSpacing.verticalMD,

          // Birth info
          if (person.birthDate != null || person.birthPlace != null)
            _buildInfoSection(
              Icons.cake,
              'Kelahiran',
              [
                if (person.birthDate != null)
                  _formatDate(person.birthDate!),
                if (person.birthPlace != null)
                  'di ${person.birthPlace}',
                if (person.age != null && person.isAlive)
                  '(${person.age} tahun)',
              ].join(' '),
            ),

          // Death info
          if (person.deathDate != null)
            _buildInfoSection(
              Icons.brightness_1,
              'Wafat',
              [
                _formatDate(person.deathDate!),
                if (person.deathPlace != null)
                  'di ${person.deathPlace}',
                if (person.age != null)
                  '(usia ${person.age} tahun)',
              ].join(' '),
              iconColor: AppColors.textTertiary,
            ),

          // Occupation
          if (person.occupation != null && person.occupation!.isNotEmpty)
            _buildInfoSection(
              Icons.work,
              'Pekerjaan',
              person.occupation!,
            ),

          // Bio
          if (person.bio != null && person.bio!.isNotEmpty) ...[
            AppSpacing.verticalMD,
            const Text(
              'Tentang',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            AppSpacing.verticalSM,
            Text(
              person.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],

          // Generation level
          AppSpacing.verticalLG,
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_tree,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Generasi',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  '${person.generationLevel + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color nodeColor) {
    const size = 80.0;

    if (person.avatarUrl != null && person.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: person.avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              _buildInitialsAvatar(nodeColor, size),
          errorWidget: (context, url, error) =>
              _buildInitialsAvatar(nodeColor, size),
        ),
      );
    }

    return _buildInitialsAvatar(nodeColor, size);
  }

  Widget _buildInitialsAvatar(Color nodeColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: nodeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          person.initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRelativeOptions(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Kerabat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.verticalMD,
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.supervisor_account, color: Colors.white),
                ),
                title: const Text('Orang Tua'),
                subtitle: const Text('Tambahkan ayah atau ibu'),
                onTap: () {
                  Navigator.pop(context);
                  onAddRelative?.call(RelationshipType.parent);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.info.withValues(alpha: 0.2),
                  child: const Icon(Icons.favorite, color: AppColors.info),
                ),
                title: const Text('Pasangan'),
                subtitle: const Text('Tambahkan suami/istri'),
                onTap: () {
                  Navigator.pop(context);
                  onAddRelative?.call(RelationshipType.spouse);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success.withValues(alpha: 0.2),
                  child: const Icon(Icons.child_care, color: AppColors.success),
                ),
                title: const Text('Anak'),
                subtitle: const Text('Tambahkan anak'),
                onTap: () {
                  Navigator.pop(context);
                  onAddRelative?.call(RelationshipType.child);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                  child: const Icon(Icons.people, color: AppColors.warning),
                ),
                title: const Text('Saudara'),
                subtitle: const Text('Tambahkan kakak/adik'),
                onTap: () {
                  Navigator.pop(context);
                  onAddRelative?.call(RelationshipType.sibling);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNodeColor(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'male':
        return AppColors.maleNode;
      case 'female':
        return AppColors.femaleNode;
      default:
        return AppColors.otherNode;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
