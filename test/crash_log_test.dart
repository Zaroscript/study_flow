import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/utils/crash_log_io.dart';

void main() {
  test('Reset all data can delete the local error log, and logging works again afterwards', () async {
    final dir = await Directory.systemTemp.createTemp('enote_crash_log');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/enote-errors.log');
    CrashLog.useFileForTesting(file);

    CrashLog.record(StateError('private note text'), StackTrace.current);
    expect(file.existsSync(), isTrue);
    expect(
      file.readAsStringSync(),
      isNot(contains('private note text')),
      reason: 'only the error type is logged',
    );

    await CrashLog.clear();
    expect(file.existsSync(), isFalse);

    await CrashLog.clear(); // clearing twice must not throw
    CrashLog.record(ArgumentError('x'), StackTrace.current);
    expect(file.existsSync(), isTrue);
  });
}
