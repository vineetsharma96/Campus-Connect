import 'package:campus/features/streaks/domain/gamification_models.dart';
import 'package:campus/features/streaks/domain/streak_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreakCalculator Engine Tests', () {
    test('Calculates consecutive daily streak correctly', () {
      final today = DateTime.now();
      final dates = [
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
        today.subtract(const Duration(days: 3)),
      ];

      final streak = StreakCalculator.calculateConsecutiveStreak(dates);
      expect(streak, equals(4));
    });

    test('Bridges weekends correctly across Friday and Monday', () {
      final monday = DateTime(2026, 9, 7); // Monday
      final friday = DateTime(2026, 9, 4); // Friday
      final thursday = DateTime(2026, 9, 3); // Thursday

      final dates = [monday, friday, thursday];
      final streak = StreakCalculator.calculateConsecutiveStreak(dates, monday);
      expect(streak, equals(3));
    });

    test('Resets streak to 0 if last attendance was more than 1 day ago', () {
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));

      final dates = [fourDaysAgo, fiveDaysAgo];
      final streak = StreakCalculator.calculateConsecutiveStreak(dates);
      expect(streak, equals(0));
    });
  });

  group('StudentGamificationSummary Tests', () {
    test('Calculates correct level based on XP formula', () {
      expect(StudentGamificationSummary.calculateLevel(0), equals(1));
      expect(StudentGamificationSummary.calculateLevel(180), equals(1));
      expect(StudentGamificationSummary.calculateLevel(250), equals(2));
      expect(StudentGamificationSummary.calculateLevel(500), equals(3));
    });

    test('Calculates level progress fraction cleanly', () {
      expect(StudentGamificationSummary.calculateLevelProgress(125),
          closeTo(0.5, 0.01));
      expect(StudentGamificationSummary.calculateXpInCurrentLevel(375),
          equals(125));
    });
  });
}
