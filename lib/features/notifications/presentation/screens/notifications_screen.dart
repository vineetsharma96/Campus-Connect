import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/notification_models.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _handleNotificationRouting(
      BuildContext context, WidgetRef ref, NotificationItem item) {
    ref.read(notificationsControllerProvider.notifier).markAsRead(item.id);

    switch (item.type) {
      case NotificationType.notice:
        // Switch to Notices tab via router or pop back
        context.pop();
        break;
      case NotificationType.eventUpdate:
      case NotificationType.eventCancelled:
        context.pop();
        break;
      case NotificationType.rewardUnlocked:
        context.pop();
        break;
      case NotificationType.academicAlert:
        context.push(AppRoutes.academicHub);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (state is NotificationsLoaded && state.unreadCount > 0)
            TextButton.icon(
              onPressed: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label:
                  const Text('Mark all read', style: TextStyle(fontSize: 12)),
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: switch (state) {
        NotificationsLoading() => const _NotificationsSkeleton(),
        NotificationsError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 48, color: AppColors.errorRed),
                  const SizedBox(height: AppSpacing.md),
                  Text('Unable to synchronize notifications',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        NotificationsLoaded(
          :final visibleNotifications,
          :final filterUnreadOnly,
          :final unreadCount
        ) =>
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.sm),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('All (${(state).notifications.length})'),
                      selected: !filterUnreadOnly,
                      onSelected: (_) => ref
                          .read(notificationsControllerProvider.notifier)
                          .toggleFilterUnread(false),
                      selectedColor:
                          AppColors.primaryBlue.withValues(alpha: 0.15),
                      showCheckmark: false,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    FilterChip(
                      label: Text('Unread ($unreadCount)'),
                      selected: filterUnreadOnly,
                      onSelected: (_) => ref
                          .read(notificationsControllerProvider.notifier)
                          .toggleFilterUnread(true),
                      selectedColor:
                          AppColors.primaryBlue.withValues(alpha: 0.15),
                      showCheckmark: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visibleNotifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.notifications_none_rounded,
                                size: 48, color: AppColors.textMutedLight),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              filterUnreadOnly
                                  ? 'No unread notifications'
                                  : 'Inbox is empty',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: visibleNotifications.length,
                        itemBuilder: (context, index) {
                          final item = visibleNotifications[index];
                          return NotificationTile(
                            item: item,
                            onTap: () =>
                                _handleNotificationRouting(context, ref, item),
                          );
                        },
                      ),
              ),
            ],
          ),
      },
    );
  }
}

class _NotificationsSkeleton extends StatelessWidget {
  const _NotificationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
            width: double.infinity,
            height: 75,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
            width: double.infinity,
            height: 75,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
            width: double.infinity,
            height: 75,
            borderRadius: AppSpacing.radiusMd),
      ],
    );
  }
}
