class DashboardUpcomingEvent {
  final String id;
  final String title;
  final String clubName;
  final DateTime scheduledAt;
  final String venue;
  final String? posterUrl;

  const DashboardUpcomingEvent({
    required this.id,
    required this.title,
    required this.clubName,
    required this.scheduledAt,
    required this.venue,
    this.posterUrl,
  });

  factory DashboardUpcomingEvent.fromJson(Map<String, dynamic> json) {
    return DashboardUpcomingEvent(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Event',
      clubName: json['club_name'] as String? ?? 'Institute Club',
      scheduledAt: DateTime.tryParse(json['scheduled_at'] as String? ?? '') ??
          DateTime.now(),
      venue: json['venue'] as String? ?? 'Campus Auditorium',
      posterUrl: json['poster_url'] as String?,
    );
  }
}

class DashboardNoticeSummary {
  final String id;
  final String title;
  final String category;
  final DateTime publishedAt;
  final bool isImportant;

  const DashboardNoticeSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.publishedAt,
    this.isImportant = false,
  });

  factory DashboardNoticeSummary.fromJson(Map<String, dynamic> json) {
    return DashboardNoticeSummary(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Announcement',
      category: json['category'] as String? ?? 'General',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? '') ??
          DateTime.now(),
      isImportant: json['is_important'] as bool? ?? false,
    );
  }
}

class DashboardData {
  final double overallAttendancePercentage;
  final int totalClassesAttended;
  final int totalClassesConducted;
  final int streakDays;
  final int unreadNoticesCount;
  final DashboardUpcomingEvent? nextEvent;
  final List<DashboardNoticeSummary> recentNotices;

  const DashboardData({
    required this.overallAttendancePercentage,
    required this.totalClassesAttended,
    required this.totalClassesConducted,
    required this.streakDays,
    required this.unreadNoticesCount,
    this.nextEvent,
    this.recentNotices = const [],
  });

  factory DashboardData.initial() {
    return const DashboardData(
      overallAttendancePercentage: 0.0,
      totalClassesAttended: 0,
      totalClassesConducted: 0,
      streakDays: 0,
      unreadNoticesCount: 0,
      nextEvent: null,
      recentNotices: [],
    );
  }
}
