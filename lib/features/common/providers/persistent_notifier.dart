import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serializes mutations after hydration and publishes only a committed value.
abstract class PersistentNotifier<T> extends StateNotifier<T> {
  PersistentNotifier(super.initial, Future<T> Function() load) {
    _loaded = load();
    unawaited(
      _loaded
          .then((value) {
            if (mounted) state = value;
          })
          .catchError(reportStorageFailure),
    );
  }
  late final Future<T> _loaded;
  Future<void> _pending = Future.value();
  Future<void> flush() => _pending;

  Future<void> change(Future<T> Function(T current) operation) {
    final next = _pending.then((_) async {
      await _loaded;
      if (!mounted) return;
      final committed = await operation(state);
      if (mounted) state = committed;
    });
    // Keep the queue usable after one failure. The caller still receives failure.
    _pending = next.catchError(reportStorageFailure);
    return next;
  }
}

/// Uses the app-owned error net; never reports user content to another service.
void reportStorageFailure(Object error, StackTrace stack) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'ENote storage',
    ),
  );
}
