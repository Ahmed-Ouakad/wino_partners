import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wino_partners/injection_container.dart' as di;
import 'package:wino_partners/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('MyApp builds successfully smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isAuthenticated: false));

    // Verify that MaterialApp is created
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
