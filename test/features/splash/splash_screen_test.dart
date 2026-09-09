import 'package:campus/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashScreen renders title and subtitle correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.text('CAMPUS'), findsOneWidget);
    expect(find.text('INSTITUTE OS'), findsOneWidget);
    expect(find.byIcon(Icons.school_rounded), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
