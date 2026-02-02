import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/entities/family.dart';
import '../../domain/repositories/family_repository.dart';
import '../providers/family_provider.dart';
import '../providers/family_state.dart';

class AddRelationshipDialog extends ConsumerStatefulWidget {
  final List<Person> persons;
  final VoidCallback? onRelationshipAdded;

  const AddRelationshipDialog({
    super.key,
    required this.persons,
    this.onRelationshipAdded,
  });

  @override
  ConsumerState<AddRelationshipDialog> createState() =>
      _AddRelationshipDialogState();
}

class _AddRelationshipDialogState extends ConsumerState<AddRelationshipDialog> {
  Person? _person1;
  Person? _person2;
  RelationshipType? _relationshipType;
  MarriageStatus? _marriageStatus;
  DateTime? _marriageDate;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(relationshipFormProvider);

    ref.listen<RelationshipFormState>(relationshipFormProvider, (prev, next) {
      if (next is RelationshipFormSuccess) {
        Navigator.pop(context);
        widget.onRelationshipAdded?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      } else if (next is RelationshipFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingSM,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.link,
                      color: AppColors.info,
                    ),
                  ),
                  AppSpacing.horizontalMD,
                  const Expanded(
                    child: Text(
                      'Buat Hubungan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              AppSpacing.verticalMD,

              const Text(
                'Pilih dua anggota keluarga dan tentukan hubungan mereka.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalLG,

              // Person 1
              _buildPersonDropdown(
                label: 'Orang Pertama',
                value: _person1,
                onChanged: (p) => setState(() => _person1 = p),
                excludeId: _person2?.id,
              ),
              AppSpacing.verticalMD,

              // Relationship type
              DropdownButtonFormField<RelationshipType>(
                value: _relationshipType,
                decoration: InputDecoration(
                  labelText: 'Hubungan',
                  prefixIcon: const Icon(Icons.family_restroom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: RelationshipType.parent,
                    child: Text('adalah ORANG TUA dari'),
                  ),
                  DropdownMenuItem(
                    value: RelationshipType.spouse,
                    child: Text('adalah PASANGAN dari'),
                  ),
                  DropdownMenuItem(
                    value: RelationshipType.sibling,
                    child: Text('adalah SAUDARA dari'),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _relationshipType = value;
                  // Reset marriage status if not spouse
                  if (value != RelationshipType.spouse) {
                    _marriageStatus = null;
                    _marriageDate = null;
                  }
                }),
              ),
              AppSpacing.verticalMD,

              // Person 2
              _buildPersonDropdown(
                label: 'Orang Kedua',
                value: _person2,
                onChanged: (p) => setState(() => _person2 = p),
                excludeId: _person1?.id,
              ),

              // Marriage details (if spouse relationship)
              if (_relationshipType == RelationshipType.spouse) ...[
                AppSpacing.verticalLG,
                const Divider(),
                AppSpacing.verticalMD,
                const Text(
                  'Detail Pernikahan (Opsional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                AppSpacing.verticalMD,

                // Marriage status
                DropdownButtonFormField<MarriageStatus>(
                  value: _marriageStatus,
                  decoration: InputDecoration(
                    labelText: 'Status Pernikahan',
                    prefixIcon: const Icon(Icons.favorite),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: MarriageStatus.married,
                      child: Text('Menikah'),
                    ),
                    DropdownMenuItem(
                      value: MarriageStatus.engaged,
                      child: Text('Bertunangan'),
                    ),
                    DropdownMenuItem(
                      value: MarriageStatus.divorced,
                      child: Text('Bercerai'),
                    ),
                    DropdownMenuItem(
                      value: MarriageStatus.widowed,
                      child: Text('Duda/Janda'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _marriageStatus = value),
                ),
                AppSpacing.verticalMD,

                // Marriage date
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pernikahan',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _marriageDate != null
                          ? _formatDate(_marriageDate!)
                          : 'Pilih tanggal',
                      style: TextStyle(
                        color: _marriageDate != null
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ],

              AppSpacing.verticalLG,

              // Preview
              if (_person1 != null &&
                  _person2 != null &&
                  _relationshipType != null)
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPersonChip(_person1!),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      _buildPersonChip(_person2!),
                    ],
                  ),
                ),
              AppSpacing.verticalLG,

              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  AppSpacing.horizontalMD,
                  Expanded(
                    child: AppButton(
                      label: 'Simpan',
                      isLoading: formState is RelationshipFormLoading,
                      onPressed: _canSubmit ? _submit : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonDropdown({
    required String label,
    required Person? value,
    required void Function(Person?) onChanged,
    int? excludeId,
  }) {
    final filteredPersons = widget.persons
        .where((p) => excludeId == null || p.id != excludeId)
        .toList();

    return DropdownButtonFormField<Person>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: filteredPersons.map((person) {
        return DropdownMenuItem(
          value: person,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getNodeColor(person.gender),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    person.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  person.fullName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildPersonChip(Person person) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getNodeColor(person.gender).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        person.firstName,
        style: TextStyle(
          color: _getNodeColor(person.gender),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  bool get _canSubmit =>
      _person1 != null && _person2 != null && _relationshipType != null;

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _marriageDate ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _marriageDate = date);
    }
  }

  void _submit() {
    if (!_canSubmit) return;

    final params = CreateRelationshipParams(
      personId: _person1!.id,
      relatedPersonId: _person2!.id,
      type: _relationshipType!,
      marriageStatus: _marriageStatus,
      marriageDate: _marriageDate,
    );

    ref.read(relationshipFormProvider.notifier).createRelationship(params);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
}
