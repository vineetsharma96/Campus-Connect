import 'package:campus/features/admin/domain/admin_models.dart';
import 'package:campus/features/notices/domain/notice_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Institute Admin Domain Tests', () {
    test('NoticePayload serializes clean database parameters', () {
      const payload = NoticePayload(
        title: 'Mid-Term Reschedule',
        content: 'Exam pushed by 2 days.',
        category: NoticeCategory.examinations,
        isImportant: true,
      );

      final map = payload.toMap('admin-uuid');

      expect(map['title'], equals('Mid-Term Reschedule'));
      expect(map['category'], equals('EXAMINATIONS'));
      expect(map['is_important'], isTrue);
      expect(map['published_by'], equals('admin-uuid'));
    });

    test('FacultyPayload formats emails and trims inputs', () {
      const faculty = FacultyPayload(
        fullName: '  Dr. Meenakshi Sundaram ',
        designation: 'Professor',
        department: 'CSE',
        email: 'M.SUNDARAM@CAMPUS.EDU ',
        officeLocation: 'Block B-401',
      );

      final map = faculty.toMap();

      expect(map['full_name'], equals('Dr. Meenakshi Sundaram'));
      expect(map['email'], equals('m.sundaram@campus.edu'));
    });
  });
}
