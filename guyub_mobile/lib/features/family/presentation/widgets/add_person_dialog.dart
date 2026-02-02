import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/repositories/family_repository.dart';
import '../providers/family_provider.dart';
import '../providers/family_state.dart';

class AddPersonDialog extends ConsumerStatefulWidget {
  final int familyId;
  final VoidCallback? onPersonAdded;

  const AddPersonDialog({
    super.key,
    required this.familyId,
    this.onPersonAdded,
  });

  @override
  ConsumerState<AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends ConsumerState<AddPersonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedGender;
  DateTime? _birthDate;
  DateTime? _deathDate;
  bool _isDeceased = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _occupationController.dispose();
    _birthPlaceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(personFormProvider);

    ref.listen<PersonFormState>(personFormProvider, (prev, next) {
      if (next is PersonFormSuccess) {
        Navigator.pop(context);
        widget.onPersonAdded?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      } else if (next is PersonFormError) {
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
          child: Form(
            key: _formKey,
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
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.horizontalMD,
                    const Expanded(
                      child: Text(
                        'Tambah Anggota Keluarga',
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
                AppSpacing.verticalLG,

                // First name
                AppTextField(
                  controller: _firstNameController,
                  label: 'Nama Depan',
                  hint: 'Masukkan nama depan',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama depan wajib diisi';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalMD,

                // Last name
                AppTextField(
                  controller: _lastNameController,
                  label: 'Nama Belakang (Opsional)',
                  hint: 'Masukkan nama belakang',
                  prefixIcon: Icons.badge,
                ),
                AppSpacing.verticalMD,

                // Gender
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: const Icon(Icons.wc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                    DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                    DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) {
                    if (value == null) {
                      return 'Pilih jenis kelamin';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalMD,

                // Birth date
                _buildDateField(
                  label: 'Tanggal Lahir (Opsional)',
                  value: _birthDate,
                  onTap: () => _selectDate(
                    context,
                    _birthDate,
                    (date) => setState(() => _birthDate = date),
                  ),
                ),
                AppSpacing.verticalMD,

                // Birth place
                AppTextField(
                  controller: _birthPlaceController,
                  label: 'Tempat Lahir (Opsional)',
                  hint: 'Masukkan tempat lahir',
                  prefixIcon: Icons.location_on,
                ),
                AppSpacing.verticalMD,

                // Deceased toggle
                SwitchListTile(
                  title: const Text('Sudah Meninggal'),
                  value: _isDeceased,
                  onChanged: (value) => setState(() => _isDeceased = value),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),

                // Death date (if deceased)
                if (_isDeceased) ...[
                  AppSpacing.verticalSM,
                  _buildDateField(
                    label: 'Tanggal Wafat',
                    value: _deathDate,
                    onTap: () => _selectDate(
                      context,
                      _deathDate,
                      (date) => setState(() => _deathDate = date),
                    ),
                  ),
                ],
                AppSpacing.verticalMD,

                // Occupation
                AppTextField(
                  controller: _occupationController,
                  label: 'Pekerjaan (Opsional)',
                  hint: 'Masukkan pekerjaan',
                  prefixIcon: Icons.work,
                ),
                AppSpacing.verticalMD,

                // Bio
                AppTextField(
                  controller: _bioController,
                  label: 'Tentang (Opsional)',
                  hint: 'Ceritakan tentang orang ini...',
                  prefixIcon: Icons.notes,
                  maxLines: 3,
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
                        isLoading: formState is PersonFormLoading,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          value != null ? _formatDate(value) : 'Pilih tanggal',
          style: TextStyle(
            color: value != null
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    void Function(DateTime) onSelected,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
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
      onSelected(date);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final params = CreatePersonParams(
      familyId: widget.familyId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      gender: _selectedGender,
      birthDate: _birthDate,
      deathDate: _isDeceased ? _deathDate : null,
      birthPlace: _birthPlaceController.text.trim().isEmpty
          ? null
          : _birthPlaceController.text.trim(),
      occupation: _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
    );

    ref.read(personFormProvider.notifier).createPerson(params);
  }
}
