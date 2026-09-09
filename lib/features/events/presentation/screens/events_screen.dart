import 'package:campus/core/constants/app_colors.dart';
import 'package:campus/core/constants/app_spacing.dart';
import 'package:campus/features/events/domain/club_event_models.dart';
import 'package:campus/features/events/presentation/controllers/events_controller.dart';
import 'package:campus/features/events/presentation/widgets/club_directory_card.dart';
import 'package:campus/features/events/presentation/widgets/event_card.dart';
import 'package:campus/features/events/presentation/widgets/event_detail_sheet.dart';
import 'package:campus/shared/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clubs & Campus Events',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: switch (state) {
        EventsLoading() => const _EventsSkeleton(),
        EventsError(:final message) => _EventsErrorView(
            message: message,
            onRetry: () =>
                ref.read(eventsControllerProvider.notifier).refresh(),
          ),
        EventsLoaded(
          :final filter,
          :final filteredEvents,
          :final filteredClubs
        ) =>
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => ref
                              .read(eventsControllerProvider.notifier)
                              .setActiveTab(0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: filter.activeTab == 0
                                  ? AppColors.primaryBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd - 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Upcoming Events (${filteredEvents.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: filter.activeTab == 0
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => ref
                              .read(eventsControllerProvider.notifier)
                              .setActiveTab(1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: filter.activeTab == 1
                                  ? AppColors.primaryBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd - 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Clubs Directory (${filteredClubs.length})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: filter.activeTab == 1
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref
                      .read(eventsControllerProvider.notifier)
                      .updateSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: filter.activeTab == 0
                        ? 'Search events, clubs, venues...'
                        : 'Search clubs, societies, leads...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(eventsControllerProvider.notifier)
                                  .updateSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    filled: true,
                    fillColor: theme.cardTheme.color,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: EventCategory.values.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final cat = EventCategory.values[index];
                    final isSelected = filter.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: isSelected,
                      onSelected: (_) => ref
                          .read(eventsControllerProvider.notifier)
                          .selectCategory(cat),
                      selectedColor: AppColors.primaryBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : theme.colorScheme.outline,
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(eventsControllerProvider.notifier).refresh(),
                  child: filter.activeTab == 0
                      ? (filteredEvents.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 60),
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.event_busy_rounded,
                                          size: 48,
                                          color: AppColors.textMutedLight),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text('No events matching criteria',
                                          style: theme.textTheme.titleMedium),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];
                                return EventCard(
                                  event: event,
                                  onTap: () =>
                                      EventDetailSheet.show(context, event),
                                );
                              },
                            ))
                      : (filteredClubs.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 60),
                                Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.groups_rounded,
                                          size: 48,
                                          color: AppColors.textMutedLight),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text('No clubs found',
                                          style: theme.textTheme.titleMedium),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              itemCount: filteredClubs.length,
                              itemBuilder: (context, index) {
                                final club = filteredClubs[index];
                                return ClubDirectoryCard(club: club);
                              },
                            )),
                ),
              ),
            ],
          ),
      },
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
            width: double.infinity,
            height: 40,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
            width: double.infinity,
            height: 42,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
            width: double.infinity,
            height: 135,
            borderRadius: AppSpacing.radiusLg),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
            width: double.infinity,
            height: 135,
            borderRadius: AppSpacing.radiusLg),
      ],
    );
  }
}

class _EventsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EventsErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.errorRed),
            const SizedBox(height: AppSpacing.md),
            Text('Events Offline',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reload Events'),
            ),
          ],
        ),
      ),
    );
  }
}
