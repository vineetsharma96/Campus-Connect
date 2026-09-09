import 'package:campus/core/models/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole Enum Parsing Tests', () {
    test('Parses database string to correct enum instance', () {
      expect(UserRole.fromString('STUDENT'), equals(UserRole.student));
      expect(UserRole.fromString('INSTITUTE_ADMIN'),
          equals(UserRole.instituteAdmin));
      expect(UserRole.fromString('CLUB_ADMIN'), equals(UserRole.clubAdmin));
    });

    test('Defaults to student on malformed or unexpected role strings', () {
      expect(UserRole.fromString('SUPER_USER'), equals(UserRole.student));
      expect(UserRole.fromString(null), equals(UserRole.student));
      expect(UserRole.fromString(''), equals(UserRole.student));
    });
  });
}
