import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  // Wrap in runZonedGuarded for additional error catching
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !const bool.fromEnvironment('dart.vm.product'),
      );
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Initialize global error handler
      ErrorHandler.init();

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

      // Initialize dependency injection
      await di.init();

      // Initialize deep link service
      final deepLinkService = di.sl<DeepLinkService>();
      await deepLinkService.initialize();

      // Initialize sync service for background offline queue processing
      final syncService = di.sl<SyncService>();
      syncService.start();

      // Initialize notification service
      await NotificationService().initialize();

      runApp(const ProviderScope(child: GuyubApp()));
    },
    (error, stackTrace) {
      // Catch any errors that escape the Flutter framework
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
      ErrorHandler.handleException(error);
    },
  );
}
