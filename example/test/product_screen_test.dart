import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_example/screens/product_screen.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:herald_widgets/herald_widgets.dart';

void main() {
  testWidgets('buying reports the purchase count, then the order with its total', (tester) async {
    final analytics = FakeAnalyticsProvider();
    final herald = Herald(
      providers: [HeraldProvider(name: 'test', events: analytics, properties: analytics)],
    );
    final routes = HeraldRouteObserver();
    await tester.pumpWidget(
      HeraldScope(
        analytics: herald,
        routes: routes,
        child: MaterialApp(
          navigatorObservers: [routes],
          home: ProductScreen(productId: 'day_pass', analytics: herald, properties: herald),
        ),
      ),
    );

    await tester.tap(find.text('Add to cart'));
    await tester.tap(find.text('Add to cart'));
    await tester.pump();
    await tester.tap(find.text('Buy 2'));
    await tester.pumpAndSettle();

    analytics
      ..assertTracked('product', (event) => event.param('product_id', 'day_pass'))
      ..assertTrackedTimes('added_to_cart', 2)
      ..assertTracked(
        'order_paid',
        (event) => event
          ..param('items', 2)
          ..param('total', 9.98),
      )
      ..assertNothingElseTracked()
      ..assertPropertySet('total_purchases', 1);
  });
}
