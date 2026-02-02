import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/repositories/family_repository.dart';

class CreateFamilyDialog extends StatefulWidget {
  final void Function(CreateFamilyParams params) onCreated;

  const CreateFamilyDialog({
    super.key,
    required this.onCreated,
  });

  @override
  State<CreateFamilyDialog> createState() => _CreateFamilyDialogState();
}

class _CreateFamilyDialogState extends State<CreateFamilyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originController = TextEditingController();
  bool _isPublic = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _originController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        Icons.family_restroom,
                        color: AppColors.primary,
                      ),
                    ),
                    AppSpacing.horizontalMD,
                    const Expanded(
                      child: Text(
                        'Buat Keluarga Baru',
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

                // Family name
                AppTextField(
                  controller: _nameController,
                  label: 'Nama Keluarga',
                  hint: 'Contoh: Keluarga Besar Kusuma',
                  prefixIcon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama keluarga wajib diisi';
                    }
                    if (value.length < 3) {
                      return 'Minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                AppSpacing.verticalMD,

                // Description
                AppTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi (Opsional)',
                  hint: 'Ceritakan tentang keluarga ini...',
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                AppSpacing.verticalMD,

                // Origin
                AppTextField(
                  controller: _originController,
                  label: 'Asal Daerah (Opsional)',
                  hint: 'Contoh: Yogyakarta',
                  prefixIcon: Icons.location_on,
                ),
                AppSpacing.verticalMD,

                // Public toggle
                SwitchListTile(
                  title: const Text('Keluarga Publik'),
                  subtitle: const Text(
                    'Pohon keluarga dapat dilihat oleh semua orang',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isPublic,
                  onChanged: (value) => setState(() => _isPublic = value),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
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
                        label: 'Buat',
                        isLoading: _isLoading,
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final params = CreateFamilyParams(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      origin: _originController.text.trim().isEmpty
          ? null
          : _originController.text.trim(),
      isPublic: _isPublic,
    );

    widget.onCreated(params);
    Navigator.pop(context);
  }
}
