import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/overall_attendance_card.dart';
import '../widgets/subject_attendance_card.dart';

class AttendanceBoardScreen extends ConsumerWidget {
  const AttendanceBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance Board',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(attendanceControllerProvider.notifier).refresh(),
        child: switch (state) {
          AttendanceLoading() => const _AttendanceSkeleton(),
          AttendanceError(:final message) => _AttendanceErrorView(
              message: message,
              onRetry: () =>
                  ref.read(attendanceControllerProvider.notifier).refresh(),
            ),
          AttendanceLoaded(:final summary) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              children: [
                OverallAttendanceCard(
                  percentage: summary.overallPercentage,
                  totalConducted: summary.totalConducted,
                  totalAttended: summary.totalAttended,
                  totalAbsent: summary.totalAbsent,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUBJECT-WISE BREAKDOWN',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      '${summary.subjects.length} Subjects',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...summary.subjects.map(
                  (subject) => SubjectAttendanceCard(subject: subject),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'RECENT SESSION AUDIT LOG',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: summary.recentLogs.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text('No recorded attendance entries yet.'),
                        )
                      : Column(
                          children: summary.recentLogs.map((log) {
                            final isPresent = log.status.dbValue == 'PRESENT';
                            return ListTile(
                              dense: true,
                              title: Text(
                                '${log.subjectCode} — ${log.subjectName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${log.sessionDate.day}/${log.sessionDate.month}/${log.sessionDate.year}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (isPresent
                                          ? AppColors.successGreen
                                          : AppColors.errorRed)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  log.status.dbValue,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isPresent
                                        ? AppColors.successGreen
                                        : AppColors.errorRed,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
        },
      ),
    );
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
            width: double.infinity,
            height: 160,
            borderRadius: AppSpacing.radiusLg),
        SizedBox(height: AppSpacing.lg),
        SkeletonLoader(
            width: double.infinity,
            height: 95,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
            width: double.infinity,
            height: 95,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
            width: double.infinity,
            height: 95,
            borderRadius: AppSpacing.radiusMd),
      ],
    );
  }
}

class _AttendanceErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AttendanceErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.errorRed),
            const SizedBox(height: AppSpacing.md),
            Text('Unable to Load Records',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
