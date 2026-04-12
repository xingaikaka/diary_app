class DiaryEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;
  final bool isStarred;
  final List<String> imagePaths;
  final String mood;
  final String? tag;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    this.isStarred = false,
    this.imagePaths = const [],
    this.mood = '😊',
    this.tag,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 提取第一句话作为时间线摘要
  String get excerpt {
    if (content.isEmpty) return '今天还没有写什么…';
    final text = content.trim();
    for (final sep in ['。', '！', '？', '!', '?', '\n']) {
      final idx = text.indexOf(sep);
      if (idx > 0 && idx < 80) return text.substring(0, idx + 1);
    }
    return text.length <= 80 ? text : '${text.substring(0, 80)}…';
  }

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
    bool? isStarred,
    List<String>? imagePaths,
    String? mood,
    Object? tag = _sentinel,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
      isStarred: isStarred ?? this.isStarred,
      imagePaths: imagePaths ?? this.imagePaths,
      mood: mood ?? this.mood,
      tag: tag == _sentinel ? this.tag : tag as String?,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'content': content,
        'isStarred': isStarred,
        'imagePaths': imagePaths,
        'mood': mood,
        'tag': tag,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> j) => DiaryEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        title: j['title'] as String,
        content: j['content'] as String,
        isStarred: j['isStarred'] as bool? ?? false,
        imagePaths:
            (j['imagePaths'] as List?)?.map((e) => e as String).toList() ?? [],
        mood: j['mood'] as String? ?? '😊',
        tag: j['tag'] as String?,
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'] as String)
            : null,
        updatedAt: j['updatedAt'] != null
            ? DateTime.parse(j['updatedAt'] as String)
            : null,
      );
}

const Object _sentinel = Object();
