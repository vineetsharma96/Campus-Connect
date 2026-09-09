import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/club_event_models.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository(Supabase.instance.client);
});

class EventsRepository {
  final SupabaseClient _client;

  EventsRepository(this._client);

  Future<List<ClubEventItem>> fetchEvents() async {
    try {
      final response = await _client
          .from('events')
          .select(
              'id, club_id, title, description, category, venue, event_date, poster_url, registration_url, status, clubs(name, code)')
          .order('event_date', ascending: true);

      return (response as List)
          .map((json) => ClubEventItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw Exception(
          'Unable to load campus events. Please check your connection.');
    }
  }

  Future<List<ClubItem>> fetchClubs() async {
    try {
      final response = await _client
          .from('clubs')
          .select(
              'id, name, code, category, description, lead_name, contact_email, logo_url')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ClubItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw Exception('Unable to load student clubs directory.');
    }
  }
}
