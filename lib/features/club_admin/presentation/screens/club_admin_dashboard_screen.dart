import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../events/domain/club_event_models.dart';
import '../controllers/club_admin_controller.dart';
import '../widgets/event_editor_dialog.dart';

class ClubAdminDashboardScreen extends ConsumerWidget {
  const ClubAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubAdminControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Club Management Console',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: state is ClubAdminLoaded
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Event',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: () {
                EventEditorDialog.show(
                  context,
                  clubId: state.profile.clubId,
                  clubCategory: state.profile.category,
                  onSave: (payload) => ref
                      .read(clubAdminControllerProvider.notifier)
                      .submitEvent(payload),
                );
              },
            )
          : null,
      body: switch (state) {
        ClubAdminLoading() => const _AdminSkeleton(),
        ClubAdminUnauthorized(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person_rounded,
                      size: 52, color: AppColors.textMutedLight),
                  const SizedBox(height: AppSpacing.md),
                  Text('Access Restricted', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ClubAdminError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.errorRed),
                const SizedBox(height: AppSpacing.md),
                Text(message),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () =>
                      ref.read(clubAdminControllerProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ClubAdminLoaded(:final profile, :final events) => RefreshIndicator(
            onRefresh: () =>
                ref.read(clubAdminControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 80),
              children: [
                // Club Header Badge
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profile.clubCode,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.clubName,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Authorized Lead • ${profile.category.label} Wing',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: AppColors.secondaryTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MANAGED EVENTS (${events.length})',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'No events published yet. Tap "+ Create Event" to post.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...events.map(
                    (event) => _ManagedEventTile(
                      event: event,
                      onEdit: () {
                        EventEditorDialog.show(
                          context,
                          clubId: profile.clubId,
                          clubCategory: profile.category,
                          existingEvent: event,
                          onSave: (payload) => ref
                              .read(clubAdminControllerProvider.notifier)
                              .submitEvent(payload),
                        );
                      },
                      onCancel: () => ref
                          .read(clubAdminControllerProvider.notifier)
                          .cancelEvent(event.id),
                      onDelete: () => ref
                          .read(clubAdminControllerProvider.notifier)
                          .deleteEvent(event.id),
                    ),
                  ),
              ],
            ),
          ),
      },
    );
  }
}

class _ManagedEventTile extends StatelessWidget {
  final ClubEventItem event;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _ManagedEventTile({
    required this.event,
    required this.onEdit,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = event.status == EventStatus.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppColors.errorRed.withValues(alpha: 0.12)
                      : AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event.status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCancelled
                        ? AppColors.errorRed
                        : AppColors.successGreen,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'cancel') onCancel();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit Details')),
                  if (!isCancelled)
                    const PopupMenuItem(
                        value: 'cancel', child: Text('Cancel Event')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Event',
                        style: TextStyle(color: AppColors.errorRed)),
                  ),
                ],
              ),
            ],
          ),
          Text(
            event.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year} • ${event.venue}',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AdminSkeleton extends StatelessWidget {
  const _AdminSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
            width: double.infinity,
            height: 75,
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
      ],
    );
  }
}
