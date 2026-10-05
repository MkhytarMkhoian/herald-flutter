import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald_docs_samples/guides/screen_views.dart';
import 'package:herald_testing/herald_testing.dart';

void main() {
  testWidgets('the settings page tracks its own screen view when it opens', (tester) async {
    final analytics = FakeAnalyticsProvider();

    await tester.pumpWidget(MaterialApp(home: SettingsPage(analytics)));

    analytics
      ..assertTracked('settings')
      ..assertNothingElseTracked();
  });
}
