class NoteModel {
  final String id;
  final String title;
  final String content;
  final String folder;
  final String date;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.folder = 'عام',
    required this.date,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? folder,
    String? date,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      folder: folder ?? this.folder,
      date: date ?? this.date,
    );
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      folder: json['folder'] as String? ?? 'عام',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'folder': folder,
      'date': date,
    };
  }
}
