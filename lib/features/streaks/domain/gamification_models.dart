class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int requiredStreak;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.requiredStreak,
    required this.xpReward,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory BadgeItem.fromJson(
    Map<String, dynamic> json, {
    bool isUnlocked = false,
    DateTime? unlockedAt,
  }) {
    return BadgeItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Achievement',
      description: json['description'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'military_tech_rounded',
      requiredStreak: json['required_streak'] as int? ?? 0,
      xpReward: json['xp_reward'] as int? ?? 0,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
    );
  }
}

class NextRewardProgress {
  final BadgeItem nextBadge;
  final int daysRemaining;
  final double progressFraction;

  const NextRewardProgress({
    required this.nextBadge,
    required this.daysRemaining,
    required this.progressFraction,
  });
}

class StudentGamificationSummary {
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final int currentLevel;
  final int xpInCurrentLevel;
  final int xpForNextLevel;
  final double levelProgress;
  final List<BadgeItem> badges;
  final NextRewardProgress? nextReward;

  const StudentGamificationSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXp,
    required this.currentLevel,
    required this.xpInCurrentLevel,
    required this.xpForNextLevel,
    required this.levelProgress,
    required this.badges,
    this.nextReward,
  });

  static const int xpStepPerLevel = 250;

  static int calculateLevel(int totalXp) {
    if (totalXp <= 0) {
      return 1;
    }
    return (totalXp / xpStepPerLevel).floor() + 1;
  }

  static int calculateXpInCurrentLevel(int totalXp) {
    return totalXp % xpStepPerLevel;
  }

  static double calculateLevelProgress(int totalXp) {
    final remainder = totalXp % xpStepPerLevel;
    return remainder / xpStepPerLevel;
  }
}