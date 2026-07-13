// Basic widget test for AeroDry app.

import 'package:flutter_test/flutter_test.dart';
import 'package:aerodry_app/main.dart';
import 'package:aerodry_app/screens/dashboard_screen.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AeroDryApp());

    // Verify that the app launches without errors.
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
