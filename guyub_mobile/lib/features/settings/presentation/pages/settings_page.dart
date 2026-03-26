import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/constants/api_constants.dart';
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

/// Settings Page
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Future<
    (
      bool isSupported,
      bool isEnabled,
      List<AppBiometricType> biometrics,
      bool hasCredentials,
    )
  >
  _biometricSettingsFuture;

  @override
  void initState() {
    super.initState();
    _biometricSettingsFuture = _loadBiometricSettings();
  }

  Future<
    (
      bool isSupported,
      bool isEnabled,
      List<AppBiometricType> biometrics,
      bool hasCredentials,
    )
  >
  _loadBiometricSettings() async {
    final biometricService = sl<BiometricService>();
    final results = await Future.wait([
      biometricService.isSupported,
      biometricService.isBiometricLoginEnabled,
      biometricService.getAvailableBiometrics(),
      biometricService.hasBiometricCredentials(),
    ]);
    return (
      results[0] as bool,
      results[1] as bool,
      results[2] as List<AppBiometricType>,
      results[3] as bool,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  subtitle: const Text('Terang'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur akan segera hadir')),
                    );
                  },
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

          // Biometric Settings Section
          const _SectionHeader(title: 'Keamanan'),
          Card(
            child:
                FutureBuilder<
                  (
                    bool isSupported,
                    bool isEnabled,
                    List<AppBiometricType> biometrics,
                    bool hasCredentials,
                  )
                >(
                  future: _biometricSettingsFuture,
                  builder: (context, snapshot) {
                    final isSupported = snapshot.data?.$1 ?? false;
                    final isEnabled = snapshot.data?.$2 ?? false;
                    final biometrics = snapshot.data?.$3 ?? [];
                    final hasCredentials = snapshot.data?.$4 ?? false;

                    final biometricNames = biometrics
                        .map((b) {
                          switch (b) {
                            case AppBiometricType.fingerprint:
                              return 'Sidik Jari';
                            case AppBiometricType.faceId:
                              return 'Face ID';
                            case AppBiometricType.iris:
                              return 'Iris';
                            default:
                              return 'Biometrik';
                          }
                        })
                        .join(', ');

                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.fingerprint),
                          title: const Text('Login Biometrik'),
                          subtitle: Text(
                            isSupported
                                ? (isEnabled
                                      ? 'Diaktifkan'
                                      : hasCredentials
                                      ? 'Dinonaktifkan'
                                      : 'Belum diatur - login dulu')
                                : 'Tidak didukung perangkat',
                          ),
                          trailing: isSupported && hasCredentials
                              ? Switch(
                                  value: isEnabled,
                                  onChanged: (value) async {
                                    final biometricService =
                                        sl<BiometricService>();
                                    if (value) {
                                      // Enable biometric
                                      final result = await biometricService
                                          .authenticate(
                                            reason: 'Aktifkan login biometrik',
                                          );
                                      if (result.isSuccess) {
                                        // Enable biometric login (credentials already exist)
                                        await biometricService
                                            .enableBiometricLoginFromExisting();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Login biometrik diaktifkan',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Disable biometric
                                      await biometricService
                                          .disableBiometricLogin();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Login biometrik dinonaktifkan',
                                          ),
                                        ),
                                      );
                                    }
                                    setState(() {
                                      _biometricSettingsFuture =
                                          _loadBiometricSettings();
                                    }); // Refresh UI
                                  },
                                  activeColor: AppColors.primary,
                                )
                              : isSupported && !hasCredentials
                              ? const Icon(
                                  Icons.info_outline,
                                  color: AppColors.textSecondary,
                                )
                              : const Icon(
                                  Icons.block,
                                  color: AppColors.textSecondary,
                                ),
                        ),
                        if (isSupported) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('Tipe Biometrik'),
                            subtitle: Text(
                              biometricNames.isNotEmpty
                                  ? biometricNames
                                  : 'Tidak tersedia',
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
          ),

          AppSpacing.verticalXL,
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
              // TODO: Clear cache
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
