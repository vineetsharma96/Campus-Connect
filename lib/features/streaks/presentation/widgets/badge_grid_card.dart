import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/gamification_models.dart';
import 'milestone_celebration_dialog.dart';

class BadgeGridCard extends StatelessWidget {
  final List<BadgeItem> badges;

  const BadgeGridCard({super.key, required this.badges});

  IconData _resolveIcon(String iconName) {
    return switch (iconName) {
      'bolt_rounded' => Icons.bolt_rounded,
      'local_fire_department_rounded' => Icons.local_fire_department_rounded,
      'workspace_premium_rounded' => Icons.workspace_premium_rounded,
      'military_tech_rounded' => Icons.military_tech_rounded,
      'emoji_events_rounded' => Icons.emoji_events_rounded,
      _ => Icons.shield_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ATTENDANCE BADGES',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '${badges.where((b) => b.isUnlocked).length} of ${badges.length} Unlocked',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return InkWell(
                onTap: () {
                  if (badge.isUnlocked) {
                    MilestoneCelebrationDialog.show(context, badge);
                  }
                },
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: badge.isUnlocked
                        ? AppColors.primaryBlue.withValues(alpha: 0.06)
                        : theme.colorScheme.outline.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: badge.isUnlocked
                          ? AppColors.primaryBlue.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badge.isUnlocked
                              ? AppColors.primaryBlue
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.4),
                        ),
                        child: Icon(
                          _resolveIcon(badge.iconName),
                          color: badge.isUnlocked
                              ? Colors.white
                              : AppColors.textMutedLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badge.isUnlocked
                              ? theme.textTheme.bodyMedium?.color
                              : AppColors.textMutedLight,
                        ),
                      ),
                      Text(
                        '${badge.requiredStreak}d streak',
                        style: TextStyle(
                          fontSize: 10,
                          color: badge.isUnlocked
                              ? AppColors.secondaryTeal
                              : AppColors.textMutedLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
