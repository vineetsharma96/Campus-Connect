import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../academic/domain/academic_hierarchy_models.dart';

final facultyRepositoryProvider = Provider<FacultyRepository>((ref) {
  return FacultyRepository(Supabase.instance.client);
});

class FacultyRepository {
  final SupabaseClient _client;
  FacultyRepository(this._client);

  Future<List<FacultyAllocation>> fetchAllocations(String facultyId) async {
    final response = await _client
        .from('faculty_allocations')
        .select(
            'id, subject_id, section_id, subjects(name, code), sections(section_name, semester, courses(code))')
        .eq('faculty_id', facultyId);

    return (response as List)
        .map((j) => FacultyAllocation.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<SectionStudent>> fetchStudentsBySection(String sectionId) async {
    final response = await _client
        .from('profiles')
        .select('id, full_name, email, avatar_url')
        .eq('section_id', sectionId)
        .order('full_name');

    return (response as List)
        .map((j) => SectionStudent.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitAttendanceBatch({
    required String subjectId,
    required String sectionId,
    required DateTime date,
    required Map<String, bool> attendanceMap,
  }) async {
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final records = attendanceMap.entries
        .map((entry) => {
              'student_id': entry.key,
              'subject_id': subjectId,
              'section_id': sectionId,
              'session_date': formattedDate,
              'status': entry.value ? 'PRESENT' : 'ABSENT',
            })
        .toList();

    await _client.from('attendance').upsert(
          records,
          onConflict: 'student_id,subject_id,session_date',
        );
  }

  Future<void> sendMentorNotice({
    required String mentorId,
    required String title,
    required String message,
  }) async {
    await _client.from('mentor_notices').insert({
      'mentor_id': mentorId,
      'title': title.trim(),
      'message': message.trim(),
    });
  }
}
