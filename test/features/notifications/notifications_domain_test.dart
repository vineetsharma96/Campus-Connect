import 'package:campus/features/notifications/domain/notification_models.dart';
import 'package:campus/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification Domain & Realtime State Tests', () {
    final sampleItems = [
      NotificationItem(
        id: '1',
        userId: 'u1',
        title: 'Notice Alert',
        body: 'Exam schedule released',
        type: NotificationType.notice,
        isRead: false,
        createdAt: DateTime.now(),
      ),
      NotificationItem(
        id: '2',
        userId: 'u1',
        title: 'Event Cancelled',
        body: 'Robotics workshop cancelled',
        type: NotificationType.eventCancelled,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: '3',
        userId: 'u1',
        title: 'Reward Unlocked',
        body: '10-day streak achieved',
        type: NotificationType.rewardUnlocked,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    test('Parses database notification type strings safely', () {
      expect(
        NotificationType.fromString('EVENT_CANCELLED'),
        equals(NotificationType.eventCancelled),
      );
      expect(
        NotificationType.fromString('REWARD_UNLOCKED'),
        equals(NotificationType.rewardUnlocked),
      );
      expect(
        NotificationType.fromString('ACADEMIC_ALERT'),
        equals(NotificationType.academicAlert),
      );
      expect(
        NotificationType.fromString(null),
        equals(NotificationType.notice),
      );
    });

    test('Computes unread count accurately', () {
      final state = NotificationsLoaded(notifications: sampleItems);
      expect(state.unreadCount, equals(2));
    });

    test('Filters visible notifications when unread-only is toggled', () {
      final state = NotificationsLoaded(
        notifications: sampleItems,
        filterUnreadOnly: true,
      );

      expect(state.visibleNotifications.length, equals(2));
      expect(
        state.visibleNotifications.any((NotificationItem n) => n.isRead),
        isFalse,
      );
    });
  });
}
