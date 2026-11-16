class CategoryConstants {
  CategoryConstants._();

  static const Map<String, String> categoryLabelsAr = {
    'study': 'دراسة',
    'school': 'مدرسة',
    'lesson': 'درس خصوصي',
    'homework': 'واجبات',
    'sleep': 'نوم',
    'exercise': 'رياضة',
    'meal': 'طعام',
    'reading': 'قراءة',
    'break': 'استراحة',
    'personal': 'شخصي',
  };

  static String getLabel(String key) {
    return categoryLabelsAr[key] ?? key;
  }
}
