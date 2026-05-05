import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpms_app/Screens/Login_screen.dart';

void main() {
  group('LoginScreen - Widget Tests', () {
    // Helper to wrap the screen properly
    Widget buildTestApp() {
      return const MaterialApp(
        home: LoginScreen(),
      );
    }

    // ✅ Test 1: Screen renders without crashing
    testWidgets('LoginScreen renders without crashing', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    // ✅ Test 2: Email and Password fields are present
    testWidgets('LoginScreen has email and password TextFields', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // There should be 2 TextField widgets: email + password
      expect(find.byType(TextField), findsNWidgets(2));
    });

    // ✅ Test 3: "Welcome back!" text is visible
    testWidgets('LoginScreen shows Welcome back! text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    // ✅ Test 4: "Please login to your account" subtitle is visible
    testWidgets('LoginScreen shows subtitle text', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.text('Please login to your account'), findsOneWidget);
    });

    // ✅ Test 5: Continue button is present
    testWidgets('LoginScreen has a Continue button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.widgetWithText(ElevatedButton, 'Continue'), findsOneWidget);
    });

    // ✅ Test 6: Forgot password button is present
    testWidgets('LoginScreen has Forgot password? button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.text('Forgot password?'), findsOneWidget);
    });

    // ✅ Test 7: Register button is present
    testWidgets('LoginScreen has Register button', (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.text('Register'), findsOneWidget);
    });

    // ✅ Test 8: Empty form submit shows SnackBar error
    testWidgets('LoginScreen shows error SnackBar on empty submit',
        (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Tap Continue without entering any data
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pump(); // trigger state rebuild

      // Expect the error snackbar
      expect(
        find.text('Please enter both email and password.'),
        findsOneWidget,
      );
    });

    // ✅ Test 9: Password field has visibility toggle icon
    testWidgets('LoginScreen has password visibility toggle icon',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    // ✅ Test 10: Tapping visibility icon changes the icon
    testWidgets('Password visibility toggles on icon tap', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Initially shows visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap the icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Now should show visibility (password visible)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    // ✅ Test 11: Remember me checkbox is present and toggleable
    testWidgets('Remember me checkbox exists and can be toggled', (tester) async {
      await tester.pumpWidget(buildTestApp());

      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Tap the checkbox
      await tester.tap(checkbox);
      await tester.pump();

      final Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, true);
    });

    // ✅ Test 12: Google and Apple social buttons are visible
    testWidgets('LoginScreen shows Google and Apple login buttons',
        (tester) async {
      await tester.pumpWidget(buildTestApp());
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
    });
  });
}
