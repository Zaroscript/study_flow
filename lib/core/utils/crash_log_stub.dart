class CrashLog {
  static Future<void> init() async {}
  static Future<void> clear() async {}
  static void record(Object error, StackTrace stack) {}
}
