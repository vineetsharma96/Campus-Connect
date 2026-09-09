import 'package:campus/features/academic/domain/academic_models.dart';
import 'package:campus/features/academic/presentation/controllers/academic_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Academic Domain Model Tests', () {
    test('Calculates countdown days until examination accurately', () {
      final now = DateTime.now();
      final inTenDays =
          DateTime(now.year, now.month, now.day).add(const Duration(days: 10));

      final exam = ExaminationItem(
        id: 'ex-1',
        subjectCode: 'CS301',
        subjectName: 'DSA',
        examDate: inTenDays,
        startTime: '09:30',
        endTime: '12:30',
        venue: 'Hall A',
      );

      expect(exam.daysUntilExam, equals(10));
    });

    test('Filters timetable slots for selected day', () {
      const slotMon = TimetableSlot(
        id: '1',
        subjectCode: 'CS301',
        subjectName: 'DSA',
        facultyName: 'Dr. Radhika',
        day: AcademicDay.monday,
        startTime: '09:00',
        endTime: '10:00',
        roomNumber: '302',
      );

      const slotTue = TimetableSlot(
        id: '2',
        subjectCode: 'CS303',
        subjectName: 'OS',
        facultyName: 'Dr. Meenakshi',
        day: AcademicDay.tuesday,
        startTime: '09:00',
        endTime: '10:00',
        roomNumber: '204',
      );

      const data = AcademicHubData(
        timetable: [slotMon, slotTue],
        examinations: [],
        faculty: [],
        calendar: [],
        selectedDay: AcademicDay.monday,
      );

      expect(data.slotsForSelectedDay.length, equals(1));
      expect(data.slotsForSelectedDay.first.subjectCode, equals('CS301'));
    });
  });
}
