typedef HapticAction = void Function();

/// Centralized haptic feedback service adhering to the `motion-and-haptics` skill.
///
/// Designed as a decoupled, pure Dart service so that domain notifiers,
/// state services, and standalone unit tests can execute with 100% safety
/// without requiring a Flutter engine binary.
///
/// Flutter binds to this service via [initAppHaptics].
class AppHaptics {
  AppHaptics._();

  /// Master in-app toggle for haptic feedback
  static bool isEnabled = true;

  /// Hookable actions wired by Flutter engine on app startup
  static HapticAction? onSelection;
  static HapticAction? onLight;
  static HapticAction? onMedium;
  static HapticAction? onMilestone;
  static HapticAction? onRejection;

  /// Lightweight tap acknowledgment for tab/filter switching or mode selection
  static void selection() {
    if (!isEnabled) return;
    onSelection?.call();
  }

  /// Light impact for task toggle, quick checkboxes, chip selection
  static void light() {
    if (!isEnabled) return;
    onLight?.call();
  }

  /// Medium impact for committing meaningful progress: habit completion, goal step
  static void medium() {
    if (!isEnabled) return;
    onMedium?.call();
  }

  /// Heavy impact reserved for major academic milestones: level-up, badge unlock, 100% goal
  static void milestone() {
    if (!isEnabled) return;
    onMilestone?.call();
  }

  /// Subtle vibration for errors / invalid inputs without punishing the user
  static void rejection() {
    if (!isEnabled) return;
    onRejection?.call();
  }

  /// Ergonomic aliases
  static void selectionClick() => selection();
  static void lightImpact() => light();
  static void mediumImpact() => medium();
  static void heavyImpact() => milestone();
}
