import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/attendance_models.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(Supabase.instance.client);
});

class AttendanceRepository {
  final SupabaseClient _client;

  AttendanceRepository(this._client);

  Future<OverallAttendanceSummary> fetchStudentAttendance(String studentId) async {
    try {
      // 1. Fetch all subjects
      final subjectsResponse = await _client
          .from('subjects')
          .select('id, code, name, faculty_name')
          .order('code');

      final subjectsList = List<Map<String, dynamic>>.from(subjectsResponse);

      // 2. Fetch all attendance logs for this student
      final attendanceResponse = await _client
          .from('attendance')
          .select('id, subject_id, status, session_date, subjects(code, name)')
          .eq('student_id', studentId)
          .order('session_date', ascending: false);

      final attendanceLogs = List<Map<String, dynamic>>.from(attendanceResponse);

      int aggregateConducted = 0;
      int aggregateAttended = 0;
      int aggregateAbsent = 0;

      final List<SubjectAttendance> computedSubjects = [];

      for (final sub in subjectsList) {
        final subId = sub['id'] as String;
        final subLogs = attendanceLogs.where((log) => log['subject_id'] == subId);

        final conducted = subLogs.length;
        final attended = subLogs
            .where((log) => log['status'] == 'PRESENT' || log['status'] == 'EXCUSED')
            .length;
        final absent = subLogs.where((log) => log['status'] == 'ABSENT').length;

        aggregateConducted += conducted;
        aggregateAttended += attended;
        aggregateAbsent += absent;

        computedSubjects.add(
          SubjectAttendance(
            subjectId: subId,
            code: sub['code'] as String? ?? '',
            name: sub['name'] as String? ?? '',
            facultyName: sub['faculty_name'] as String? ?? '',
            totalConducted: conducted,
            totalAttended: attended,
            totalAbsent: absent,
          ),
        );
      }

      final double overallPercentage = aggregateConducted == 0
          ? 100.0
          : (aggregateAttended / aggregateConducted) * 100.0;

      final recentEntries = attendanceLogs
          .take(15)
          .map((json) => AttendanceLogEntry.fromJson(json))
          .toList();

      return OverallAttendanceSummary(
        overallPercentage: overallPercentage,
        totalConducted: aggregateConducted,
        totalAttended: aggregateAttended,
        totalAbsent: aggregateAbsent,
        subjects: computedSubjects,
        recentLogs: recentEntries,
      );
    } catch (_) {
      throw Exception('Unable to load attendance records. Please verify your connection.');
    }
  }
}