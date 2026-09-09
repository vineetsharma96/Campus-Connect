import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/streaks_repository.dart';
import '../../domain/gamification_models.dart';

sealed class StreaksState {
  const StreaksState();
}

class StreaksLoading extends StreaksState {
  const StreaksLoading();
}

class StreaksLoaded extends StreaksState {
  final StudentGamificationSummary summary;
  const StreaksLoaded(this.summary);
}

class StreaksError extends StreaksState {
  final String message;
  const StreaksError(this.message);
}

final streaksControllerProvider =
    StateNotifierProvider<StreaksController, StreaksState>((ref) {
  final repo = ref.watch(streaksRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return StreaksController(repo, authState);
});

class StreaksController extends StateNotifier<StreaksState> {
  final StreaksRepository _repo;
  final AppAuthState _authState;

  StreaksController(this._repo, this._authState)
      : super(const StreaksLoading()) {
    loadGamificationData();
  }

  Future<void> loadGamificationData() async {
    state = const StreaksLoading();
    final auth = _authState;
    if (auth is! Authenticated) {
      state = const StreaksError('Student is unauthenticated.');
      return;
    }

    final userId = auth.profile.id;
    try {
      final summary = await _repo.fetchGamificationSummary(userId);
      state = StreaksLoaded(summary);
    } catch (e) {
      state = StreaksError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> refresh() async => loadGamificationData();
}
