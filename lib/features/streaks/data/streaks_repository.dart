import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/gamification_models.dart';

final streaksRepositoryProvider = Provider<StreaksRepository>((ref) {
  return StreaksRepository(Supabase.instance.client);
});

class StreaksRepository {
  final SupabaseClient _client;

  StreaksRepository(this._client);

  Future<StudentGamificationSummary> fetchGamificationSummary(
      String studentId) async {
    try {
      // 1. Fetch Streak and XP metrics
      final streakData = await _client
          .from('attendance_streaks')
          .select()
          .eq('student_id', studentId)
          .maybeSingle();

      final currentStreak = streakData?['current_streak'] as int? ?? 0;
      final longestStreak = streakData?['longest_streak'] as int? ?? 0;
      final totalXp = streakData?['total_xp'] as int? ?? 0;

      // 2. Fetch all system badges
      final badgesResponse = await _client
          .from('badges')
          .select()
          .order('required_streak', ascending: true);

      final allBadges = List<Map<String, dynamic>>.from(badgesResponse);

      // 3. Fetch badges unlocked by this student
      final unlockedResponse = await _client
          .from('student_rewards')
          .select('badge_id, unlocked_at')
          .eq('student_id', studentId);

      final unlockedMap = <String, DateTime>{};
      for (final item in List<Map<String, dynamic>>.from(unlockedResponse)) {
        final bId = item['badge_id'] as String;
        final date = DateTime.tryParse(item['unlocked_at'] as String? ?? '');
        if (date != null) {
          unlockedMap[bId] = date;
        }
      }

      final List<BadgeItem> domainBadges = [];
      BadgeItem? nextTargetBadge;

      for (final raw in allBadges) {
        final id = raw['id'] as String;
        final isUnlocked = unlockedMap.containsKey(id);
        final badge = BadgeItem.fromJson(
          raw,
          isUnlocked: isUnlocked,
          unlockedAt: unlockedMap[id],
        );

        domainBadges.add(badge);

        if (!isUnlocked && nextTargetBadge == null) {
          nextTargetBadge = badge;
        }
      }

      NextRewardProgress? nextReward;
      if (nextTargetBadge != null) {
        final remaining = nextTargetBadge.requiredStreak - currentStreak;
        final fraction =
            (currentStreak / nextTargetBadge.requiredStreak).clamp(0.0, 1.0);
        nextReward = NextRewardProgress(
          nextBadge: nextTargetBadge,
          daysRemaining: remaining > 0 ? remaining : 0,
          progressFraction: fraction,
        );
      }

      final currentLevel = StudentGamificationSummary.calculateLevel(totalXp);
      final xpInLevel =
          StudentGamificationSummary.calculateXpInCurrentLevel(totalXp);
      final progress =
          StudentGamificationSummary.calculateLevelProgress(totalXp);

      return StudentGamificationSummary(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        totalXp: totalXp,
        currentLevel: currentLevel,
        xpInCurrentLevel: xpInLevel,
        xpForNextLevel: StudentGamificationSummary.xpStepPerLevel,
        levelProgress: progress,
        badges: domainBadges,
        nextReward: nextReward,
      );
    } catch (_) {
      throw Exception('Unable to load streak and rewards data.');
    }
  }
}
