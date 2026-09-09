import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../academic/domain/academic_hierarchy_models.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/faculty_repository.dart';
import 'faculty_attendance_sheet_screen.dart';

final facultyAllocationsProvider =
    FutureProvider<List<FacultyAllocation>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  if (auth is! Authenticated) return [];
  return ref.read(facultyRepositoryProvider).fetchAllocations(auth.profile.id);
});

class FacultyConsoleScreen extends ConsumerWidget {
  const FacultyConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocationsAsync = ref.watch(facultyAllocationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Console',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: allocationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error loading allocations: $err')),
        data: (allocations) {
          if (allocations.isEmpty) {
            return const Center(
              child: Text(
                  'No subject or section allocations found for your account.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(facultyAllocationsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: allocations.length,
              itemBuilder: (context, index) {
                final alloc = allocations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        alloc.subjectCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    title: Text(
                      '${alloc.courseCode} Sem ${alloc.semester} - ${alloc.sectionName}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(alloc.subjectName),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              FacultyAttendanceSheetScreen(allocation: alloc),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
