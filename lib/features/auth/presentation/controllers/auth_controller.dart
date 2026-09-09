import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../data/auth_repository.dart';
import '../../domain/auth_state_model.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AppAuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController extends StateNotifier<AppAuthState> {
  final AuthRepository _repository;
  StreamSubscription<supa.AuthState>? _subscription;

  AuthController(this._repository) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    _subscription = _repository.authStateChanges.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _loadProfile();
      } else {
        state = const Unauthenticated();
      }
    });

    if (_repository.currentUser != null) {
      _loadProfile();
    } else {
      state = const Unauthenticated();
    }
  }

  Future<void> _loadProfile() async {
    state = const AuthLoading();
    try {
      final profile = await _repository.getCurrentUserProfile();
      if (profile != null) {
        state = Authenticated(profile);
      } else {
        state =
            const AuthFailure('User profile not found. Contact administrator.');
      }
    } catch (_) {
      state =
          const AuthFailure('Unable to load profile. Check your connection.');
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      await _repository.signInWithEmail(email: email, password: password);
    } on supa.AuthException catch (e) {
      state = AuthFailure(e.message);
    } catch (_) {
      state = const AuthFailure('Connection error. Please try again.');
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    try {
      await _repository.signOut();
      state = const Unauthenticated();
    } catch (_) {
      state = const Unauthenticated();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
