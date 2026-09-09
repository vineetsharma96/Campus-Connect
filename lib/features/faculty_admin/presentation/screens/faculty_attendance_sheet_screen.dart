import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../academic/domain/academic_hierarchy_models.dart';
import '../../data/faculty_repository.dart';

class FacultyAttendanceSheetScreen extends ConsumerStatefulWidget {
  final FacultyAllocation allocation;

  const FacultyAttendanceSheetScreen({super.key, required this.allocation});

  @override
  ConsumerState<FacultyAttendanceSheetScreen> createState() =>
      _FacultyAttendanceSheetScreenState();
}

class _FacultyAttendanceSheetScreenState
    extends ConsumerState<FacultyAttendanceSheetScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;
  List<SectionStudent> _students = [];
  final Map<String, bool> _attendance = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final list = await ref
          .read<FacultyRepository>(facultyRepositoryProvider)
          .fetchStudentsBySection(widget.allocation.sectionId);
      setState(() {
        _students = list;
        for (final s in list) {
          _attendance[s.id] = true;
        }
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _markAll(bool isPresent) {
    setState(() {
      for (final s in _students) {
        _attendance[s.id] = isPresent;
      }
    });
  }

  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read<FacultyRepository>(facultyRepositoryProvider)
          .submitAttendanceBatch(
            subjectId: widget.allocation.subjectId,
            sectionId: widget.allocation.sectionId,
            date: _selectedDate,
            attendanceMap: _attendance,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance recorded successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentCount = _attendance.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.allocation.courseCode} Sem ${widget.allocation.semester} - ${widget.allocation.sectionName}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              widget.allocation.subjectName,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Present: $presentCount / ${_students.length}',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _isSaving || _isLoading ? null : _saveAttendance,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Submit Records'),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        icon:
                            const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 30)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _markAll(true),
                        child: const Text('All Present'),
                      ),
                      TextButton(
                        onPressed: () => _markAll(false),
                        child: const Text('All Absent',
                            style: TextStyle(color: AppColors.errorRed)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final isPresent = _attendance[student.id] ?? true;

                      return SwitchListTile(
                        value: isPresent,
                        activeTrackColor: AppColors.successGreen,
                        inactiveThumbColor: AppColors.errorRed,
                        onChanged: (val) {
                          setState(() => _attendance[student.id] = val);
                        },
                        title: Text(
                          student.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(student.email,
                            style: const TextStyle(fontSize: 12)),
                        secondary: CircleAvatar(
                          backgroundColor: (isPresent
                                  ? AppColors.successGreen
                                  : AppColors.errorRed)
                              .withValues(alpha: 0.12),
                          child: Text(
                            student.fullName.isNotEmpty
                                ? student.fullName[0]
                                : 'S',
                            style: TextStyle(
                              color: isPresent
                                  ? AppColors.successGreen
                                  : AppColors.errorRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
