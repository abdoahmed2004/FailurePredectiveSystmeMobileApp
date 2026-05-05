import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpms_app/Screens/splash_screen.dart';
import 'package:fpms_app/Screens/onboarding_screen.dart';
import 'package:fpms_app/Screens/Register_screen.dart';

void main() {
  // ─────────────────────────────────────────────────────────
  // SPLASH SCREEN
  // ─────────────────────────────────────────────────────────
  group('SplashScreen - Widget Tests', () {
    testWidgets('SplashScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('SplashScreen has a Scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────
  // ONBOARDING SCREEN
  // ─────────────────────────────────────────────────────────
  group('OnboardingScreen - Widget Tests', () {
    testWidgets('OnboardingScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen()),
      );
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('OnboardingScreen has a Scaffold', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OnboardingScreen()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────
  // REGISTER SCREEN
  // ─────────────────────────────────────────────────────────
  group('RegisterScreen - Widget Tests', () {
    testWidgets('RegisterScreen renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('RegisterScreen has text fields for registration',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );
      // Should have multiple input fields: name, email, password, etc.
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('RegisterScreen has a register/submit button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterScreen()),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
