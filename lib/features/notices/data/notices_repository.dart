import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/notice_models.dart';

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) {
  return NoticesRepository(Supabase.instance.client);
});

class NoticesRepository {
  final SupabaseClient _client;

  NoticesRepository(this._client);

  Future<List<NoticeItem>> fetchNotices(String studentId) async {
    try {
      // 1. Fetch notices sorted by importance and recency
      final response = await _client
          .from('notices')
          .select(
              'id, title, content, category, is_important, attachment_url, published_at')
          .order('is_important', ascending: false)
          .order('published_at', ascending: false);

      final noticesRaw = List<Map<String, dynamic>>.from(response);

      // 2. Fetch read statuses for current student
      final readResponse = await _client
          .from('notice_reads')
          .select('notice_id')
          .eq('student_id', studentId);

      final readNoticeIds = (readResponse as List)
          .map((r) => (r as Map<String, dynamic>)['notice_id'] as String)
          .toSet();

      return noticesRaw.map((json) {
        final id = json['id'] as String;
        return NoticeItem.fromJson(json, isRead: readNoticeIds.contains(id));
      }).toList();
    } catch (_) {
      throw Exception(
          'Failed to load institute notices. Please check your network.');
    }
  }

  Future<void> markAsRead(String studentId, String noticeId) async {
    try {
      await _client.from('notice_reads').upsert({
        'notice_id': noticeId,
        'student_id': studentId,
      }, onConflict: 'notice_id,student_id');
    } catch (_) {
      // Non-critical background failure suppressed to preserve UX flow
    }
  }
}
