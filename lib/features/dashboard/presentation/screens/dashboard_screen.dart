import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/greeting_helper.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/attendance_quick_stat_card.dart';
import '../widgets/streak_banner_card.dart';
import '../widgets/upcoming_event_preview_card.dart';

class DashboardScreen extends ConsumerWidget {
  final void Function(int tabIndex) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final dashboardState = ref.watch(dashboardControllerProvider);

    final fullName =
        authState is Authenticated ? authState.profile.fullName : 'Student';
    final greeting = GreetingHelper.getGreeting();
    final emoji = GreetingHelper.getGreetingEmoji();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.md,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting $emoji',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            Text(
              fullName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final notifState = ref.watch(notificationsControllerProvider);
              final unreadCount = notifState is NotificationsLoaded
                  ? notifState.unreadCount
                  : 0;

              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  backgroundColor: AppColors.errorRed,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                tooltip: 'Notifications Inbox',
                onPressed: () => context.push(AppRoutes.notifications),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Student Profile',
            onPressed: () => onNavigateTab(4),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(dashboardControllerProvider.notifier).refresh(),
        child: switch (dashboardState) {
          DashboardLoading() => const _DashboardSkeletonBody(),
          DashboardError(:final message) => _DashboardErrorBody(
              message: message,
              onRetry: () =>
                  ref.read(dashboardControllerProvider.notifier).refresh(),
            ),
          DashboardLoaded(:final data) => ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              children: [
                StreakBannerCard(streakDays: data.streakDays),
                const SizedBox(height: AppSpacing.md),
                AttendanceQuickStatCard(
                  percentage: data.overallAttendancePercentage,
                  attended: data.totalClassesAttended,
                  conducted: data.totalClassesConducted,
                  onTap: () => onNavigateTab(1),
                ),
                const SizedBox(height: AppSpacing.md),
                // Academic Portal Launcher Card
                InkWell(
                  onTap: () => context.push(AppRoutes.academicHub),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Academic Portal',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Timetable, Exam Roster & Faculty Directory',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMutedLight,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                UpcomingEventPreviewCard(
                  event: data.nextEvent,
                  onExplore: () => onNavigateTab(3),
                ),
                const SizedBox(height: AppSpacing.md),
                _RecentNoticesContainer(
                  notices: data.recentNotices,
                  onViewAll: () => onNavigateTab(2),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
        },
      ),
    );
  }
}

class _RecentNoticesContainer extends StatelessWidget {
  final List<dynamic> notices;
  final VoidCallback onViewAll;

  const _RecentNoticesContainer({
    required this.notices,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LATEST ANNOUNCEMENTS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: onViewAll,
                child: Text(
                  'All Notices',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notices.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No new notices available.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ] else ...[
            ...notices.take(2).map((notice) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notice.title as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _DashboardSkeletonBody extends StatelessWidget {
  const _DashboardSkeletonBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
          width: double.infinity,
          height: 80,
          borderRadius: AppSpacing.radiusLg,
        ),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
          width: double.infinity,
          height: 110,
          borderRadius: AppSpacing.radiusMd,
        ),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
          width: double.infinity,
          height: 72,
          borderRadius: AppSpacing.radiusMd,
        ),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
          width: double.infinity,
          height: 120,
          borderRadius: AppSpacing.radiusMd,
        ),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
          width: double.infinity,
          height: 90,
          borderRadius: AppSpacing.radiusMd,
        ),
      ],
    );
  }
}

class _DashboardErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorBody({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textMutedLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Connection Stalled',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
