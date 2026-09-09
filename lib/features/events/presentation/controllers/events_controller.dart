import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/events_repository.dart';
import '../../domain/club_event_models.dart';

class EventsFilterState {
  final EventCategory selectedCategory;
  final String searchQuery;
  final int activeTab; // 0 = Events, 1 = Clubs Directory

  const EventsFilterState({
    this.selectedCategory = EventCategory.all,
    this.searchQuery = '',
    this.activeTab = 0,
  });

  EventsFilterState copyWith({
    EventCategory? selectedCategory,
    String? searchQuery,
    int? activeTab,
  }) {
    return EventsFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

sealed class EventsState {
  const EventsState();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

class EventsLoaded extends EventsState {
  final List<ClubEventItem> allEvents;
  final List<ClubItem> allClubs;
  final EventsFilterState filter;

  const EventsLoaded({
    required this.allEvents,
    required this.allClubs,
    required this.filter,
  });

  List<ClubEventItem> get filteredEvents {
    return allEvents.where((event) {
      final matchesCategory = filter.selectedCategory == EventCategory.all ||
          event.category == filter.selectedCategory;
      final query = filter.searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          event.title.toLowerCase().contains(query) ||
          event.clubName.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<ClubItem> get filteredClubs {
    return allClubs.where((club) {
      final matchesCategory = filter.selectedCategory == EventCategory.all ||
          club.category == filter.selectedCategory;
      final query = filter.searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          club.name.toLowerCase().contains(query) ||
          club.code.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }
}

class EventsError extends EventsState {
  final String message;
  const EventsError(this.message);
}

final eventsControllerProvider =
    StateNotifierProvider<EventsController, EventsState>((ref) {
  final repo = ref.watch(eventsRepositoryProvider);
  return EventsController(repo);
});

class EventsController extends StateNotifier<EventsState> {
  final EventsRepository _repo;

  EventsController(this._repo) : super(const EventsLoading()) {
    loadEventsData();
  }

  Future<void> loadEventsData() async {
    state = const EventsLoading();
    try {
      final results = await Future.wait([
        _repo.fetchEvents(),
        _repo.fetchClubs(),
      ]);

      state = EventsLoaded(
        allEvents: results[0] as List<ClubEventItem>,
        allClubs: results[1] as List<ClubItem>,
        filter: const EventsFilterState(),
      );
    } catch (e) {
      state = EventsError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void selectCategory(EventCategory category) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      state = EventsLoaded(
        allEvents: current.allEvents,
        allClubs: current.allClubs,
        filter: current.filter.copyWith(selectedCategory: category),
      );
    }
  }

  void updateSearchQuery(String query) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      state = EventsLoaded(
        allEvents: current.allEvents,
        allClubs: current.allClubs,
        filter: current.filter.copyWith(searchQuery: query),
      );
    }
  }

  void setActiveTab(int index) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      state = EventsLoaded(
        allEvents: current.allEvents,
        allClubs: current.allClubs,
        filter: current.filter.copyWith(activeTab: index),
      );
    }
  }

  Future<void> refresh() async => loadEventsData();
}
