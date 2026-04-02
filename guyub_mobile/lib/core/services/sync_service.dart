import 'dart:async';

import '../network/network_info.dart';
import '../../features/family/domain/repositories/family_repository.dart';

class SyncService {
  final NetworkInfo networkInfo;
  final FamilyRepository familyRepository;

  StreamSubscription<bool>? _connectivitySubscription;

  SyncService({required this.networkInfo, required this.familyRepository});

  void start() {
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen(
      (isOnline) async {
        if (!isOnline) return;

        // Trigger offline queue processing whenever device regains connectivity.
        await _processOfflineQueue();
      },
      onError: (_) {
        // Ignore connectivity stream errors; it will retry on next event.
      },
    );

    // Initial sync attempt if already online
    _tryInitialSync();
  }

  Future<void> _tryInitialSync() async {
    final connected = await networkInfo.isConnected;
    if (connected) {
      await _processOfflineQueue();
    }
  }

  Future<void> _processOfflineQueue() async {
    for (var attempt = 0; attempt < 3; attempt++) {
      await Future.delayed(Duration(seconds: 1 << attempt));

      final result = await familyRepository.syncOfflineData();
      if (result.isRight()) {
        // Sync succeeded, stop retrying
        break;
      }

      // keep retrying till max attempts
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
