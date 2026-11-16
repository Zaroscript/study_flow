import 'package:drift/drift.dart';

class StudentProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get grade => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DailyTasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get category => text().withDefault(const Constant('study'))();
  TextColumn get startTime => text().withDefault(const Constant('09:00'))();
  TextColumn get endTime => text().withDefault(const Constant('10:00'))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get date => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class HomeworkTable extends Table {
  TextColumn get id => text()();
  TextColumn get subject => text()();
  TextColumn get description => text()();
  TextColumn get deadline => text()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get subject => text()();
  TextColumn get date => text()();
  TextColumn get time => text()();
  TextColumn get location => text().withDefault(const Constant(''))();
  TextColumn get priority => text().withDefault(const Constant('high'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get target => integer().withDefault(const Constant(10))();
  IntColumn get current => integer().withDefault(const Constant(0))();
  TextColumn get deadline => text()();
  TextColumn get color => text().withDefault(const Constant('green'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().withDefault(const Constant('Star'))();
  TextColumn get color => text().withDefault(const Constant('indigo'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get dateKey => text()(); // YYYY-MM-DD
  BoolColumn get completed => boolean().withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {habitId, dateKey},
  ];
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get folder => text().withDefault(const Constant('عام'))();
  TextColumn get date => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class StudySessions extends Table {
  TextColumn get id => text()();
  IntColumn get durationMinutes => integer()();
  TextColumn get mode => text().withDefault(const Constant('study'))();
  DateTimeColumn get completedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class WeeklySchedules extends Table {
  TextColumn get id => text()();
  IntColumn get dayOfWeek => integer()();
  TextColumn get subject => text()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();
  TextColumn get location => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
