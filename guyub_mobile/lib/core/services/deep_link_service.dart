import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/family/domain/repositories/family_repository.dart';

/// Deep Link Service
/// Handles deep linking for the app
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;

  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Uri? _pendingDeepLink;

  /// Initialize deep link handling
  Future<void> initialize() async {
    // Handle initial link if app was opened from a link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    // Listen for incoming links
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) {
        debugPrint('Error handling deep link: $err');
      },
    );
  }

  /// Handle deep link URI
  void _handleDeepLink(Uri uri) {
    debugPrint('Handling deep link: $uri');
    _pendingDeepLink = uri;
  }

  /// Get pending deep link and clear it
  Uri? getAndClearPendingDeepLink() {
    final link = _pendingDeepLink;
    _pendingDeepLink = null;
    return link;
  }

  /// Check if there's a pending deep link
  bool hasPendingDeepLink() => _pendingDeepLink != null;

  /// Navigate to deep link destination
  void navigateToDeepLink(BuildContext context, Uri uri) {
    final path = uri.path;
    final queryParams = uri.queryParameters;

    debugPrint('Navigating to deep link: $path');

    if (path.startsWith('/family/')) {
      // Family tree page: /family/{invite_code}
      final inviteCode = path.split('/').last;
      if (inviteCode.isNotEmpty) {
        context.go('/family/$inviteCode');
      }
    } else if (path.startsWith('/event/')) {
      // Event detail page: /event/{event_id}
      final eventId = path.split('/').last;
      if (eventId.isNotEmpty) {
        context.go('/event/$eventId');
      }
    } else if (path == '/invite') {
      // Join family dialog: /invite/{code}
      final code = queryParams['code'];
      if (code != null && code.isNotEmpty) {
        _showJoinFamilyDialog(context, code);
      }
    } else if (path == '/login') {
      // Login page
      context.go('/login');
    } else {
      // Unknown path - go to dashboard
      context.go('/dashboard');
    }
  }

  /// Show join family dialog
  void _showJoinFamilyDialog(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bergabung ke Keluarga'),
        content: Text(
          'Apakah Anda ingin bergabung ke keluarga dengan kode undangan: $inviteCode?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _joinFamily(context, inviteCode);
            },
            child: const Text('Bergabung'),
          ),
        ],
      ),
    );
  }

  /// Join family logic
  Future<void> _joinFamily(BuildContext context, String inviteCode) async {
    try {
      final familyRepository = sl<FamilyRepository>();
      final result = await familyRepository.joinFamily(inviteCode);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal bergabung: ${failure.message}')),
          );
        },
        (family) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil bergabung ke keluarga ${family.name}'),
            ),
          );
          context.go('/families/${family.id}');
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
