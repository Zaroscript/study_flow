import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/flutter_haptics_binding.dart';
import 'data/local/preferences/preferences_service.dart';
import 'features/common/providers/study_flow_state_provider.dart';
import 'features/common/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Production Error Netting: Catch build errors and async platform errors gracefully
  FlutterError.onError = (FlutterErrorDetails details) {
    try {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('[FlutterError] ${details.exceptionAsString()}');
      }
    } catch (_) {}
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    try {
      if (kDebugMode) {
        debugPrint('[PlatformDispatcher.onError] $error\n$stack');
      }
    } catch (_) {}
    return true; // Prevent app hard crash
  };

  initAppHaptics();

  // Initialize preferences before launching the widget tree to prevent theme flickering
  final prefsService = SharedPreferencesService();
  await prefsService.init();

  runApp(
    ProviderScope(
      overrides: [preferencesServiceProvider.overrideWithValue(prefsService)],
      child: const StudyFlowApp(),
    ),
  );
}

class StudyFlowApp extends ConsumerWidget {
  const StudyFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
