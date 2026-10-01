import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald_example/analytics/herald_setup.dart';
import 'package:herald_example/analytics/timeline_analytics.dart';
import 'package:herald_example/main.dart';

void main() {
  testWidgets('screen views reach the timeline as the user navigates', (tester) async {
    final timeline = TimelineAnalytics();
    final herald = buildHerald(timeline);

    await tester.pumpWidget(HeraldExampleApp(herald: herald, timeline: timeline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('week_pass'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(timeline.lines, ['screen home', 'screen product  product_id=week_pass', 'screen home']);
  });
}
