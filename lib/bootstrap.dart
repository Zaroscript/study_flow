import 'package:flutter/foundation.dart';

import 'data/local/database/sqlite_database.dart';
import 'data/local/preferences/preferences_service.dart';
import 'core/utils/crash_log.dart';
import 'features/notifications/services/notification_service.dart' hide kIsWeb;
import 'features/notifications/services/native_notification_gateway.dart';
import 'features/notifications/services/notification_gateway.dart';
import 'features/notifications/services/database_notification_storage.dart';

class AppDependencies {
  AppDependencies(this.database, this.preferences, this.notifications);
  final EnoteDatabase database;
  final SharedPreferencesService preferences;
  final NotificationService notifications;
}

/// One composition root; failure leaves the store intact and exposes Retry.
Future<AppDependencies> bootstrap() async {
  await CrashLog.init();
  final preferences = SharedPreferencesService();
  await preferences.init();
  final database = EnoteDatabase();
  try {
    await database.init();
    await database.getProfile();
    NotificationGateway gateway = UnavailableNotificationGateway();
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      final native = NativeNotificationGateway();
      await native.init();
      gateway = native;
    }
    final notifications = NotificationService(
      storage: DatabaseNotificationStorage(database),
      gateway: gateway,
    );
    await notifications.init();
    return AppDependencies(database, preferences, notifications);
  } catch (_) {
    await database.close();
    rethrow;
  }
}
