class MaterialFolder {
  final String id;
  final String name; // e.g. رياضيات, فيزياء, كيمياء
  final String color; // hex or category color identifier
  final String icon; // Icon name e.g. Book, Calculate, Science
  final int filesCount;

  const MaterialFolder({
    required this.id,
    required this.name,
    this.color = 'indigo',
    this.icon = 'Book',
    this.filesCount = 0,
  });

  MaterialFolder copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    int? filesCount,
  }) {
    return MaterialFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      filesCount: filesCount ?? this.filesCount,
    );
  }

  factory MaterialFolder.fromJson(Map<String, dynamic> json) {
    return MaterialFolder(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? 'indigo',
      icon: json['icon'] as String? ?? 'Book',
      filesCount: (json['filesCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'filesCount': filesCount,
    };
  }
}

enum MaterialType { pdf, book, summary, examBank, note }

class MaterialItem {
  final String id;
  final String folderId;
  final String subject;
  final String title;
  final MaterialType type;
  final String fileUrl; // Local path or web link
  final int totalPages;
  final int readPages;
  final String description;
  final String dateAdded;

  const MaterialItem({
    required this.id,
    required this.folderId,
    required this.subject,
    required this.title,
    this.type = MaterialType.pdf,
    this.fileUrl = '',
    this.totalPages = 0,
    this.readPages = 0,
    this.description = '',
    required this.dateAdded,
  });

  double get readingProgress {
    if (totalPages <= 0) return 0.0;
    return (readPages / totalPages).clamp(0.0, 1.0);
  }

  int get readingPercentage {
    return (readingProgress * 100).round();
  }

  MaterialItem copyWith({
    String? id,
    String? folderId,
    String? subject,
    String? title,
    MaterialType? type,
    String? fileUrl,
    int? totalPages,
    int? readPages,
    String? description,
    String? dateAdded,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      totalPages: totalPages ?? this.totalPages,
      readPages: readPages ?? this.readPages,
      description: description ?? this.description,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String? ?? '',
      folderId: json['folderId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      title: json['title'] as String? ?? '',
      type: MaterialType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MaterialType.pdf,
      ),
      fileUrl: json['fileUrl'] as String? ?? '',
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      readPages: (json['readPages'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      dateAdded: json['dateAdded'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderId': folderId,
      'subject': subject,
      'title': title,
      'type': type.name,
      'fileUrl': fileUrl,
      'totalPages': totalPages,
      'readPages': readPages,
      'description': description,
      'dateAdded': dateAdded,
    };
  }
}
