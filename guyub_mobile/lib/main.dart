import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/error/error_handler.dart';

void main() async {
  // Wrap in runZonedGuarded for additional error catching
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

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

      // Initialize Hive for local storage
      await Hive.initFlutter();

      // Initialize dependency injection
      await di.init();

      runApp(
        const ProviderScope(
          child: GuyubApp(),
        ),
      );
    },
    (error, stackTrace) {
      // Catch any errors that escape the Flutter framework
      ErrorHandler.handleException(error);
    },
  );
}
