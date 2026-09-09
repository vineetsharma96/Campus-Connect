import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus/features/auth/domain/auth_state_model.dart';
import 'package:campus/features/auth/presentation/controllers/auth_controller.dart';
import '../../data/notices_repository.dart';
import '../../domain/notice_models.dart';

class NoticesFilterState {
  final NoticeCategory selectedCategory;
  final String searchQuery;

  const NoticesFilterState({
    this.selectedCategory = NoticeCategory.all,
    this.searchQuery = '',
  });

  NoticesFilterState copyWith({
    NoticeCategory? selectedCategory,
    String? searchQuery,
  }) {
    return NoticesFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

sealed class NoticesState {
  const NoticesState();
}

class NoticesLoading extends NoticesState {
  const NoticesLoading();
}

class NoticesLoaded extends NoticesState {
  final List<NoticeItem> allNotices;
  final NoticesFilterState filter;

  const NoticesLoaded({required this.allNotices, required this.filter});

  List<NoticeItem> get filteredNotices {
    return allNotices.where((notice) {
      final matchesCategory = filter.selectedCategory == NoticeCategory.all ||
          notice.category == filter.selectedCategory;
      final query = filter.searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          notice.title.toLowerCase().contains(query) ||
          notice.content.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get unreadCount => allNotices.where((n) => !n.isRead).length;
}

class NoticesError extends NoticesState {
  final String message;
  const NoticesError(this.message);
}

final noticesControllerProvider =
    StateNotifierProvider<NoticesController, NoticesState>((ref) {
  final repo = ref.watch(noticesRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return NoticesController(repo, authState);
});

class NoticesController extends StateNotifier<NoticesState> {
  final NoticesRepository _repo;
  final AppAuthState _authState;

  NoticesController(this._repo, this._authState)
      : super(const NoticesLoading()) {
    loadNotices();
  }

  Future<void> loadNotices() async {
    state = const NoticesLoading();
    final currentAuth = _authState;
    if (currentAuth is! Authenticated) {
      state = const NoticesError('Session expired. Please log in.');
      return;
    }

    final studentId = currentAuth.profile.id;
    try {
      final notices = await _repo.fetchNotices(studentId);
      state = NoticesLoaded(
        allNotices: notices,
        filter: const NoticesFilterState(),
      );
    } catch (e) {
      state = NoticesError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void selectCategory(NoticeCategory category) {
    final currentState = state;
    if (currentState is NoticesLoaded) {
      state = NoticesLoaded(
        allNotices: currentState.allNotices,
        filter: currentState.filter.copyWith(selectedCategory: category),
      );
    }
  }

  void updateSearchQuery(String query) {
    final currentState = state;
    if (currentState is NoticesLoaded) {
      state = NoticesLoaded(
        allNotices: currentState.allNotices,
        filter: currentState.filter.copyWith(searchQuery: query),
      );
    }
  }

  Future<void> markNoticeAsRead(String noticeId) async {
    final currentAuth = _authState;
    final currentState = state;
    if (currentAuth is! Authenticated || currentState is! NoticesLoaded) {
      return;
    }

    final studentId = currentAuth.profile.id;

    final updatedList = currentState.allNotices.map((n) {
      if (n.id == noticeId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    state = NoticesLoaded(allNotices: updatedList, filter: currentState.filter);
    await _repo.markAsRead(studentId, noticeId);
  }

  Future<void> refresh() async => loadNotices();
}
