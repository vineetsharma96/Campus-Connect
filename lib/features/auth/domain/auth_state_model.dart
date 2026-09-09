import '../../../core/models/user_profile.dart';

sealed class AppAuthState {
  const AppAuthState();
}

class AuthInitial extends AppAuthState {
  const AuthInitial();
}

class AuthLoading extends AppAuthState {
  const AuthLoading();
}

class Authenticated extends AppAuthState {
  final UserProfile profile;
  const Authenticated(this.profile);
}

class Unauthenticated extends AppAuthState {
  const Unauthenticated();
}

class AuthFailure extends AppAuthState {
  final String message;
  const AuthFailure(this.message);
}
