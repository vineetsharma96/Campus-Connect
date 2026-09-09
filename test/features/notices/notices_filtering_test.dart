import 'package:campus/features/notices/domain/notice_models.dart';
import 'package:campus/features/notices/presentation/controllers/notices_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoticesFilterState Engine Tests', () {
    final sampleNotices = [
      NoticeItem(
        id: '1',
        title: 'End-Semester Exam Hall Ticket',
        content: 'Collect hall tickets from academic block.',
        category: NoticeCategory.examinations,
        isImportant: true,
        publishedAt: DateTime.now(),
        isRead: false,
      ),
      NoticeItem(
        id: '2',
        title: 'Minor Project Synopsis Submission',
        content: 'Submit draft to coordinator.',
        category: NoticeCategory.academic,
        isImportant: false,
        publishedAt: DateTime.now(),
        isRead: true,
      ),
      NoticeItem(
        id: '3',
        title: 'Campus Wi-Fi Downtime',
        content: 'Routine server maintenance.',
        category: NoticeCategory.administrative,
        isImportant: false,
        publishedAt: DateTime.now(),
        isRead: false,
      ),
    ];

    test('Filters by Category accurately', () {
      final state = NoticesLoaded(
        allNotices: sampleNotices,
        filter: const NoticesFilterState(
            selectedCategory: NoticeCategory.examinations),
      );

      expect(state.filteredNotices.length, equals(1));
      expect(state.filteredNotices.first.category,
          equals(NoticeCategory.examinations));
    });

    test('Filters by Keyword Search query case-insensitively', () {
      final state = NoticesLoaded(
        allNotices: sampleNotices,
        filter: const NoticesFilterState(searchQuery: 'synopsis'),
      );

      expect(state.filteredNotices.length, equals(1));
      expect(state.filteredNotices.first.id, equals('2'));
    });

    test('Counts unread notices correctly', () {
      final state = NoticesLoaded(
        allNotices: sampleNotices,
        filter: const NoticesFilterState(),
      );

      expect(state.unreadCount, equals(2));
    });
  });
}
