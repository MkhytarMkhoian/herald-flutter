import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:test/test.dart';

import 'test_events.dart';

/// Keeps `debug_ping` away from [inner].
final class const ExceptDebugPing(final EventTrackerService inner) implements EventTrackerService {
  @override
  Future<void> track(Event event) async {
    if (event.name != 'debug_ping') await inner.track(event);
  }
}

/// The fake as a real provider, so the test runs through a real `Herald`.
void main() {
  late FakeAnalyticsProvider analytics;

  setUp(() => analytics = FakeAnalyticsProvider());

  test('an event tracked through Herald reaches the fake', () async {
    final herald = Herald(
      providers: [HeraldProvider(name: 'test', events: analytics, properties: analytics)],
    );

    await herald.track(const TestEvent('checkout_started', {'plan': .string('pro')}));

    analytics
      ..assertTracked('checkout_started', (event) => event.param('plan', 'pro'))
      ..assertNothingElseTracked();
  });

  test('a decorator shows in what the fake did not get', () async {
    final herald = Herald(
      providers: [HeraldProvider(name: 'test', events: ExceptDebugPing(analytics))],
    );

    await herald.track(const TestEvent('checkout_started'));
    await herald.track(const TestEvent('debug_ping'));

    analytics
      ..assertTracked('checkout_started')
      ..assertNotTracked('debug_ping')
      ..assertNothingElseTracked();
  });
}
