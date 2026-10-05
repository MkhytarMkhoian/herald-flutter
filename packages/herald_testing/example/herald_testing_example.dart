import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:test/test.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

final class const CheckoutViewModel(final EventTrackerService analytics) {
  Future<void> start(String plan, int seats) => analytics.track(CheckoutStarted(plan, seats));
}

void main() {
  test('checkout reports the plan and seats, once', () async {
    final analytics = FakeAnalyticsProvider();

    await CheckoutViewModel(analytics).start('pro', 3);

    analytics
      ..assertTracked(
        'checkout_started',
        (event) => event
          ..param('plan', 'pro')
          ..param('seats', 3),
      )
      ..assertNothingElseTracked();
  });
}
