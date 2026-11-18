import 'package:material_ui/material_ui.dart';
import 'package:study_flow/l10n/app_localizations.dart';

Widget testApp({required Widget home, String language = 'ar'}) => MaterialApp(
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: home,
);
