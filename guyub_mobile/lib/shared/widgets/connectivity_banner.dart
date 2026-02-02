import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../config/theme/app_colors.dart';
import '../../core/network/network_info.dart';
import '../../core/di/injection_container.dart';

part 'connectivity_banner.g.dart';

/// Connectivity State Provider
@riverpod
Stream<bool> connectivity(Ref ref) {
  final networkInfo = sl<NetworkInfo>();
  return networkInfo.onConnectivityChanged;
}

/// Connectivity Banner Widget
/// Shows a banner when the device is offline
class ConnectivityBanner extends ConsumerWidget {
  final Widget child;
  final bool showBanner;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.showBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return Column(
      children: [
        if (showBanner)
          connectivityAsync.when(
            data: (isConnected) {
              if (!isConnected) {
                return _OfflineBanner();
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        Expanded(child: child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning,
      child: const SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Tidak ada koneksi internet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Connectivity-aware wrapper
/// Provides offline indicator and can disable interactions when offline
class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool disableWhenOffline;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    this.offlineWidget,
    this.disableWhenOffline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (isConnected) {
        if (!isConnected && offlineWidget != null) {
          return offlineWidget!;
        }
        if (!isConnected && disableWhenOffline) {
          return AbsorbPointer(
            absorbing: true,
            child: Opacity(
              opacity: 0.5,
              child: child,
            ),
          );
        }
        return child;
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
