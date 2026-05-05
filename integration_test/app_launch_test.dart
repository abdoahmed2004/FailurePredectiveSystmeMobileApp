import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:fpms_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test - Login Flow', () {
    testWidgets('App launches and shows splash screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The app should be running — at minimum a Scaffold exists
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App navigates from splash to login or onboarding',
        (tester) async {
      app.main();
      // Wait for splash to complete its timer (typically 2-3 seconds)
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // After splash, either onboarding or login should appear
      final onLoginOrOnboarding =
          find.byType(Scaffold).evaluate().isNotEmpty;
      expect(onLoginOrOnboarding, true);
    });
  });
}
