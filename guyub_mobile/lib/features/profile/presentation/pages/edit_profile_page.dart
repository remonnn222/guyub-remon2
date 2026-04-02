import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/image_service.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _pickedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil'), centerTitle: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAvatar(user),
                AppSpacing.verticalMD,
                _buildTextField(
                  _nameController,
                  'Nama',
                  'Masukkan nama lengkap',
                  true,
                ),
                AppSpacing.verticalSM,
                _buildTextField(
                  _emailController,
                  'Email',
                  null,
                  false,
                  readOnly: true,
                ),
                AppSpacing.verticalSM,
                _buildTextField(_phoneController, 'Telepon', 'Opsional', false),
                AppSpacing.verticalLG,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveProfile(user),
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
      ),
    );
  }

  Widget _buildAvatar(User? user) {
    final avatarUrl = _pickedImage != null ? null : user?.avatarUrl;

    final avatarWidget = _pickedImage != null
        ? CircleAvatar(radius: 56, backgroundImage: FileImage(_pickedImage!))
        : (avatarUrl != null && avatarUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: avatarUrl,
                  imageBuilder: (context, imageProvider) =>
                      CircleAvatar(radius: 56, backgroundImage: imageProvider),
                  placeholder: (context, url) => const CircleAvatar(
                    radius: 56,
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => _initialsAvatar(user),
                )
              : _initialsAvatar(user));

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            avatarWidget,
            InkWell(
              onTap: _showImageSourcePicker,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSM,
        const Text('Ketuk ikon untuk ganti foto'),
      ],
    );
  }

  Widget _initialsAvatar(User? user) {
    final initials = user?.initials ?? 'U';
    return CircleAvatar(
      radius: 56,
      backgroundColor: AppColors.primary,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? hint,
    bool requiredField, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil dari Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final imageService = sl<ImageService>();
    final picked = await imageService.pickCropAndCompress(source: source);

    if (picked != null) {
      setState(() {
        _pickedImage = picked;
      });
    }
  }

  Future<void> _saveProfile(User? user) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendapatkan data pengguna')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? avatarUrl = user.avatarUrl;
      if (_pickedImage != null) {
        final uploadResult = await sl<UploadAvatarUseCase>().call(
          UploadAvatarParams(file: _pickedImage!, userId: user.id),
        );
        await uploadResult.fold(
          (failure) {
            throw Exception(failure.message);
          },
          (url) {
            avatarUrl = url;
          },
        );
      }

      final profileResult = await sl<EditProfileUseCase>().call(
        EditProfileParams(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        ),
      );

      await profileResult.fold(
        (failure) async {
          throw Exception(failure.message);
        },
        (updatedUser) async {
          final mergedUser = updatedUser.copyWith(avatarUrl: avatarUrl);
          ref.read(authProvider.notifier).updateUser(mergedUser);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui')),
          );
          context.go(RouteNames.profile);
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
