import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/animated_stat_counter.dart';
import '../../domain/attendance_models.dart';

class SubjectAttendanceCard extends StatelessWidget {
  final SubjectAttendance subject;

  const SubjectAttendanceCard({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isShortage = subject.isBelowThreshold;
    final statusColor =
        isShortage ? AppColors.errorRed : AppColors.successGreen;

    final classesNeeded = subject.classesNeededToReach(75.0);
    final safeToMiss = subject.classesCanMiss(75.0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isShortage
              ? AppColors.errorRed.withValues(alpha: 0.25)
              : theme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  subject.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Row(
                children: [
                  AnimatedStatCounter(
                    targetValue: subject.percentage,
                    fractionDigits: 1,
                    suffix: '%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subject.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Faculty: ${subject.facultyName}',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0.0,
                end: (subject.percentage / 100.0).clamp(0.0, 1.0),
              ),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) {
                return LinearProgressIndicator(
                  value: val,
                  minHeight: 5,
                  backgroundColor:
                      theme.colorScheme.outline.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subject.totalAttended} / ${subject.totalConducted} classes attended',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
              Text(
                isShortage
                    ? 'Attend next $classesNeeded to hit 75%'
                    : safeToMiss > 0
                        ? 'Can miss $safeToMiss safely'
                        : 'On the margin',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isShortage ? AppColors.errorRed : AppColors.secondaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
