import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../academic/domain/academic_models.dart';
import '../../../auth/domain/auth_state_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../events/domain/club_event_models.dart';
import '../../../notices/domain/notice_models.dart';
import '../../data/institute_admin_repository.dart';
import '../../domain/admin_models.dart';

sealed class InstituteAdminState {
  const InstituteAdminState();
}

class AdminLoading extends InstituteAdminState {
  const AdminLoading();
}

class AdminLoaded extends InstituteAdminState {
  final List<NoticeItem> notices;
  final List<FacultyMember> faculty;
  final List<CandidateStudent> students;
  final List<ClubItem> clubs;
  final int activeTab;

  const AdminLoaded({
    required this.notices,
    required this.faculty,
    required this.students,
    required this.clubs,
    this.activeTab = 0,
  });

  AdminLoaded copyWith({
    List<NoticeItem>? notices,
    List<FacultyMember>? faculty,
    List<CandidateStudent>? students,
    List<ClubItem>? clubs,
    int? activeTab,
  }) {
    return AdminLoaded(
      notices: notices ?? this.notices,
      faculty: faculty ?? this.faculty,
      students: students ?? this.students,
      clubs: clubs ?? this.clubs,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class AdminUnauthorized extends InstituteAdminState {
  final String message;
  const AdminUnauthorized(this.message);
}

class AdminError extends InstituteAdminState {
  final String message;
  const AdminError(this.message);
}

final instituteAdminControllerProvider =
    StateNotifierProvider<InstituteAdminController, InstituteAdminState>((ref) {
  final repo =
      ref.watch<InstituteAdminRepository>(instituteAdminRepositoryProvider);
  final authState = ref.watch(authControllerProvider);
  return InstituteAdminController(repo, authState);
});

class InstituteAdminController extends StateNotifier<InstituteAdminState> {
  final InstituteAdminRepository _repo;
  final AppAuthState _authState;

  InstituteAdminController(this._repo, this._authState)
      : super(const AdminLoading()) {
    loadAdminData();
  }

  Future<void> loadAdminData() async {
    state = const AdminLoading();
    if (_authState is! Authenticated) {
      state = const AdminUnauthorized('Authentication required.');
      return;
    }

    try {
      final results = await Future.wait<dynamic>([
        _repo.fetchNotices(),
        _repo.fetchFaculty(),
        _repo.fetchCandidateStudents(),
        _repo.fetchClubs(),
      ]);

      state = AdminLoaded(
        notices: results[0] as List<NoticeItem>,
        faculty: results[1] as List<FacultyMember>,
        students: results[2] as List<CandidateStudent>,
        clubs: results[3] as List<ClubItem>,
      );
    } catch (e) {
      state = AdminError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void setActiveTab(int index) {
    if (state is AdminLoaded) {
      final current = state as AdminLoaded;
      state = current.copyWith(activeTab: index);
    }
  }

  Future<bool> saveNotice(NoticePayload payload) async {
    final auth = _authState;
    if (auth is! Authenticated || state is! AdminLoaded) return false;
    final current = state as AdminLoaded;
    final adminId = auth.profile.id;

    try {
      await _repo.saveNotice(payload, adminId);
      final refreshed = await _repo.fetchNotices();
      state = current.copyWith(notices: refreshed);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteNotice(String id) async {
    if (state is! AdminLoaded) return;
    final current = state as AdminLoaded;

    try {
      await _repo.deleteNotice(id);
      final refreshed = await _repo.fetchNotices();
      state = current.copyWith(notices: refreshed);
    } catch (_) {}
  }

  Future<bool> saveFaculty(FacultyPayload payload) async {
    if (state is! AdminLoaded) return false;
    final current = state as AdminLoaded;

    try {
      await _repo.saveFaculty(payload);
      final refreshed = await _repo.fetchFaculty();
      state = current.copyWith(faculty: refreshed);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteFaculty(String id) async {
    if (state is! AdminLoaded) return;
    final current = state as AdminLoaded;

    try {
      await _repo.deleteFaculty(id);
      final refreshed = await _repo.fetchFaculty();
      state = current.copyWith(faculty: refreshed);
    } catch (_) {}
  }

  Future<bool> assignClubAdmin(String userId, String clubId) async {
    if (state is! AdminLoaded) return false;
    final current = state as AdminLoaded;

    try {
      await _repo.assignClubAdmin(userId, clubId);
      final refreshedStudents = await _repo.fetchCandidateStudents();
      state = current.copyWith(students: refreshedStudents);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> revokeClubAdmin(String userId) async {
    if (state is! AdminLoaded) return false;
    final current = state as AdminLoaded;

    try {
      await _repo.revokeClubAdmin(userId);
      final refreshedStudents = await _repo.fetchCandidateStudents();
      state = current.copyWith(students: refreshedStudents);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async => loadAdminData();
}
