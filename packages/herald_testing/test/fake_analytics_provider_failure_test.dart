import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:test/test.dart';

import 'test_events.dart';

/// The message of the [TestFailure] that [assertion] throws.
String _failureOf(void Function() assertion) {
  try {
    assertion();
  } on TestFailure catch (failure) {
    return failure.message ?? '';
  }
  fail('Expected the assertion to fail.');
}

/// Every assertion must fail when it should, and say why.
void main() {
  late FakeAnalyticsProvider analytics;

  setUp(() => analytics = FakeAnalyticsProvider());

  test('assertTracked fails for a missing event, and shows what was tracked', () async {
    await analytics.track(const TestEvent('cart_viewed'));

    final message = _failureOf(() => analytics.assertTracked('checkout_started'));

    expect(message, contains('checkout_started'));
    expect(message, contains('cart_viewed'));
  });

  test('assertTracked fails for a duplicate, and points to assertTrackedTimes', () async {
    await analytics.track(const TestEvent('checkout_started'));
    await analytics.track(const TestEvent('checkout_started'));

    final message = _failureOf(() => analytics.assertTracked('checkout_started'));

    expect(message, contains('2 were tracked'));
    expect(message, contains('assertTrackedTimes'));
  });

  test('param fails for a missing parameter', () async {
    await analytics.track(const TestEvent('checkout_started', {'plan': .string('pro')}));

    final message = _failureOf(
      () => analytics.assertTracked('checkout_started', (event) => event.param('seats', 3)),
    );

    expect(message, contains('seats'));
  });

  test('param fails when a number was sent as text', () async {
    await analytics.track(const TestEvent('checkout_started', {'seats': .string('3')}));

    final message = _failureOf(
      () => analytics.assertTracked('checkout_started', (event) => event.param('seats', 3)),
    );

    expect(message, contains('AnalyticsInt(3)'));
    expect(message, contains('AnalyticsString(3)'));
  });

  test('param refuses a value that is not an analytics value', () async {
    await analytics.track(const TestEvent('typed', {'count': .int(3)}));

    expect(
      () => analytics.assertTracked('typed', (event) => event.param('count', const [3])),
      throwsArgumentError,
    );
  });

  test('noParameters fails for an event with parameters', () async {
    await analytics.track(const TestEvent('checkout_started', {'plan': .string('pro')}));

    final message = _failureOf(
      () => analytics.assertTracked('checkout_started', (event) => event.noParameters()),
    );

    expect(message, contains('plan'));
  });

  test('assertNothingElseTracked fails for an event nobody checked', () async {
    await analytics.track(const TestEvent('checkout_started'));
    await analytics.track(const TestEvent('debug_ping'));

    analytics.assertTracked('checkout_started');
    final message = _failureOf(analytics.assertNothingElseTracked);

    expect(message, contains('debug_ping'));
  });

  test('assertNothingElseTracked passes once every event was checked', () async {
    await analytics.track(const TestEvent('checkout_started'));
    await analytics.track(const TestEvent('cart_viewed'));
    await analytics.track(const TestEvent('cart_viewed'));

    analytics
      ..assertTracked('checkout_started')
      ..assertTrackedTimes('cart_viewed', 2)
      ..assertNothingElseTracked();
  });

  test('assertTrackedTimes fails for the wrong count', () async {
    await analytics.track(const TestEvent('checkout_started'));

    final message = _failureOf(() => analytics.assertTrackedTimes('checkout_started', 2));

    expect(message, contains('2 times'));
    expect(message, contains('1 times'));
  });

  test('assertNotTracked and assertNothingTracked fail when something was tracked', () async {
    await analytics.track(const TestEvent('checkout_started'));

    _failureOf(() => analytics.assertNotTracked('checkout_started'));
    _failureOf(analytics.assertNothingTracked);
  });

  test('assertPropertySet fails for another value, and names it', () async {
    await analytics.set(const TestProperty('total_purchases', AnalyticsInt(41)));

    final message = _failureOf(
      () => analytics.assertPropertySet('total_purchases', const AnalyticsInt(42)),
    );

    expect(message, contains('AnalyticsInt(41)'));
  });

  test('assertPropertySet fails when the right value was overwritten, and shows both', () async {
    await analytics.set(const TestProperty('plan', AnalyticsString('pro')));
    await analytics.set(const TestProperty('plan', AnalyticsString('free')));

    final message = _failureOf(() => analytics.assertPropertySet('plan', 'pro'));

    expect(message, contains('AnalyticsString(pro) then AnalyticsString(free)'));
  });

  test('assertPropertySet fails when a number was set as text', () async {
    await analytics.set(const TestProperty('seats', AnalyticsString('3')));

    final message = _failureOf(() => analytics.assertPropertySet('seats', 3));

    expect(message, contains('AnalyticsInt(3)'));
    expect(message, contains('AnalyticsString(3)'));
  });

  test('assertPropertySet fails for a property that was never set', () async {
    await analytics.set(const TestProperty('plan', AnalyticsString('pro')));

    final message = _failureOf(
      () => analytics.assertPropertySet('total_purchases', const AnalyticsInt(42)),
    );

    expect(message, contains('never was'));
    expect(message, contains('plan'));
  });

  test('assertIdentified fails for another user', () async {
    await analytics.identify(const Identity('user-2'));

    final message = _failureOf(() => analytics.assertIdentified('user-1'));

    expect(message, contains('user-1'));
    expect(message, contains('user-2'));
  });

  test('a failure lists every kind of call, in order', () async {
    await analytics.start();
    await analytics.identify(const Identity('user-1'));
    await analytics.set(const TestProperty('plan', AnalyticsString('pro')));
    await analytics.track(const TestEvent('cart_viewed', {'items': .int(2)}));
    await analytics.setEnabled(false);
    await analytics.flush();
    await analytics.reset();

    final message = _failureOf(() => analytics.assertTracked('checkout_started'));

    expect(
      message.substring(message.indexOf('Recorded:\n') + 'Recorded:\n'.length),
      [
        '  1. start',
        '  2. identify user-1',
        '  3. property plan = pro',
        '  4. event    cart_viewed { items = 2 }',
        '  5. enabled  false',
        '  6. flush',
        '  7. reset',
      ].join('\n'),
    );
  });

  test('a failure with nothing recorded says so', () {
    final message = _failureOf(() => analytics.assertTracked('checkout_started'));

    expect(message, contains('nothing was recorded'));
  });
}
