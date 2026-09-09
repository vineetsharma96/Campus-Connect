import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../domain/academic_models.dart';
import '../controllers/academic_controller.dart';
import '../widgets/exam_schedule_card.dart';
import '../widgets/faculty_member_card.dart';
import '../widgets/timetable_slot_card.dart';

class AcademicHubScreen extends ConsumerStatefulWidget {
  const AcademicHubScreen({super.key});

  @override
  ConsumerState<AcademicHubScreen> createState() => _AcademicHubScreenState();
}

class _AcademicHubScreenState extends ConsumerState<AcademicHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(academicControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Information',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          tabs: const [
            Tab(text: 'Timetable'),
            Tab(text: 'Exams'),
            Tab(text: 'Faculty'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: switch (state) {
        AcademicLoading() => const _AcademicSkeleton(),
        AcademicError(:final message) => _AcademicErrorView(
            message: message,
            onRetry: () =>
                ref.read(academicControllerProvider.notifier).refresh(),
          ),
        AcademicLoaded(:final data) => TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Timetable
              RefreshIndicator(
                onRefresh: () =>
                    ref.read(academicControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AcademicDay.values.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.xs),
                        itemBuilder: (context, index) {
                          final day = AcademicDay.values[index];
                          final isSelected = data.selectedDay == day;
                          return ChoiceChip(
                            label: Text(day.label),
                            selected: isSelected,
                            onSelected: (_) => ref
                                .read(academicControllerProvider.notifier)
                                .selectDay(day),
                            selectedColor: AppColors.primaryBlue,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color,
                            ),
                            showCheckmark: false,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (data.slotsForSelectedDay.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'No scheduled sessions for ${data.selectedDay.label}.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      )
                    else
                      ...data.slotsForSelectedDay.map(
                        (slot) => TimetableSlotCard(slot: slot),
                      ),
                  ],
                ),
              ),
              // Tab 2: Examination Schedule
              RefreshIndicator(
                onRefresh: () =>
                    ref.read(academicControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (data.examinations.isEmpty)
                      const Center(child: Text('No upcoming exams scheduled.'))
                    else
                      ...data.examinations.map(
                        (exam) => ExamScheduleCard(exam: exam),
                      ),
                  ],
                ),
              ),
              // Tab 3: Faculty Directory
              RefreshIndicator(
                onRefresh: () =>
                    ref.read(academicControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    if (data.faculty.isEmpty)
                      const Center(child: Text('Faculty directory is empty.'))
                    else
                      ...data.faculty.map(
                        (fac) => FacultyMemberCard(faculty: fac),
                      ),
                  ],
                ),
              ),
              // Tab 4: Academic Calendar
              RefreshIndicator(
                onRefresh: () =>
                    ref.read(academicControllerProvider.notifier).refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: data.calendar.length,
                  itemBuilder: (context, index) {
                    final item = data.calendar[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryTeal
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.eventType.label.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.secondaryTeal,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.eventDate.day}/${item.eventDate.month}/${item.eventDate.year}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (item.description != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.description!,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
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

class _AcademicSkeleton extends StatelessWidget {
  const _AcademicSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        SkeletonLoader(
            width: double.infinity,
            height: 38,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.md),
        SkeletonLoader(
            width: double.infinity,
            height: 85,
            borderRadius: AppSpacing.radiusMd),
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

class _AcademicErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AcademicErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school_outlined,
                size: 48, color: AppColors.errorRed),
            const SizedBox(height: AppSpacing.md),
            Text('Academic Records Offline',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
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
