import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/attendance_repository.dart';
import '../../domain/attendance_models.dart';

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final OverallAttendanceSummary summary;
  const AttendanceLoaded(this.summary);
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
}

final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return AttendanceController(repo, authState);
});

class AttendanceController extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repo;
  final AppAuthState _authState;

  AttendanceController(this._repo, this._authState)
      : super(const AttendanceLoading()) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    state = const AttendanceLoading();
    final authState = _authState;
    if (authState is! Authenticated) {
      state = const AttendanceError('Authentication session not active.');
      return;
    }

    final userId = authState.profile.id;
    try {
      final summary = await _repo.fetchStudentAttendance(userId);
      state = AttendanceLoaded(summary);
    } catch (e) {
      state = AttendanceError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> refresh() async => loadAttendance();
}
