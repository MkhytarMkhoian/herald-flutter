import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald_docs_samples/guides/widgets.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:herald_widgets/herald_widgets.dart';

void main() {
  // --8<-- [start:test]
  testWidgets('the product page reports its screen view', (tester) async {
    final analytics = FakeAnalyticsProvider();
    final routes = HeraldRouteObserver();

    await tester.pumpWidget(
      HeraldScope(
        analytics: analytics,
        routes: routes,
        child: MaterialApp(navigatorObservers: [routes], home: const ProductPage('day_pass')),
      ),
    );
    await tester.pump();

    analytics.assertTracked('product', (event) => event.param('product_id', 'day_pass'));
  });
  // --8<-- [end:test]
}
