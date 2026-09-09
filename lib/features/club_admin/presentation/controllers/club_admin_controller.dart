import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus/features/auth/domain/auth_state_model.dart';
import 'package:campus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campus/features/club_admin/data/club_admin_repository.dart';
import 'package:campus/features/club_admin/domain/club_admin_models.dart';
import 'package:campus/features/events/domain/club_event_models.dart';

sealed class ClubAdminState {
  const ClubAdminState();
}

class ClubAdminLoading extends ClubAdminState {
  const ClubAdminLoading();
}

class ClubAdminLoaded extends ClubAdminState {
  final ClubAdminProfile profile;
  final List<ClubEventItem> events;
  final bool isSubmitting;

  const ClubAdminLoaded({
    required this.profile,
    required this.events,
    this.isSubmitting = false,
  });

  ClubAdminLoaded copyWith({
    ClubAdminProfile? profile,
    List<ClubEventItem>? events,
    bool? isSubmitting,
  }) {
    return ClubAdminLoaded(
      profile: profile ?? this.profile,
      events: events ?? this.events,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ClubAdminUnauthorized extends ClubAdminState {
  final String message;
  const ClubAdminUnauthorized(this.message);
}

class ClubAdminError extends ClubAdminState {
  final String message;
  const ClubAdminError(this.message);
}

final clubAdminControllerProvider =
    StateNotifierProvider<ClubAdminController, ClubAdminState>((ref) {
  final repo = ref.watch<ClubAdminRepository>(clubAdminRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return ClubAdminController(repo, authState);
});

class ClubAdminController extends StateNotifier<ClubAdminState> {
  final ClubAdminRepository _repo;
  final AppAuthState _authState;

  ClubAdminController(this._repo, this._authState)
      : super(const ClubAdminLoading()) {
    loadClubAdminData();
  }

  Future<void> loadClubAdminData() async {
    state = const ClubAdminLoading();
    final auth = _authState;
    if (auth is! Authenticated) {
      state =
          const ClubAdminUnauthorized('Please log in to manage club events.');
      return;
    }

    final user = auth.profile;
    try {
      final clubProfile = await _repo.fetchAssignedClub(user.id);
      if (clubProfile == null) {
        state =
            const ClubAdminUnauthorized('No club assigned to this account.');
        return;
      }

      final events = await _repo.fetchManagedEvents(clubProfile.clubId);
      state = ClubAdminLoaded(profile: clubProfile, events: events);
    } catch (e) {
      state = ClubAdminError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> submitEvent(EventFormPayload payload) async {
    if (state is! ClubAdminLoaded) {
      return false;
    }
    final current = state as ClubAdminLoaded;

    state = current.copyWith(isSubmitting: true);
    try {
      await _repo.saveEvent(payload);
      final refreshed = await _repo.fetchManagedEvents(current.profile.clubId);
      state = ClubAdminLoaded(
        profile: current.profile,
        events: refreshed,
        isSubmitting: false,
      );
      return true;
    } catch (_) {
      state = current.copyWith(isSubmitting: false);
      return false;
    }
  }

  Future<void> cancelEvent(String eventId) async {
    if (state is! ClubAdminLoaded) {
      return;
    }
    final current = state as ClubAdminLoaded;

    try {
      await _repo.setEventStatus(
        eventId,
        current.profile.clubId,
        EventStatus.cancelled,
      );
      final refreshed = await _repo.fetchManagedEvents(current.profile.clubId);
      state = current.copyWith(events: refreshed);
    } catch (_) {}
  }

  Future<void> deleteEvent(String eventId) async {
    if (state is! ClubAdminLoaded) {
      return;
    }
    final current = state as ClubAdminLoaded;

    try {
      await _repo.deleteEvent(eventId, current.profile.clubId);
      final refreshed = await _repo.fetchManagedEvents(current.profile.clubId);
      state = current.copyWith(events: refreshed);
    } catch (_) {}
  }

  Future<void> refresh() async => loadClubAdminData();
}
