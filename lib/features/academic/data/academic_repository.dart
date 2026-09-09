import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/cache/in_memory_cache.dart';
import '../domain/academic_models.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepository(Supabase.instance.client, InMemoryCache());
});

class AcademicRepository {
  final SupabaseClient _client;
  final InMemoryCache _cache;

  AcademicRepository(this._client, this._cache);

  Future<List<TimetableSlot>> fetchTimetable() async {
    const cacheKey = 'academic_timetable';
    final cached = _cache.get<List<TimetableSlot>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client
          .from('timetable')
          .select(
            'id, day, start_time, end_time, room_number, subjects(code, name), faculty(full_name)',
          )
          .order('start_time');

      final result = (response as List)
          .map((json) => TimetableSlot.fromJson(json as Map<String, dynamic>))
          .toList();

      _cache.set(cacheKey, result, ttl: const Duration(minutes: 15));
      return result;
    } catch (_) {
      throw Exception(
          'Unable to load weekly timetable. Check your connection.');
    }
  }

  Future<List<ExaminationItem>> fetchExaminations() async {
    const cacheKey = 'academic_examinations';
    final cached = _cache.get<List<ExaminationItem>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client
          .from('examinations')
          .select(
            'id, exam_date, start_time, end_time, venue, subjects(code, name)',
          )
          .order('exam_date', ascending: true);

      final result = (response as List)
          .map((json) => ExaminationItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _cache.set(cacheKey, result, ttl: const Duration(minutes: 15));
      return result;
    } catch (_) {
      throw Exception('Unable to load exam schedules.');
    }
  }

  Future<List<FacultyMember>> fetchFacultyDirectory() async {
    const cacheKey = 'academic_faculty';
    final cached = _cache.get<List<FacultyMember>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client
          .from('faculty')
          .select(
            'id, full_name, designation, department, email, office_location',
          )
          .order('full_name');

      final result = (response as List)
          .map((json) => FacultyMember.fromJson(json as Map<String, dynamic>))
          .toList();

      _cache.set(cacheKey, result, ttl: const Duration(hours: 1));
      return result;
    } catch (_) {
      throw Exception('Unable to load faculty directory.');
    }
  }

  Future<List<AcademicCalendarItem>> fetchAcademicCalendar() async {
    const cacheKey = 'academic_calendar';
    final cached = _cache.get<List<AcademicCalendarItem>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _client
          .from('academic_calendar')
          .select(
            'id, title, description, event_date, end_date, event_type',
          )
          .order('event_date', ascending: true);

      final result = (response as List)
          .map((json) =>
              AcademicCalendarItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _cache.set(cacheKey, result, ttl: const Duration(hours: 1));
      return result;
    } catch (_) {
      throw Exception('Unable to load academic calendar milestones.');
    }
  }
}
