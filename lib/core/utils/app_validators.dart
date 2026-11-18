class AppValidators {
  AppValidators._();
  static int? parseInt(String input) => int.tryParse(normalize(input.trim()));
  static String normalize(String input) => String.fromCharCodes(
    input.runes.map(
      (r) => r >= 0x0660 && r <= 0x0669
          ? r - 0x0660 + 48
          : r >= 0x06f0 && r <= 0x06f9
          ? r - 0x06f0 + 48
          : r,
    ),
  ).replaceAll('٫', '.').replaceAll('٬', '');
  static String? required(String? value) =>
      value == null || value.trim().isEmpty ? 'هذا الحقل مطلوب' : null;
  static String? integer(String? value, {int min = 0, int max = 1000000}) {
    final number = parseInt(value ?? '');
    return number == null || number < min || number > max
        ? 'أدخل عددًا صحيحًا بين $min و$max'
        : null;
  }

  static String? time(String? value) =>
      RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(normalize(value ?? ''))
      ? null
      : 'استخدم وقتًا صالحًا مثل 09:30';
  static String? date(String? value) {
    final text = normalize(value?.trim() ?? '');
    final parsed = DateTime.tryParse(text);
    return parsed != null && parsed.toIso8601String().split('T').first == text
        ? null
        : 'اختر تاريخًا صالحًا بصيغة YYYY-MM-DD';
  }

  static bool validTimeRange(String start, String end) =>
      time(start) == null &&
      time(end) == null &&
      normalize(start).compareTo(normalize(end)) < 0;
}
