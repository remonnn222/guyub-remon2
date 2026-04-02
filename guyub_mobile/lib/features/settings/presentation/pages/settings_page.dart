import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/constants/api_constants.dart';
import '../../../../config/theme/theme_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/security/biometric_service.dart';

part 'settings_page.g.dart';

/// Environment Enum
enum Environment {
  local('Lokal', ApiConstants.localUrl),
  androidEmulator('Android Emulator', ApiConstants.androidEmulatorUrl),
  production('Produksi', ApiConstants.productionUrl);

  final String label;
  final String url;
  const Environment(this.label, this.url);
}

/// Environment Notifier
@riverpod
class EnvironmentNotifier extends _$EnvironmentNotifier {
  @override
  Environment build() => Environment.local;

  void setEnvironment(Environment env) {
    state = env;
  }
}

/// Biometric Settings Notifier
@riverpod
class BiometricNotifier extends _$BiometricNotifier {
  @override
  Future<Map<String, dynamic>> build() async {
    final biometricService = sl<BiometricService>();

    return {
      'isEnabled': await biometricService.isBiometricLoginEnabled,
      'isSupported': await biometricService.isSupported,
      'isEnrolled': await biometricService.isEnrolled,
      'availableTypes': await biometricService.getAvailableBiometrics(),
    };
  }

  /// Toggle biometric login
  /// Note: Biometric can only be disabled from settings.
  /// Enabling requires going through login flow with credentials.
  Future<void> toggleBiometric(bool enable) async {
    final biometricService = sl<BiometricService>();

    // Only allow disabling biometric from settings
    if (!enable) {
      await biometricService.disableBiometricLogin();
    }
    // If trying to enable, do nothing - user must go through login flow

    // Refresh the state
    state = AsyncValue.data({
      'isEnabled': await biometricService.isBiometricLoginEnabled,
      'isSupported': await biometricService.isSupported,
      'isEnrolled': await biometricService.isEnrolled,
      'availableTypes': await biometricService.getAvailableBiometrics(),
    });
  }
}

/// Settings Page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentEnv = ref.watch(environmentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan'), centerTitle: true),
      body: ListView(
        padding: AppSpacing.paddingLG,
        children: [
          // API Environment Section
          const _SectionHeader(title: 'Koneksi Server'),
          Card(
            child: Column(
              children: Environment.values.map((env) {
                return RadioListTile<Environment>(
                  value: env,
                  groupValue: currentEnv,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(environmentProvider.notifier)
                          .setEnvironment(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Server diubah ke: ${env.label}'),
                          action: SnackBarAction(label: 'OK', onPressed: () {}),
                        ),
                      );
                    }
                  },
                  title: Text(env.label),
                  subtitle: Text(env.url, style: const TextStyle(fontSize: 12)),
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),
          AppSpacing.verticalMD,

          // Current URL Display
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                AppSpacing.horizontalSM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'URL Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        currentEnv.url,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalXL,

          // Biometric Security Section
          const _SectionHeader(title: 'Keamanan'),
          _buildBiometricSettings(context),

          AppSpacing.verticalXL,

          // App Settings Section
          const _SectionHeader(title: 'Aplikasi'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Bahasa'),
                  subtitle: const Text('Indonesia'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur akan segera hadir')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Tema'),
                  subtitle: Text(ref.watch(themeProvider).label),
                  trailing: PopupMenuButton<AppThemeMode>(
                    onSelected: (mode) {
                      ref.read(themeProvider.notifier).setThemeMode(mode);
                    },
                    itemBuilder: (context) => AppThemeMode.values.map((mode) {
                      return PopupMenuItem(
                        value: mode,
                        child: Row(
                          children: [
                            Icon(
                              mode == AppThemeMode.light
                                  ? Icons.wb_sunny
                                  : mode == AppThemeMode.dark
                                  ? Icons.nightlight_round
                                  : Icons.settings_brightness,
                              color: AppColors.primary,
                            ),
                            AppSpacing.horizontalSM,
                            Text(mode.label),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: AppSpacing.borderRadiusMd,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ref.watch(themeProvider) == AppThemeMode.light
                                ? Icons.wb_sunny
                                : ref.watch(themeProvider) == AppThemeMode.dark
                                ? Icons.nightlight_round
                                : Icons.settings_brightness,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          AppSpacing.horizontalXS,
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Cache'),
                  subtitle: const Text('Hapus data tersimpan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showClearCacheDialog(context),
                ),
              ],
            ),
          ),
          AppSpacing.verticalXL,

          // About Section
          const _SectionHeader(title: 'Tentang'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Versi Aplikasi'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Lisensi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Guyub',
                      applicationVersion: '1.0.0',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSettings(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final biometricState = ref.watch(biometricProvider);

        return biometricState.when(
          data: (biometricData) {
            final isEnabled = biometricData['isEnabled'] as bool;
            final isSupported = biometricData['isSupported'] as bool;
            final isEnrolled = biometricData['isEnrolled'] as bool;
            final availableTypes = biometricData['availableTypes'] as List;

            if (!isSupported) {
              return Card(
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fingerprint,
                        color: AppColors.textSecondary,
                      ),
                      AppSpacing.horizontalMD,
                      Expanded(
                        child: Text(
                          'Biometric tidak didukung perangkat Anda',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!isEnrolled) {
              return Card(
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint, color: AppColors.warning),
                      AppSpacing.horizontalMD,
                      Expanded(
                        child: Text(
                          'Daftar sidik jari atau Face ID di pengaturan perangkat',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Biometric is supported and enrolled
            return Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Login Biometrik'),
                    subtitle: Text(_getBiometricTypeLabel(availableTypes)),
                    value: isEnabled,
                    onChanged: (value) async {
                      await ref
                          .read(biometricProvider.notifier)
                          .toggleBiometric(!value);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !value
                                ? 'Login biometrik dinonaktifkan'
                                : 'Aktifkan login biometrik melalui proses login',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            );
          },
          loading: () => Card(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Text(
                'Error: $error',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.error),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get biometric type label based on available types
  String _getBiometricTypeLabel(List availableTypes) {
    if (availableTypes.isEmpty) {
      return 'Tidak ada biometric tersedia';
    }

    final labels = <String>[];
    for (final type in availableTypes) {
      if (type.toString().contains('fingerprint')) {
        labels.add('Sidik Jari');
      } else if (type.toString().contains('faceId')) {
        labels.add('Face ID');
      } else if (type.toString().contains('iris')) {
        labels.add('Iris');
      }
    }

    return labels.isNotEmpty ? labels.join(', ') : 'Biometric';
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cache?'),
        content: const Text(
          'Semua data tersimpan di perangkat akan dihapus. '
          'Data di server tidak akan terpengaruh.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cache clearing functionality
              // This would clear Hive boxes and local storage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache berhasil dihapus')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
