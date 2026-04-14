import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/error/error_handler.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_service.dart';

void main() async {
  BindingBase.debugZoneErrorsAreFatal = false;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      bool hasStartupError = false;
      String? startupErrorMessage;
      bool firebaseInitialized = false;

      try {
        firebaseInitialized = await _tryInitializeFirebase();
      } catch (error) {
        hasStartupError = true;
        startupErrorMessage = error.toString();
        ErrorHandler.handleException(error);
      }

      if (!hasStartupError) {
        try {
          await di.init();
        } catch (error) {
          hasStartupError = true;
          startupErrorMessage = error.toString();
          ErrorHandler.handleException(error);
        }
      }

      if (hasStartupError) {
        runApp(AppInitErrorApp(message: startupErrorMessage ?? 'Terjadi kesalahan saat memulai aplikasi.'));
        return;
      }

      // Initialize global error handler first, so we can handle any future errors.
      ErrorHandler.init();

      if (firebaseInitialized) {
        ErrorHandler.crashlyticsEnabled = true;
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
          !const bool.fromEnvironment('dart.vm.product'),
        );
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      }

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize deep link service
      final deepLinkService = di.sl<DeepLinkService>();
      await deepLinkService.initialize();

      // Initialize sync service for background offline queue processing
      final syncService = di.sl<SyncService>();
      syncService.start();

      // Initialize notification service only if Firebase initialized.
      if (firebaseInitialized) {
        await NotificationService().initialize();
      } else if (kDebugMode) {
        debugPrint('Skipping NotificationService initialization because Firebase is not initialized.');
      }

      runApp(const ProviderScope(child: GuyubApp()));
    },
    (error, stackTrace) {
      // Only log errors here; do not call runApp from the error handler zone.
      ErrorHandler.handleException(error);
    },
  );
}

Future<bool> _tryInitializeFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } catch (error) {
    final errorString = error.toString();
    if (kIsWeb && errorString.contains('FirebaseOptions cannot be null')) {
      if (kDebugMode) {
        debugPrint('Firebase web config is missing; skipping Firebase initialization.');
      }
      return false;
    }
    rethrow;
  }
}

class AppInitErrorApp extends StatelessWidget {
  final String message;

  const AppInitErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guyub - Error',
      home: Scaffold(
        appBar: AppBar(title: const Text('Startup Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
