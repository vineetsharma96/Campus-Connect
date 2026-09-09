import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:campus/features/club_admin/domain/club_admin_models.dart';
import 'package:campus/features/events/domain/club_event_models.dart';

final clubAdminRepositoryProvider = Provider<ClubAdminRepository>((ref) {
  return ClubAdminRepository(Supabase.instance.client);
});

class ClubAdminRepository {
  final SupabaseClient _client;

  ClubAdminRepository(this._client);

  Future<ClubAdminProfile?> fetchAssignedClub(String userId) async {
    try {
      final response = await _client
          .from('club_admins')
          .select('club_id, clubs(name, code, category)')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }
      return ClubAdminProfile.fromJson(response);
    } catch (_) {
      throw Exception('Failed to load administrator club assignment.');
    }
  }

  Future<List<ClubEventItem>> fetchManagedEvents(String clubId) async {
    try {
      final response = await _client
          .from('events')
          .select(
            'id, club_id, title, description, category, venue, event_date, poster_url, registration_url, status, clubs(name, code)',
          )
          .eq('club_id', clubId)
          .order('event_date', ascending: false);

      return (response as List)
          .map((json) => ClubEventItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw Exception('Unable to load club events.');
    }
  }

  Future<void> saveEvent(EventFormPayload payload) async {
    try {
      if (payload.eventId == null) {
        await _client.from('events').insert(payload.toSupabaseMap());
      } else {
        final response = await _client
            .from('events')
            .update(payload.toSupabaseMap())
            .eq('id', payload.eventId!)
            .eq('club_id', payload.clubId)
            .select();

        if ((response as List).isEmpty) {
          throw Exception(
              'Update failed. You may lack permission for this event.');
        }
      }
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> setEventStatus(
    String eventId,
    String clubId,
    EventStatus newStatus,
  ) async {
    try {
      await _client
          .from('events')
          .update({
            'status': newStatus.dbValue,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', eventId)
          .eq('club_id', clubId);
    } catch (_) {
      throw Exception('Failed to update event status.');
    }
  }

  Future<void> deleteEvent(String eventId, String clubId) async {
    try {
      await _client
          .from('events')
          .delete()
          .eq('id', eventId)
          .eq('club_id', clubId);
    } catch (_) {
      throw Exception('Unauthorized to delete this event.');
    }
  }
}
