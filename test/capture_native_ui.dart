// Run explicitly: flutter test test/capture_native_ui.dart --concurrency=1
// Captures real Flutter widgets with bundled fonts; not a device screenshot.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_flow/main.dart';
import 'package:study_flow/core/router/app_router.dart';
import 'package:study_flow/data/local/preferences/preferences_service.dart';
import 'package:study_flow/data/repositories/in_memory_study_flow_repository.dart';
import 'package:study_flow/features/common/providers/study_flow_state_provider.dart';

void main() {
  for (final language in ['ar', 'en']) {
    for (final theme in ['light', 'dark']) {
      for (final largeText in [false, true]) {
        testWidgets(
          '$language/$theme/${largeText ? 'large' : 'normal'} native screens',
          (tester) async {
            tester.view.physicalSize = const Size(390, 844);
            tester.view.devicePixelRatio = 1;
            tester.platformDispatcher.textScaleFactorTestValue = largeText
                ? 2
                : 1;
            tester.platformDispatcher.accessibilityFeaturesTestValue =
                const FakeAccessibilityFeatures(disableAnimations: true);
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            addTearDown(
              tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
            );
            final font = FontLoader('Cairo')
              ..addFont(rootBundle.load('assets/fonts/Cairo.ttf'));
            await font.load();
            SharedPreferences.setMockInitialValues({
              'enote_locale': language,
              'studyflow_theme_mode': theme,
              'studyflow_onboarding_completed': true,
            });
            final prefs = SharedPreferencesService();
            await prefs.init();
            final container = ProviderContainer(
              overrides: [
                preferencesServiceProvider.overrideWithValue(prefs),
                studyFlowRepositoryProvider.overrideWithValue(
                  InMemoryStudyFlowRepository(),
                ),
              ],
            );
            addTearDown(container.dispose);
            final boundary = GlobalKey();
            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: RepaintBoundary(
                  key: boundary,
                  child: const StudyFlowApp(),
                ),
              ),
            );
            await tester.pumpAndSettle();
            // Collect every layout error (with its source location) across all
            // routes instead of stopping at the first one.
            final issues = <String>[];
            var currentRoute = '';
            final originalOnError = FlutterError.onError;
            FlutterError.onError = (details) => issues.add(
              '$currentRoute: ${details.toString().split('\n').take(12).join('\n')}',
            );
            for (final route in [
              'dashboard',
              'planner',
              'pomodoro',
              'homework',
              'goals',
              'habits',
              'notes',
              'materials',
              'rewards',
              'ai-assistant',
              'notifications',
              'settings',
              'settings/profile',
            ]) {
              currentRoute = route;
              container.read(appRouterProvider).go('/$route');
              await tester.pumpAndSettle();
              final thrown = tester.takeException();
              if (thrown != null) issues.add('$route: $thrown');
              final render =
                  boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              await tester.runAsync(() async {
                final image = await render.toImage(pixelRatio: 1);
                final bytes = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                image.dispose();
                final directory = Directory('screenshots/flutter');
                await directory.create(recursive: true);
                await File(
                  '${directory.path}/$language-$theme-${largeText ? '200' : '100'}-${route.replaceAll('/', '-')}.png',
                ).writeAsBytes(bytes!.buffer.asUint8List());
              });
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
            FlutterError.onError = originalOnError;
            expect(
              issues,
              isEmpty,
              reason:
                  '$language/$theme/large=$largeText\n${issues.join('\n---\n')}',
            );
          },
        );
      }
    }
  }
}
