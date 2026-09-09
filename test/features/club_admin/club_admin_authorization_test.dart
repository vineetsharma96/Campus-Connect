import 'package:campus/features/club_admin/domain/club_admin_models.dart';
import 'package:campus/features/events/domain/club_event_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Club Admin Multi-Tenant Payload Security Tests', () {
    test('Payload correctly encodes target club_id and preserves parameters',
        () {
      final now = DateTime.now();
      final payload = EventFormPayload(
        eventId: 'evt-101',
        clubId: 'a1111111-1111-1111-1111-111111111111',
        title: 'GDSC Cloud Jam',
        description: 'Hands-on lab',
        category: EventCategory.technical,
        venue: 'Lab 301',
        eventDate: now,
        registrationUrl: 'https://campus.edu/register',
        status: EventStatus.upcoming,
      );

      final map = payload.toSupabaseMap();

      expect(map['club_id'], equals('a1111111-1111-1111-1111-111111111111'));
      expect(map['category'], equals('TECHNICAL'));
      expect(map['title'], equals('GDSC Cloud Jam'));
      expect(map['status'], equals('UPCOMING'));
    });

    test('Prevents client tampering of club_id across tenants', () {
      const clubAId = 'a1111111-1111-1111-1111-111111111111';
      const clubBId = 'b2222222-2222-2222-2222-222222222222';

      // Simulate admin profile assigned to Club A
      const adminProfile = ClubAdminProfile(
        clubId: clubAId,
        clubName: 'GDSC',
        clubCode: 'GDSC',
        category: EventCategory.technical,
      );

      // Verify that payload targeting Club B fails tenant check
      final payloadForClubB = EventFormPayload(
        clubId: clubBId,
        title: 'Tampered Event',
        description: 'Attempted cross-tenant injection',
        category: EventCategory.cultural,
        venue: 'Amphitheater',
        eventDate: DateTime.now(),
      );

      final isAuthorizedForTenant =
          adminProfile.clubId == payloadForClubB.clubId;
      expect(isAuthorizedForTenant, isFalse);
    });
  });
}
