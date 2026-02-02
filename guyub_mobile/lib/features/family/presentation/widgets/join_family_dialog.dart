import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';

class JoinFamilyDialog extends StatefulWidget {
  final void Function(String inviteCode) onJoin;

  const JoinFamilyDialog({
    super.key,
    required this.onJoin,
  });

  @override
  State<JoinFamilyDialog> createState() => _JoinFamilyDialogState();
}

class _JoinFamilyDialogState extends State<JoinFamilyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
                      color: AppColors.info.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.group_add,
                      color: AppColors.info,
                    ),
                  ),
                  AppSpacing.horizontalMD,
                  const Expanded(
                    child: Text(
                      'Gabung Keluarga',
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

              // Description
              const Text(
                'Masukkan kode undangan yang Anda terima dari anggota keluarga.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalLG,

              // Invite code input
              AppTextField(
                controller: _codeController,
                label: 'Kode Undangan',
                hint: 'Contoh: ABC123',
                prefixIcon: Icons.key,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode undangan wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Kode undangan minimal 6 karakter';
                  }
                  return null;
                },
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
                      label: 'Gabung',
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
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    widget.onJoin(_codeController.text.trim().toUpperCase());
    Navigator.pop(context);
  }
}
