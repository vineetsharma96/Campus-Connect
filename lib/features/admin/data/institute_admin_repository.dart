import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../academic/domain/academic_hierarchy_models.dart';
import '../../academic/domain/academic_models.dart';
import '../../events/domain/club_event_models.dart';
import '../../notices/domain/notice_models.dart';
import '../domain/admin_models.dart';

final instituteAdminRepositoryProvider =
    Provider<InstituteAdminRepository>((ref) {
  return InstituteAdminRepository(Supabase.instance.client);
});

class InstituteAdminRepository {
  final SupabaseClient _client;

  InstituteAdminRepository(this._client);

  // --- Allocations & Hierarchy ---
  Future<List<FacultyAllocation>> fetchFacultyAllocations() async {
    final response = await _client.from('faculty_allocations').select(
          'id, subject_id, section_id, subjects(name, code), sections(section_name, semester, courses(code))',
        );

    return (response as List)
        .map((j) => FacultyAllocation.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<SectionStudent>> fetchSectionStudents(String sectionId) async {
    final response = await _client
        .from('profiles')
        .select('id, full_name, email, avatar_url')
        .eq('section_id', sectionId)
        .order('full_name');

    return (response as List)
        .map((j) => SectionStudent.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // --- Notices Operations ---
  Future<List<NoticeItem>> fetchNotices() async {
    final response = await _client
        .from('notices')
        .select()
        .order('published_at', ascending: false);
    return (response as List)
        .map((json) => NoticeItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveNotice(NoticePayload payload, String publisherId) async {
    if (payload.id == null) {
      await _client.from('notices').insert(payload.toMap(publisherId));
    } else {
      await _client
          .from('notices')
          .update(payload.toMap(publisherId))
          .eq('id', payload.id!);
    }
  }

  Future<void> deleteNotice(String noticeId) async {
    await _client.from('notices').delete().eq('id', noticeId);
  }

  // --- Faculty Operations ---
  Future<List<FacultyMember>> fetchFaculty() async {
    final response = await _client.from('faculty').select().order('full_name');
    return (response as List)
        .map((json) => FacultyMember.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFaculty(FacultyPayload payload) async {
    if (payload.id == null) {
      await _client.from('faculty').insert(payload.toMap());
    } else {
      await _client
          .from('faculty')
          .update(payload.toMap())
          .eq('id', payload.id!);
    }
  }

  Future<void> deleteFaculty(String facultyId) async {
    await _client.from('faculty').delete().eq('id', facultyId);
  }

  // --- Club Admin Operations ---
  Future<List<CandidateStudent>> fetchCandidateStudents() async {
    final response = await _client
        .from('profiles')
        .select('id, full_name, email, role')
        .order('full_name');

    return (response as List)
        .map((json) => CandidateStudent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClubItem>> fetchClubs() async {
    final response = await _client.from('clubs').select().order('name');
    return (response as List)
        .map((json) => ClubItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignClubAdmin(String userId, String clubId) async {
    await _client.rpc<void>(
      'assign_club_admin',
      params: {'target_user_id': userId, 'target_club_id': clubId},
    );
  }

  Future<void> revokeClubAdmin(String userId) async {
    await _client.rpc<void>(
      'revoke_club_admin',
      params: {'target_user_id': userId},
    );
  }
}
