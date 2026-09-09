import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_data.dart';

sealed class DashboardState {
  const DashboardState();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  const DashboardLoaded(this.data);
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return DashboardController(repo, authState);
});

class DashboardController extends StateNotifier<DashboardState> {
  final DashboardRepository _repository;
  final AppAuthState _authState;

  DashboardController(this._repository, this._authState)
      : super(const DashboardLoading()) {
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    state = const DashboardLoading();
    final auth = _authState;
    if (auth is! Authenticated) {
      state = const DashboardError('User is not authenticated.');
      return;
    }

    final userId = auth.profile.id;
    try {
      final summary = await _repository.fetchDashboardSummary(userId);
      state = DashboardLoaded(summary);
    } catch (_) {
      state = const DashboardError(
        'Unable to refresh dashboard metrics right now. Pull down to retry.',
      );
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
