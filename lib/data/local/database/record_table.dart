import 'package:drift/drift.dart';

/// Durable model documents, scoped by kind and stable record identity.
class AppRecords extends Table {
  TextColumn get kind => text().withLength(min: 1, max: 80)();
  TextColumn get recordId => text().withLength(min: 1, max: 160)();
  TextColumn get payload => text()();
  @override
  Set<Column> get primaryKey => {kind, recordId};
  @override
  bool get isStrict => true;
  @override
  List<String> get customConstraints => ['CHECK (json_valid(payload))'];
}
