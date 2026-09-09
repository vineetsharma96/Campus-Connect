import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/dashboard_data.dart';

class UpcomingEventPreviewCard extends StatelessWidget {
  final DashboardUpcomingEvent? event;
  final VoidCallback onExplore;

  const UpcomingEventPreviewCard({
    super.key,
    required this.event,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
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
                'NEXT CLUB EVENT',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: onExplore,
                child: Text(
                  'View All',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (event == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.event_busy_rounded,
                      color: AppColors.textMutedLight, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'No upcoming events scheduled right now.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else ...[
            Text(
              event!.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.groups_2_rounded,
                    size: 16, color: AppColors.secondaryTeal),
                const SizedBox(width: 4),
                Text(
                  event!.clubName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event!.venue,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
