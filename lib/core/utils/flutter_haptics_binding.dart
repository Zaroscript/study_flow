import 'package:flutter/services.dart';

import 'app_haptics.dart';

/// Binds Flutter platform HapticFeedback to the decoupled [AppHaptics] service.
void initAppHaptics() {
  AppHaptics.onSelection = () {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  };

  AppHaptics.onLight = () {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  };

  AppHaptics.onMedium = () {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  };

  AppHaptics.onMilestone = () {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  };

  AppHaptics.onRejection = () {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  };
}
