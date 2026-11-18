import 'dart:ui';

import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
import 'bootstrap.dart';
import 'core/utils/crash_log.dart';
import 'features/notifications/providers/notifications_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/flutter_haptics_binding.dart';
import 'features/common/providers/study_flow_state_provider.dart';
import 'features/common/providers/theme_provider.dart';

final appMessengerKey = GlobalKey<ScaffoldMessengerState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    CrashLog.record(details.exception, details.stack ?? StackTrace.current);
    if (kDebugMode) FlutterError.presentError(details);
    _showOperationError();
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    CrashLog.record(error, stack);
    _showOperationError();
    return true;
  };
  initAppHaptics();
  runApp(const BootstrapApp());
}

void _showOperationError() {
  final messenger = appMessengerKey.currentState;
  if (messenger != null) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'تعذّر إتمام العملية. حاول مرة أخرى. / Could not complete the operation. Please retry.',
        ),
      ),
    );
  }
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key});
  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp>
    with WidgetsBindingObserver {
  late Future<AppDependencies> _future;
  AppDependencies? _dependencies;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _future = _load();
  }

  Future<AppDependencies> _load() async {
    final deps = await bootstrap();
    _dependencies = deps;
    return deps;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _dependencies?.notifications.syncNotifications().catchError((
        Object e,
        StackTrace s,
      ) {
        CrashLog.record(e, s);
        _showOperationError();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dependencies?.database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppDependencies>(
    future: _future,
    builder: (context, snapshot) {
      final deps = snapshot.data;
      if (deps != null) {
        return ProviderScope(
          overrides: [
            preferencesServiceProvider.overrideWithValue(deps.preferences),
            appDatabaseProvider.overrideWithValue(deps.database),
            notificationServiceProvider.overrideWithValue(deps.notifications),
          ],
          child: const StudyFlowApp(),
        );
      }
      return MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'تعذّر فتح بياناتك. لم نحذف أي بيانات. / Unable to open your data. Nothing was deleted.',
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () => setState(() => _future = _load()),
                            child: const Text('إعادة المحاولة / Retry'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class StudyFlowApp extends ConsumerWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      scaffoldMessengerKey: appMessengerKey,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
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
