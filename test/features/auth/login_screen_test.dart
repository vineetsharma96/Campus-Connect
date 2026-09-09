import 'package:campus/features/auth/domain/auth_state_model.dart';
import 'package:campus/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campus/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthController extends StateNotifier<AppAuthState>
    implements AuthController {
  FakeAuthController([super.initialState = const Unauthenticated()]);

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('Validation triggers on empty login fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith((ref) => FakeAuthController()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    expect(signInButton, findsOneWidget);

    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
