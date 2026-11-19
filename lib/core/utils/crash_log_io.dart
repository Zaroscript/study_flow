import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Local, bounded diagnostic metadata. Exception messages/user text are excluded.
class CrashLog {
  static File? _file;
  static Future<void> init() async {
    final dir = await getApplicationSupportDirectory();
    _file = File('${dir.path}/enote-errors.log');
  }

  @visibleForTesting
  static void useFileForTesting(File file) => _file = file;

  /// Deletes the local error log (used by "Reset all data").
  static Future<void> clear() async {
    try {
      final file = _file;
      if (file != null && await file.exists()) await file.delete();
    } catch (_) {
      /* Clearing diagnostics must never block a data reset. */
    }
  }

  static void record(Object error, StackTrace stack) {
    try {
      final file = _file;
      if (file == null) return;
      if (file.existsSync() && file.lengthSync() > 65536) {
        file.writeAsStringSync('');
      }
      file.writeAsStringSync(
        '${DateTime.now().toUtc().toIso8601String()} ${error.runtimeType}\n${stack.toString().split('\n').take(6).join('\n')}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      /* An error logger must never recursively throw. */
    }
  }
}
