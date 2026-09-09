import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/user_role.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../shared/widgets/skeleton_loader.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../streaks/presentation/controllers/streaks_controller.dart';
import '../../../streaks/presentation/widgets/badge_grid_card.dart';
import '../../../streaks/presentation/widgets/level_progression_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final streaksState = ref.watch(streaksControllerProvider);

    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = authState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile & Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (profile.role == UserRole.student) {
            await ref.read(streaksControllerProvider.notifier).refresh();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // User Header Block
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.12),
                    child: Text(
                      profile.fullName.isNotEmpty
                          ? profile.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile.role.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryTeal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // --- 1. INSTITUTE ADMIN CONSOLE ---
            if (profile.role == UserRole.instituteAdmin) ...[
              _buildConsoleCard(
                context: context,
                icon: Icons.admin_panel_settings_rounded,
                iconColor: AppColors.primaryNavy,
                title: 'Institute Admin Portal',
                subtitle:
                    'Manage courses, sections, faculty allocations & notices',
                onTap: () => context.push(AppRoutes.instituteAdminDashboard),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // --- 2. FACULTY CONSOLE ---
            if (profile.role == UserRole.faculty ||
                profile.role == UserRole.instituteAdmin) ...[
              _buildConsoleCard(
                context: context,
                icon: Icons.co_present_rounded,
                iconColor: AppColors.primaryBlue,
                title: 'Faculty Console',
                subtitle:
                    'Record section attendance, view rosters & send directives',
                onTap: () => context.push(AppRoutes.facultyConsole),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // --- 3. CLUB ADMIN CONSOLE ---
            if (profile.role == UserRole.clubAdmin ||
                profile.role == UserRole.instituteAdmin) ...[
              _buildConsoleCard(
                context: context,
                icon: Icons.celebration_rounded,
                iconColor: AppColors.streakOrange,
                title: 'Club Admin Console',
                subtitle: 'Organize, edit and manage assigned club events',
                onTap: () => context.push(AppRoutes.clubAdminDashboard),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // --- 4. STUDENT-SPECIFIC MODULES ---
            if (profile.role == UserRole.student) ...[
              _buildConsoleCard(
                context: context,
                icon: Icons.menu_book_rounded,
                iconColor: AppColors.secondaryTeal,
                title: 'Course Syllabus',
                subtitle:
                    'Curriculum units for your registered course & semester',
                onTap: () => context.push(AppRoutes.courseSyllabus),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildConsoleCard(
                context: context,
                icon: Icons.assignment_ind_rounded,
                iconColor: AppColors.warningAmber,
                title: 'Mentor Advisory Desk',
                subtitle:
                    'Official directives sent by your assigned faculty mentor',
                onTap: () => context.push(AppRoutes.mentorNotices),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Gamification & Streak Status
              switch (streaksState) {
                StreaksLoading() => const Column(
                    children: [
                      SkeletonLoader(
                        width: double.infinity,
                        height: 110,
                        borderRadius: AppSpacing.radiusLg,
                      ),
                      SizedBox(height: AppSpacing.md),
                      SkeletonLoader(
                        width: double.infinity,
                        height: 220,
                        borderRadius: AppSpacing.radiusLg,
                      ),
                    ],
                  ),
                StreaksError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(message, textAlign: TextAlign.center),
                    ),
                  ),
                StreaksLoaded(:final summary) => Column(
                    children: [
                      LevelProgressionCard(
                        level: summary.currentLevel,
                        totalXp: summary.totalXp,
                        xpInLevel: summary.xpInCurrentLevel,
                        xpTarget: summary.xpForNextLevel,
                        progress: summary.levelProgress,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BadgeGridCard(badges: summary.badges),
                    ],
                  ),
              },
            ],

            const SizedBox(height: AppSpacing.lg),

            // App Metadata
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('CAMPUS OS Platform'),
              subtitle: const Text('Version 1.0.0 (Production Release)'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Sign Out
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
                foregroundColor: AppColors.errorRed,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Sign Out of Institute Account',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildConsoleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: iconColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: iconColor),
          ],
        ),
      ),
    );
  }
}
