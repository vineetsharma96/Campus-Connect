import 'package:campus/features/events/domain/club_event_models.dart';

class ClubAdminProfile {
  final String clubId;
  final String clubName;
  final String clubCode;
  final EventCategory category;

  const ClubAdminProfile({
    required this.clubId,
    required this.clubName,
    required this.clubCode,
    required this.category,
  });

  factory ClubAdminProfile.fromJson(Map<String, dynamic> json) {
    final club = json['clubs'] as Map<String, dynamic>? ?? {};
    return ClubAdminProfile(
      clubId: json['club_id'] as String? ?? '',
      clubName: club['name'] as String? ?? 'Managed Club',
      clubCode: club['code'] as String? ?? 'CLUB',
      category: EventCategory.fromString(club['category'] as String?),
    );
  }
}

class EventFormPayload {
  final String? eventId;
  final String clubId;
  final String title;
  final String description;
  final EventCategory category;
  final String venue;
  final DateTime eventDate;
  final String? registrationUrl;
  final EventStatus status;

  const EventFormPayload({
    this.eventId,
    required this.clubId,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    required this.eventDate,
    this.registrationUrl,
    this.status = EventStatus.upcoming,
  });

  Map<String, dynamic> toSupabaseMap() {
    return {
      'club_id': clubId,
      'title': title.trim(),
      'description': description.trim(),
      'category': category.dbValue,
      'venue': venue.trim(),
      'event_date': eventDate.toUtc().toIso8601String(),
      'registration_url':
          (registrationUrl != null && registrationUrl!.trim().isNotEmpty)
              ? registrationUrl!.trim()
              : null,
      'status': status.dbValue,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
