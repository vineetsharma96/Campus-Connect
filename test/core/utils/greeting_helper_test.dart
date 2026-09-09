import 'package:campus/core/utils/greeting_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GreetingHelper Tests', () {
    test('Returns Good morning between 05:00 and 11:59', () {
      final morning = DateTime(2026, 9, 8, 9, 30);
      expect(GreetingHelper.getGreeting(morning), equals('Good morning'));
      expect(GreetingHelper.getGreetingEmoji(morning), equals('☀️'));
    });

    test('Returns Good afternoon between 12:00 and 16:59', () {
      final afternoon = DateTime(2026, 9, 8, 14, 15);
      expect(GreetingHelper.getGreeting(afternoon), equals('Good afternoon'));
      expect(GreetingHelper.getGreetingEmoji(afternoon), equals('🌤️'));
    });

    test('Returns Good evening between 17:00 and 21:59', () {
      final evening = DateTime(2026, 9, 8, 19, 45);
      expect(GreetingHelper.getGreeting(evening), equals('Good evening'));
      expect(GreetingHelper.getGreetingEmoji(evening), equals('🌆'));
    });

    test('Returns late night message after 22:00 and before 05:00', () {
      final midnight = DateTime(2026, 9, 8, 23, 10);
      expect(GreetingHelper.getGreeting(midnight),
          equals('Burning the midnight oil'));
      expect(GreetingHelper.getGreetingEmoji(midnight), equals('🌙'));
    });
  });
}
