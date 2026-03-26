import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guyub_mobile/core/di/injection_container.dart';
import 'package:guyub_mobile/core/storage/secure_storage.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';

/// Guyub App Root Widget
class GuyubApp extends ConsumerStatefulWidget {
  const GuyubApp({super.key});

  @override
  ConsumerState<GuyubApp> createState() => _GuyubAppState();
}

class _GuyubAppState extends ConsumerState<GuyubApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // If user did not choose "Remember Me", clear tokens when app is closed.
    if (state == AppLifecycleState.detached) {
      _clearTokensIfNotRemembered();
    }
  }

  Future<void> _clearTokensIfNotRemembered() async {
    final storage = sl<SecureStorageService>();
    final rememberMe = await storage.getRememberMe();
    if (!rememberMe) {
      await storage.clearAuthData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Guyub',
          debugShowCheckedModeBanner: false,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light, // TODO: Add theme mode provider
          // Router
          routerConfig: router,
        );
      },
    );
  }
}
