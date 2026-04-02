import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_spacing.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/change_password_usecase.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password'), centerTitle: true),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: AppSpacing.paddingLG,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildPasswordField(_currentPassword, 'Password Saat Ini', true),
              AppSpacing.verticalSM,
              _buildPasswordField(_newPassword, 'Password Baru', true),
              AppSpacing.verticalSM,
              _buildPasswordField(
                _confirmPassword,
                'Konfirmasi Password',
                true,
              ),
              AppSpacing.verticalLG,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSubmit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String label,
    bool requiredField,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (requiredField && (value == null || value.isEmpty)) {
          return '$label diperlukan';
        }

        if (label == 'Password Baru' && value != null && value.isNotEmpty) {
          if (value.length < 8) {
            return 'Password minimal 8 karakter';
          }
          if (!RegExp(r'(?=.*[A-Z])').hasMatch(value) ||
              !RegExp(r'(?=.*[a-z])').hasMatch(value)) {
            return 'Password harus menggunakan huruf besar & kecil';
          }
          if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
            return 'Password harus mengandung angka';
          }
          if (!RegExp(r'(?=.*[!@#\$%\^&*(),.?":{}|<>])').hasMatch(value)) {
            return 'Password harus mengandung simbol';
          }
        }

        if (label == 'Konfirmasi Password' && value != _newPassword.text) {
          return 'Konfirmasi password tidak sama';
        }

        return null;
      },
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final result = await sl<ChangePasswordUseCase>().call(
      ChangePasswordParams(
        currentPassword: _currentPassword.text.trim(),
        newPassword: _newPassword.text.trim(),
        confirmPassword: _confirmPassword.text.trim(),
      ),
    );

    await result.fold(
      (failure) async {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah')),
        );
        context.go(RouteNames.profile);
      },
    );

    setState(() {
      _isSaving = false;
    });
  }
}
