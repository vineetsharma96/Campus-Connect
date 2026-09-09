import 'package:campus/features/events/domain/club_event_models.dart';
import 'package:campus/features/events/presentation/controllers/events_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Events & Club Filter Logic Tests', () {
    final sampleClubs = [
      const ClubItem(
        id: 'c1',
        name: 'Google Developer Student Club',
        code: 'GDSC',
        category: EventCategory.technical,
        description: 'Tech hackathons and open-source.',
        leadName: 'Ishita Roy',
        contactEmail: 'gdsc@campus.edu',
      ),
      const ClubItem(
        id: 'c2',
        name: 'Society of Arts & Music',
        code: 'SAM',
        category: EventCategory.cultural,
        description: 'Acoustic and creative showcase.',
        leadName: 'Rohan Nair',
        contactEmail: 'music@campus.edu',
      ),
    ];

    final sampleEvents = [
      ClubEventItem(
        id: 'e1',
        clubId: 'c1',
        clubName: 'Google Developer Student Club',
        clubCode: 'GDSC',
        title: 'Annual Technical Hackathon',
        description: '36-hour code sprint.',
        category: EventCategory.technical,
        venue: 'Seminar Hall B',
        eventDate: DateTime.now().add(const Duration(days: 3)),
        status: EventStatus.upcoming,
      ),
      ClubEventItem(
        id: 'e2',
        clubId: 'c2',
        clubName: 'Society of Arts & Music',
        clubCode: 'SAM',
        title: 'Acoustic Open Mic',
        description: 'Unplugged guitar and indie vocals.',
        category: EventCategory.cultural,
        venue: 'Open Amphitheater',
        eventDate: DateTime.now().add(const Duration(days: 6)),
        status: EventStatus.upcoming,
      ),
    ];

    test('Filters events by category accurately', () {
      final state = EventsLoaded(
        allEvents: sampleEvents,
        allClubs: sampleClubs,
        filter:
            const EventsFilterState(selectedCategory: EventCategory.technical),
      );

      expect(state.filteredEvents.length, equals(1));
      expect(state.filteredEvents.first.title,
          equals('Annual Technical Hackathon'));
    });

    test('Filters events by search query across title, club name, or venue',
        () {
      final state = EventsLoaded(
        allEvents: sampleEvents,
        allClubs: sampleClubs,
        filter: const EventsFilterState(searchQuery: 'amphitheater'),
      );

      expect(state.filteredEvents.length, equals(1));
      expect(state.filteredEvents.first.venue, equals('Open Amphitheater'));
    });

    test('Filters club directory by name search', () {
      final state = EventsLoaded(
        allEvents: sampleEvents,
        allClubs: sampleClubs,
        filter: const EventsFilterState(activeTab: 1, searchQuery: 'GDSC'),
      );

      expect(state.filteredClubs.length, equals(1));
      expect(state.filteredClubs.first.code, equals('GDSC'));
    });
  });
}
