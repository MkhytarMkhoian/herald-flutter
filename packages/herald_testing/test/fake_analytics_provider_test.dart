import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:test/test.dart';

import 'test_events.dart';

void main() {
  late FakeAnalyticsProvider analytics;

  setUp(() => analytics = FakeAnalyticsProvider());

  group('records', () {
    test('every call goes into one list, in order', () async {
      await analytics.start();
      await analytics.identify(const Identity('user-1'));
      await analytics.set(const TestProperty('plan', AnalyticsString('pro')));
      await analytics.track(const TestEvent('checkout_started'));
      await analytics.setEnabled(false);
      await analytics.flush();
      await analytics.reset();

      expect(analytics.records, [
        const StartedRecord(),
        const IdentifiedRecord(Identity('user-1')),
        PropertySetRecord(analytics.properties.single),
        TrackedRecord(analytics.events.single),
        const EnabledSetRecord(false),
        const FlushedRecord(),
        const ResetRecord(),
      ]);
    });

    test('the order across kinds can be checked', () async {
      await analytics.set(const TestProperty('plan', AnalyticsString('pro')));
      await analytics.track(const TestEvent('checkout_started'));

      expect(analytics.records, [isA<PropertySetRecord>(), isA<TrackedRecord>()]);
    });

    test('records are equal by kind and content, const or not', () {
      const event = TestEvent('a');

      expect(const TrackedRecord(event), const TrackedRecord(event));
      expect(const EnabledSetRecord(true), isNot(const EnabledSetRecord(false)));
      // ignore: prefer_const_constructors
      expect(ResetRecord(), const ResetRecord());
      expect(const StartedRecord(), isNot(const FlushedRecord()));
    });

    test('a list of records stays as it was when read', () async {
      await analytics.track(const TestEvent('first'));
      final snapshot = analytics.records;

      await analytics.track(const TestEvent('second'));

      expect(snapshot, hasLength(1));
      expect(analytics.records, hasLength(2));
    });

    test('clear forgets the records and what was already asserted', () async {
      await analytics.track(const TestEvent('checkout_started'));
      analytics.assertTracked('checkout_started');

      analytics.clear();

      analytics
        ..assertNothingTracked()
        ..assertNothingElseTracked();
    });
  });

  group('passing assertions', () {
    test('assertTracked compares parameters by type, not by their text', () async {
      await analytics.track(
        const TestEvent('checkout_started', {
          'plan': .string('pro'),
          'seats': .int(3),
          'price': .double(3.5),
          'trial': .bool(false),
        }),
      );

      analytics.assertTracked(
        'checkout_started',
        (event) => event
          ..param('plan', 'pro')
          ..param('seats', 3)
          ..param('price', 3.5)
          ..param('trial', false)
          ..param('seats', const AnalyticsInt(3)),
      );
    });

    test('the tracked event itself is there for custom checks', () async {
      await analytics.track(const TestEvent('checkout_started'));

      analytics.assertTracked(
        'checkout_started',
        (event) => expect(event.event, const TestEvent('checkout_started')),
      );
    });

    test('noParameters passes on an event without parameters', () async {
      await analytics.track(const TestEvent('checkout_started'));

      analytics.assertTracked('checkout_started', (event) => event.noParameters());
    });

    test('assertNotTracked passes when the event is missing', () async {
      await analytics.track(const TestEvent('cart_viewed'));

      analytics.assertNotTracked('checkout_started');
    });

    test('assertTrackedTimes accepts zero', () async {
      await analytics.track(const TestEvent('cart_viewed'));

      analytics.assertTrackedTimes('checkout_started', 0);
    });

    test('event assertions ignore calls that are not events', () async {
      await analytics.start();
      await analytics.set(const TestProperty('plan', AnalyticsString('pro')));
      await analytics.identify(const Identity('user-1'));

      analytics
        ..assertNothingTracked()
        ..assertNothingElseTracked();
    });

    test('assertPropertySet checks the last value, by type', () async {
      await analytics.set(const TestProperty('plan', AnalyticsString('free')));
      await analytics.set(const TestProperty('plan', AnalyticsString('pro')));
      await analytics.set(const TestProperty('seats', AnalyticsInt(3)));

      analytics
        ..assertPropertySet('plan', 'pro')
        ..assertPropertySet('seats', 3)
        ..assertPropertySet('seats', const AnalyticsInt(3));
    });

    test('assertIdentified passes even after a later reset', () async {
      await analytics.identify(const Identity('user-1'));
      await analytics.reset();

      analytics.assertIdentified('user-1');
    });
  });
}
