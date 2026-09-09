import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../academic/domain/academic_models.dart';
import '../../../events/domain/club_event_models.dart';
import '../../../notices/domain/notice_models.dart';
import '../../domain/admin_models.dart';
import '../controllers/institute_admin_controller.dart';
import '../widgets/faculty_editor_dialog.dart';
import '../widgets/notice_editor_dialog.dart';

class InstituteAdminDashboardScreen extends ConsumerWidget {
  const InstituteAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(instituteAdminControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Institute Administration',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: state is AdminLoaded && state.activeTab != 2
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                state.activeTab == 0 ? 'Publish Notice' : 'Add Faculty',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                if (state.activeTab == 0) {
                  NoticeEditorDialog.show(
                    context,
                    onSave: (NoticePayload payload) => ref
                        .read(instituteAdminControllerProvider.notifier)
                        .saveNotice(payload),
                  );
                } else if (state.activeTab == 1) {
                  FacultyEditorDialog.show(
                    context,
                    onSave: (FacultyPayload payload) => ref
                        .read(instituteAdminControllerProvider.notifier)
                        .saveFaculty(payload),
                  );
                }
              },
            )
          : null,
      body: switch (state) {
        AdminLoading() => const _AdminSkeleton(),
        AdminUnauthorized(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 52, color: AppColors.textMutedLight),
                  const SizedBox(height: AppSpacing.md),
                  Text('Admin Authorization Required',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        AdminError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.errorRed),
                const SizedBox(height: AppSpacing.md),
                Text(message),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => ref
                      .read(instituteAdminControllerProvider.notifier)
                      .refresh(),
                  child: const Text('Retry Connection'),
                ),
              ],
            ),
          ),
        AdminLoaded(
          :final notices,
          :final faculty,
          :final students,
          :final clubs,
          :final activeTab
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
                      _buildTab(context, ref, 'Notices (${notices.length})', 0,
                          activeTab),
                      _buildTab(context, ref, 'Faculty (${faculty.length})', 1,
                          activeTab),
                      _buildTab(context, ref, 'Leads Appt', 2, activeTab),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(instituteAdminControllerProvider.notifier)
                      .refresh(),
                  child: activeTab == 0
                      ? _buildNoticesList(context, ref, notices)
                      : activeTab == 1
                          ? _buildFacultyList(context, ref, faculty)
                          : _buildAppointmentsList(
                              context, ref, students, clubs),
                ),
              ),
            ],
          ),
      },
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, String title,
      int targetIndex, int activeIndex) {
    final isSelected = targetIndex == activeIndex;
    return Expanded(
      child: InkWell(
        onTap: () => ref
            .read(instituteAdminControllerProvider.notifier)
            .setActiveTab(targetIndex),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoticesList(
      BuildContext context, WidgetRef ref, List<NoticeItem> notices) {
    if (notices.isEmpty) {
      return const Center(child: Text('No notices published.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 80),
      itemCount: notices.length,
      itemBuilder: (context, index) {
        final notice = notices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            title: Text(
              notice.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
                '${notice.category.label} • ${notice.publishedAt.day}/${notice.publishedAt.month}/${notice.publishedAt.year}'),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  NoticeEditorDialog.show(
                    context,
                    existingNotice: notice,
                    onSave: (NoticePayload payload) => ref
                        .read(instituteAdminControllerProvider.notifier)
                        .saveNotice(payload),
                  );
                } else if (val == 'delete') {
                  ref
                      .read(instituteAdminControllerProvider.notifier)
                      .deleteNotice(notice.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Notice')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete Notice',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacultyList(
      BuildContext context, WidgetRef ref, List<FacultyMember> faculty) {
    if (faculty.isEmpty) {
      return const Center(child: Text('No faculty registered.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 80),
      itemCount: faculty.length,
      itemBuilder: (context, index) {
        final member = faculty[index];
        final bool hasName = member.fullName.isNotEmpty;
        final String initialLetter = hasName ? member.fullName[0] : 'F';

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              child: Text(
                initialLetter,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            title: Text(
              member.fullName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text('${member.designation} • ${member.department}'),
            trailing: PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  FacultyEditorDialog.show(
                    context,
                    existingFaculty: member,
                    onSave: (FacultyPayload payload) => ref
                        .read(instituteAdminControllerProvider.notifier)
                        .saveFaculty(payload),
                  );
                } else if (val == 'delete') {
                  ref
                      .read(instituteAdminControllerProvider.notifier)
                      .deleteFaculty(member.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Info')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Remove Member',
                    style: TextStyle(color: AppColors.errorRed),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    WidgetRef ref,
    List<CandidateStudent> students,
    List<ClubItem> clubs,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isClubAdmin = student.role == 'CLUB_ADMIN';

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text('${student.email} • Role: ${student.role}'),
            trailing: isClubAdmin
                ? OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.errorRed),
                    onPressed: () => ref
                        .read(instituteAdminControllerProvider.notifier)
                        .revokeClubAdmin(student.id),
                    child: const Text('Revoke Lead',
                        style: TextStyle(fontSize: 11)),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _showClubAssignmentDialog(
                          context, ref, student.id, clubs);
                    },
                    child: const Text('Assign Club',
                        style: TextStyle(fontSize: 11)),
                  ),
          ),
        );
      },
    );
  }

  void _showClubAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
    String studentId,
    List<ClubItem> clubs,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text(
          'Select Club to Assign',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        children: clubs.map((c) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(instituteAdminControllerProvider.notifier)
                  .assignClubAdmin(studentId, c.id);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${c.name} (${c.code})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
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
            height: 40,
            borderRadius: AppSpacing.radiusMd),
        SizedBox(height: AppSpacing.md),
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
