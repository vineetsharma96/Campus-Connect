enum NoticeCategory {
  all('ALL', 'All'),
  academic('ACADEMIC', 'Academic'),
  examinations('EXAMINATIONS', 'Exams'),
  administrative('ADMINISTRATIVE', 'Admin'),
  clubs('CLUBS', 'Clubs');

  final String dbValue;
  final String label;

  const NoticeCategory(this.dbValue, this.label);

  static NoticeCategory fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'ACADEMIC' => NoticeCategory.academic,
      'EXAMINATIONS' => NoticeCategory.examinations,
      'ADMINISTRATIVE' => NoticeCategory.administrative,
      'CLUBS' => NoticeCategory.clubs,
      _ => NoticeCategory.all,
    };
  }
}

class NoticeItem {
  final String id;
  final String title;
  final String content;
  final NoticeCategory category;
  final bool isImportant;
  final String? attachmentUrl;
  final DateTime publishedAt;
  final bool isRead;

  const NoticeItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isImportant,
    this.attachmentUrl,
    required this.publishedAt,
    this.isRead = false,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> json,
      {bool isRead = false}) {
    return NoticeItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Notice',
      content: json['content'] as String? ?? '',
      category: NoticeCategory.fromString(json['category'] as String?),
      isImportant: json['is_important'] as bool? ?? false,
      attachmentUrl: json['attachment_url'] as String?,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      isRead: isRead,
    );
  }

  NoticeItem copyWith({bool? isRead}) {
    return NoticeItem(
      id: id,
      title: title,
      content: content,
      category: category,
      isImportant: isImportant,
      attachmentUrl: attachmentUrl,
      publishedAt: publishedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
