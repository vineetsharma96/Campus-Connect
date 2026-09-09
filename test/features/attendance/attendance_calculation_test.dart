import 'package:campus/features/attendance/domain/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Attendance Calculation Tests', () {
    test('Calculates accurate percentage and detects shortage', () {
      const subject = SubjectAttendance(
        subjectId: 'sub-1',
        code: 'CS303',
        name: 'Operating Systems',
        facultyName: 'Dr. Meenakshi',
        totalConducted: 16,
        totalAttended: 11,
        totalAbsent: 5,
      );

      expect(subject.percentage, closeTo(68.75, 0.01));
      expect(subject.isBelowThreshold, isTrue);
    });

    test('Calculates exact classes needed to cross 75% threshold', () {
      const subject = SubjectAttendance(
        subjectId: 'sub-1',
        code: 'CS303',
        name: 'Operating Systems',
        facultyName: 'Dr. Meenakshi',
        totalConducted: 16,
        totalAttended: 11,
        totalAbsent: 5,
      );

      // Current: 11/16 = 68.75%
      // Attend 4 more: (11+4)/(16+4) = 15/20 = 75.0%
      expect(subject.classesNeededToReach(75.0), equals(4));
    });

    test('Calculates safe classes to miss when comfortably above 75%', () {
      const subject = SubjectAttendance(
        subjectId: 'sub-2',
        code: 'MA301',
        name: 'Discrete Mathematics',
        facultyName: 'Prof. Verma',
        totalConducted: 22,
        totalAttended: 21,
        totalAbsent: 1,
      );

      // Current: 21/22 = 95.45%
      // Can miss 6 classes: 21 / (22 + 6) = 21/28 = 75.0%
      expect(subject.classesCanMiss(75.0), equals(6));
    });
  });
}
