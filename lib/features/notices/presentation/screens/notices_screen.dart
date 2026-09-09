import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus/core/constants/app_colors.dart';
import 'package:campus/core/constants/app_spacing.dart';
import 'package:campus/shared/widgets/skeleton_loader.dart';
import '../controllers/notices_controller.dart';
import '../../domain/notice_models.dart';
import '../widgets/important_notice_card.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_detail_bottom_sheet.dart';

class NoticesScreen extends ConsumerStatefulWidget {
  const NoticesScreen({super.key});

  @override
  ConsumerState<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends ConsumerState<NoticesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNotice(NoticeItem notice) {
    ref.read(noticesControllerProvider.notifier).markNoticeAsRead(notice.id);
    NoticeDetailBottomSheet.show(context, notice);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticesControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Institute Notices',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: switch (state) {
        NoticesLoading() => const _NoticesSkeleton(),
        NoticesError(:final message) => _NoticesErrorView(
            message: message,
            onRetry: () =>
                ref.read(noticesControllerProvider.notifier).refresh(),
          ),
        NoticesLoaded(:final filter, :final filteredNotices) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref
                      .read(noticesControllerProvider.notifier)
                      .updateSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search notices, syllabus, schedule...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(noticesControllerProvider.notifier)
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
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: NoticeCategory.values.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final cat = NoticeCategory.values[index];
                    final isSelected = filter.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      selected: isSelected,
                      onSelected: (_) => ref
                          .read(noticesControllerProvider.notifier)
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
                      ref.read(noticesControllerProvider.notifier).refresh(),
                  child: filteredNotices.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.inbox_rounded,
                                      size: 48,
                                      color: AppColors.textMutedLight),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'No notices matching filter',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md),
                          itemCount: filteredNotices.length,
                          itemBuilder: (context, index) {
                            final notice = filteredNotices[index];
                            if (notice.isImportant &&
                                index == 0 &&
                                filter.selectedCategory == NoticeCategory.all) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm),
                                child: ImportantNoticeCard(
                                  notice: notice,
                                  onTap: () => _openNotice(notice),
                                ),
                              );
                            }
                            return NoticeCard(
                              notice: notice,
                              onTap: () => _openNotice(notice),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
      },
    );
  }
}

class _NoticesSkeleton extends StatelessWidget {
  const _NoticesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
            width: double.infinity,
            height: 42,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
            width: double.infinity,
            height: 110,
            borderRadius: AppSpacing.radiusLg),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
            width: double.infinity,
            height: 85,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.sm),
        SkeletonLoader(
            width: double.infinity,
            height: 85,
            borderRadius: AppSpacing.radiusMd),
      ],
    );
  }
}

class _NoticesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NoticesErrorView({required this.message, required this.onRetry});

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
            Text('Notice Board Offline',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reload Notices'),
            ),
          ],
        ),
      ),
    );
  }
}
