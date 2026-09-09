enum NotificationType {
  notice('NOTICE', 'Notice'),
  eventUpdate('EVENT_UPDATE', 'Event Update'),
  eventCancelled('EVENT_CANCELLED', 'Cancelled'),
  rewardUnlocked('REWARD_UNLOCKED', 'Achievement'),
  academicAlert('ACADEMIC_ALERT', 'Academic');

  final String dbValue;
  final String label;

  const NotificationType(this.dbValue, this.label);

  static NotificationType fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'EVENT_UPDATE' => NotificationType.eventUpdate,
      'EVENT_CANCELLED' => NotificationType.eventCancelled,
      'REWARD_UNLOCKED' => NotificationType.rewardUnlocked,
      'ACADEMIC_ALERT' => NotificationType.academicAlert,
      _ => NotificationType.notice,
    };
  }
}

class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Campus Alert',
      body: json['body'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String?),
      referenceId: json['reference_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
