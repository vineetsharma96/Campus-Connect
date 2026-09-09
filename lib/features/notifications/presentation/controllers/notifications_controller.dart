import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/notifications_repository.dart';
import '../../domain/notification_models.dart';

sealed class NotificationsState {
  const NotificationsState();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationItem> notifications;
  final bool filterUnreadOnly;

  const NotificationsLoaded({
    required this.notifications,
    this.filterUnreadOnly = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get visibleNotifications {
    if (filterUnreadOnly) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  NotificationsLoaded copyWith({
    List<NotificationItem>? notifications,
    bool? filterUnreadOnly,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      filterUnreadOnly: filterUnreadOnly ?? this.filterUnreadOnly,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final repo = ref.watch(notificationsRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return NotificationsController(repo, authState);
});

class NotificationsController extends StateNotifier<NotificationsState> {
  final NotificationsRepository _repo;
  final AppAuthState _authState;
  StreamSubscription<List<NotificationItem>>? _streamSubscription;

  NotificationsController(this._repo, this._authState)
      : super(const NotificationsLoading()) {
    _initSubscription();
  }

  void _initSubscription() {
    final auth = _authState;
    if (auth is! Authenticated) {
      state = const NotificationsLoaded(notifications: []);
      return;
    }

    final userId = auth.profile.id;

    _streamSubscription = _repo.getRealtimeNotificationsStream(userId).listen(
      (items) {
        final currentState = state;
        final currentFilter = currentState is NotificationsLoaded
            ? currentState.filterUnreadOnly
            : false;
        state = NotificationsLoaded(
          notifications: items,
          filterUnreadOnly: currentFilter,
        );
      },
      onError: (Object err) {
        state = NotificationsError(err.toString());
      },
    );
  }

  void toggleFilterUnread(bool unreadOnly) {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      state = currentState.copyWith(filterUnreadOnly: unreadOnly);
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final auth = _authState;
    if (auth is! Authenticated) return;
    final userId = auth.profile.id;
    await _repo.markAllAsRead(userId);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
