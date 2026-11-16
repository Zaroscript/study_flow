import 'package:intl/intl.dart';

class DateFormatters {
  DateFormatters._();

  /// Formats date to Arabic full date e.g. "السبت، 14 نوفمبر 2026"
  static String formatFullDate(DateTime date) {
    try {
      return DateFormat('EEEE، d MMMM yyyy', 'ar').format(date);
    } catch (_) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// Formats date to short date e.g. "14 نوفمبر"
  static String formatShortDate(DateTime date) {
    try {
      return DateFormat('d MMMM', 'ar').format(date);
    } catch (_) {
      return '${date.day}/${date.month}';
    }
  }

  /// Formats time in Arabic 12-hour format e.g. "09:30 ص"
  static String formatTime(DateTime date) {
    try {
      return DateFormat('hh:mm a', 'ar').format(date);
    } catch (_) {
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final period = date.hour >= 12 ? 'م' : 'ص';
      return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Formats seconds to mm:ss for Pomodoro timer
  static String formatPomodoroTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
