# ENote — Flutter UI/UX quality pass

## Scope and evidence

This is the native Flutter implementation under `lib/`, including its existing library, rewards, smart planner, goals and alarm features. The earlier React screenshots and bundle measurements are not Flutter evidence.

References applied: Impeccable's native audit/adaptation, Android/Material guidance, Operate mode, hardening and craft floor; UI UX Pro Max's verified Flutter accessibility guidance. Web-only Vercel and React recommendations are not used to assess Flutter performance.

## Implemented changes

- **Shared design system:** restrained violet palette, theme-aware surfaces, stronger muted text, readable type, and native Material 3 buttons with 48dp minimum targets. Buttons grow with text rather than fixing their height.
- **All screen headers:** adapt from a row to stacked heading/action layouts on narrow windows or large system text sizes.
- **Phone/tablet navigation:** native bottom navigation and modal drawer on compact windows; persistent side drawer on expanded windows. Native drawer focus, safe areas, Back behavior and keyboard insets are retained.
- **Navigation lifetime:** independent `StatefulShellRoute.indexedStack` branches retain screen state. The router now refreshes its redirect rather than being recreated on profile changes.
- **Focus sessions:** retained across tab changes, measured against a wall-clock deadline, with cancellation of previous timers before extension. Invalid durations are rejected, and settings are awaited before resetting the countdown. Alarm and XP features remain.
- **Notes:** lazy scrolling list, case-insensitive search, folder filters, full-content opening/editing, validation, loading/error feedback, unsaved-edit confirmation, controller disposal, and upsert by ID without duplicate records.
- **Deleting tasks, homework, goals, habits and notes:** native actionable SnackBar with Undo; failures report recovery guidance.
- **Forms:** native field labels, inline validation for required fields, numbers, dates and time formats; checks for end-before-start and progress-above-target. Shared scrollable bottom sheets accommodate the keyboard.
- **Dashboard/statistics:** removed fabricated weekly hours and distribution values. Completed tasks and planned minutes come from actual task records; scheduled time is explicitly distinguished from measured focus time. Library and rewards remain reachable.
- **Habit tracking:** labelled 48dp controls scroll within the weekly row on narrow phones; long habit names can wrap.
- **Library/rewards:** grids adapt to window width and text scale, rather than forcing two narrow fixed-ratio columns.
- **Goals/progress:** metadata wraps; one-percent progress is represented correctly; completed goals do not repeatedly award completion XP on subsequent taps. Progress semantics and direction-aware alignment are shared.
- **Branding:** ENote name and supplied icon on the native shell, drawer and welcome screen.
- **Reset:** invalidates cached task, homework, goal, habit, note, statistic and timer providers after clearing the repository.

## Verification

- Parsed all 70 Dart files in `lib/` and top-level Dart tests with tree-sitter-dart: **no syntax errors found**.
- Located Antigravity's Dart-only installation (Dart 3.13.7) in the WinGet packages directory. Formatted the native source and focused tests with the actual Dart formatter.
- Ran `dart --enable-asserts test/native_validators_smoke.dart`: **10 checks passed**. Ran Dart analysis on `app_validators.dart` and `note_model.dart`: **no issues found**. These checks do not exercise Flutter widgets.
- Added `test/native_ui_quality_test.dart`: validation, note upsert, narrow/large-text headers, loading buttons, progress normalization, and full-note editing flows.
- Updated the onboarding smoke test to expect ENote branding.
- Flutter SDK is unavailable in PATH and was not found in the local SDK searches. Antigravity's installation logs confirm it installed Dart, not Flutter. Attempts to obtain Flutter failed: GitHub cloning timed out and the official Windows archive URL returned HTTP 404. Therefore **Flutter analysis, compilation, widget tests, emulator screenshots, TalkBack/VoiceOver, physical-device gestures and performance have not been verified**. Syntax parsing cannot validate Flutter types, layout or runtime behavior. No native quality score or WCAG conformance claim is made.
- The native app's existing language remains Arabic. English support in the React app is a separate implementation and is not asserted for Flutter in this pass.

## Required runtime checks once Flutter is available

Requires Flutter 3.22 or later (TextScaler, modern Material color roles and WidgetState APIs).

```powershell
flutter pub get
dart format lib test/native_ui_quality_test.dart
flutter analyze
flutter test test/native_ui_quality_test.dart
flutter test
flutter devices
flutter run -d <android-device-id>
```

Review phone/tablet and portrait/landscape layouts, light/dark modes, 200% text scaling, keyboard-open forms, deletion/undo, unsaved edits, full note content, settings reset, and an active timer during navigation and background/resume. Capture native screenshots from the emulator/device, not the React preview.
