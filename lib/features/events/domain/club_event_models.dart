enum EventCategory {
  all('ALL', 'All Events'),
  technical('TECHNICAL', 'Technical'),
  cultural('CULTURAL', 'Cultural'),
  sports('SPORTS', 'Sports'),
  literary('LITERARY', 'Literary');

  final String dbValue;
  final String label;

  const EventCategory(this.dbValue, this.label);

  static EventCategory fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'TECHNICAL' => EventCategory.technical,
      'CULTURAL' => EventCategory.cultural,
      'SPORTS' => EventCategory.sports,
      'LITERARY' => EventCategory.literary,
      _ => EventCategory.all,
    };
  }
}

enum EventStatus {
  upcoming('UPCOMING', 'Upcoming'),
  ongoing('ONGOING', 'Live Now'),
  completed('COMPLETED', 'Concluded'),
  cancelled('CANCELLED', 'Cancelled');

  final String dbValue;
  final String label;

  const EventStatus(this.dbValue, this.label);

  static EventStatus fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'ONGOING' => EventStatus.ongoing,
      'COMPLETED' => EventStatus.completed,
      'CANCELLED' => EventStatus.cancelled,
      _ => EventStatus.upcoming,
    };
  }
}

class ClubItem {
  final String id;
  final String name;
  final String code;
  final EventCategory category;
  final String description;
  final String leadName;
  final String contactEmail;
  final String? logoUrl;

  const ClubItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.description,
    required this.leadName,
    required this.contactEmail,
    this.logoUrl,
  });

  factory ClubItem.fromJson(Map<String, dynamic> json) {
    return ClubItem(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Institute Club',
      code: json['code'] as String? ?? 'CLUB',
      category: EventCategory.fromString(json['category'] as String?),
      description: json['description'] as String? ?? '',
      leadName: json['lead_name'] as String? ?? 'Club Lead',
      contactEmail: json['contact_email'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
    );
  }
}

class ClubEventItem {
  final String id;
  final String clubId;
  final String clubName;
  final String clubCode;
  final String title;
  final String description;
  final EventCategory category;
  final String venue;
  final DateTime eventDate;
  final String? posterUrl;
  final String? registrationUrl;
  final EventStatus status;

  const ClubEventItem({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.clubCode,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    required this.eventDate,
    this.posterUrl,
    this.registrationUrl,
    required this.status,
  });

  factory ClubEventItem.fromJson(Map<String, dynamic> json) {
    final club = json['clubs'] as Map<String, dynamic>? ?? {};

    return ClubEventItem(
      id: json['id'] as String,
      clubId: json['club_id'] as String? ?? '',
      clubName: club['name'] as String? ?? 'Campus Club',
      clubCode: club['code'] as String? ?? 'CLUB',
      title: json['title'] as String? ?? 'Campus Event',
      description: json['description'] as String? ?? '',
      category: EventCategory.fromString(json['category'] as String?),
      venue: json['venue'] as String? ?? 'Campus Grounds',
      eventDate: DateTime.tryParse(json['event_date'] as String? ?? '') ??
          DateTime.now(),
      posterUrl: json['poster_url'] as String?,
      registrationUrl: json['registration_url'] as String?,
      status: EventStatus.fromString(json['status'] as String?),
    );
  }
}
