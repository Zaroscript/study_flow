import '../../../data/local/database/app_database.dart';
import 'notification_service.dart';

/// Notification intent and inbox survive process death in the application DB.
class DatabaseNotificationStorage implements INotificationStorage {
  DatabaseNotificationStorage(this.database);
  final IAppDatabase database;
  @override
  Future<String?> getString(String key) async =>
      (await database.readDocument(key))?['value'] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    await database.writeDocument(key, {'value': value});
    return true;
  }

  @override
  Future<void> clear() async {
    for (final key in [
      'studyflow_notifications_history',
      'studyflow_notifications_prefs',
      'studyflow_notifications_permission',
      'studyflow_notifications_queue',
    ]) {
      await database.writeDocument(key, {'value': null});
    }
  }
}
