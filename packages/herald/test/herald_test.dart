import 'dart:async';

import 'package:herald/herald.dart';
import 'package:test/test.dart';

import 'support.dart';

const _event = TestEvent('an_event');
const _property = TestProperty('a_property', AnalyticsString('pro'));
const _identity = Identity('user-1');

/// A provider with every capability, and one that only takes events.
Herald _herald(
  RecordingService analytics,
  RecordingService attribution,
  List<AnalyticsFailure> failures,
) => Herald(
  providers: [
    HeraldProvider(
      name: 'analytics',
      events: analytics,
      properties: analytics,
      identity: analytics,
      lifecycle: analytics,
      consent: analytics,
    ),
    HeraldProvider(name: 'attribution', events: attribution),
  ],
  errorReporter: failures.add,
);

void main() {
  late RecordingService analytics;
  late RecordingService attribution;
  late List<AnalyticsFailure> failures;
  late Herald herald;

  setUp(() {
    analytics = RecordingService();
    attribution = RecordingService();
    failures = [];
    herald = _herald(analytics, attribution, failures);
  });

  group('calls', () {
    test('track reaches every provider that takes events', () async {
      await herald.track(_event);

      expect(analytics.received, ['track an_event']);
      expect(attribution.received, ['track an_event']);
    });

    test('set skips a provider without properties', () async {
      await herald.set(_property);

      expect(analytics.received, ['set a_property']);
      expect(attribution.received, isEmpty);
    });

    test('identify and reset reach only providers with identity', () async {
      await herald.identify(_identity);
      await herald.reset();

      expect(analytics.received, ['identify user-1', 'reset']);
      expect(attribution.received, isEmpty);
    });

    test('start and flush reach only providers with a lifecycle', () async {
      await herald.start();
      await herald.flush();

      expect(analytics.received, ['start', 'flush']);
      expect(attribution.received, isEmpty);
    });

    test('setEnabled reaches only providers with consent', () async {
      await herald.setEnabled(true);

      expect(analytics.received, ['enabled true']);
      expect(attribution.received, isEmpty);
    });

    test('a provider with only consent is called', () async {
      final herald = Herald(
        providers: [HeraldProvider(name: 'analytics', consent: analytics)],
      );

      await herald.setEnabled(false);

      expect(analytics.received, ['enabled false']);
    });

    test('a decorator keeps an event from one provider only', () async {
      final herald = Herald(
        providers: [
          HeraldProvider(name: 'analytics', events: analytics),
          HeraldProvider(
            name: 'attribution',
            events: TestEventTracker((event) async {
              if (event.name != 'an_event') await attribution.track(event);
            }),
          ),
        ],
      );

      await herald.track(_event);

      expect(analytics.received, ['track an_event']);
      expect(attribution.received, isEmpty);
    });

    // 'slow' waits for 'attribution', so calling providers one by one would hang.
    test('providers run at the same time, not one after another', () async {
      final attributionCalled = Completer<void>();
      final herald = Herald(
        providers: [
          HeraldProvider(name: 'slow', events: TestEventTracker((_) => attributionCalled.future)),
          HeraldProvider(
            name: 'attribution',
            events: TestEventTracker((_) async => attributionCalled.complete()),
          ),
        ],
      );

      await herald.track(_event).timeout(const Duration(seconds: 5));
    });

    test("calls don't wait for each other, and a slow vendor doesn't hold up others", () async {
      final slow = <String>[];
      final fast = <String>[];
      final gate = Completer<void>();
      final herald = Herald(
        providers: [
          HeraldProvider(
            name: 'slow',
            events: TestEventTracker((event) async {
              await gate.future;
              slow.add(event.name);
            }),
          ),
          HeraldProvider(
            name: 'fast',
            events: TestEventTracker((event) async => fast.add(event.name)),
            identity: RecordingService(fast),
          ),
        ],
      );

      final calls = [
        herald.track(const TestEvent('a')),
        herald.track(const TestEvent('b')),
        herald.identify(_identity),
      ];
      await Future<void>.delayed(Duration.zero);

      expect(fast, ['a', 'b', 'identify user-1']);
      expect(slow, isEmpty);

      gate.complete();
      await Future.wait(calls);
      expect(slow, ['a', 'b']);
    });
  });

  group('failures', () {
    test("a failing vendor doesn't stop the others, and is reported", () async {
      final error = StateError('analytics is down');
      analytics.failure = error;

      await herald.track(_event);

      expect(attribution.received, ['track an_event']);
      final failure = failures.single;
      expect(failure.provider, 'analytics');
      expect(failure.operation, const TrackOperation('an_event'));
      expect(failure.error, same(error));
    });

    test('a vendor that throws before returning a future is caught too', () async {
      final herald = Herald(
        providers: [
          HeraldProvider(
            name: 'sync',
            events: TestEventTracker((_) => throw ArgumentError('thrown before any future')),
          ),
          HeraldProvider(name: 'attribution', events: attribution),
        ],
        errorReporter: failures.add,
      );

      await herald.track(_event);

      expect(attribution.received, ['track an_event']);
      expect(failures.single.error, isA<ArgumentError>());
    });

    test('the report carries the stack trace', () async {
      analytics.failure = StateError('analytics is down');

      await herald.track(_event);

      expect(failures.single.stackTrace.toString(), contains('support.dart'));
    });

    test('the report names the event that failed', () async {
      await herald.track(_event);
      analytics.failure = StateError('bad name');
      await herald.track(const TestEvent('other_event'));

      expect(failures.map((failure) => failure.operation), [const TrackOperation('other_event')]);
    });

    test('the report names the property that failed', () async {
      analytics.failure = StateError('nope');

      await herald.set(_property);

      expect(failures.single.operation, const SetPropertyOperation('a_property'));
    });

    test('failures are reported in registration order, whatever order they happen in', () async {
      final releaseFirst = Completer<void>();
      final herald = Herald(
        providers: [
          HeraldProvider(
            name: 'first',
            events: TestEventTracker((_) async {
              await releaseFirst.future;
              throw StateError('first is down');
            }),
          ),
          HeraldProvider(
            name: 'second',
            events: TestEventTracker((_) async => throw StateError('second is down')),
          ),
        ],
        errorReporter: failures.add,
      );

      final call = herald.track(_event);
      await Future<void>.delayed(Duration.zero); // 'second' has failed by now
      releaseFirst.complete();
      await call;

      expect(failures.map((failure) => failure.provider), ['first', 'second']);
    });

    test('without a reporter, failures are dropped and the call still completes', () async {
      analytics.failure = StateError('analytics is down');
      final herald = Herald(
        providers: [HeraldProvider(name: 'analytics', events: analytics)],
      );

      await expectLater(herald.track(_event), completes);
    });

    test("a reporter that throws doesn't reach the caller", () async {
      analytics.failure = StateError('analytics is down');
      final herald = Herald(
        providers: [
          HeraldProvider(name: 'analytics', events: analytics),
          HeraldProvider(name: 'attribution', events: attribution),
        ],
        errorReporter: (_) => throw StateError('the crash reporter is down'),
      );

      await herald.track(_event);

      expect(attribution.received, ['track an_event']);
    });

    test('a reporter that throws for one failure still gets the next', () async {
      analytics.failure = StateError('analytics is down');
      attribution.failure = StateError('attribution is down');
      final seen = <String>[];
      final herald = Herald(
        providers: [
          HeraldProvider(name: 'analytics', events: analytics),
          HeraldProvider(name: 'attribution', events: attribution),
        ],
        errorReporter: (failure) {
          seen.add(failure.provider);
          if (failure.provider == 'analytics') throw StateError('the crash reporter is down');
        },
      );

      await herald.track(_event);

      expect(seen, ['analytics', 'attribution']);
    });

    test('a reporter whose future fails is caught too', () async {
      analytics.failure = StateError('analytics is down');
      final reported = <String>[];
      final herald = Herald(
        providers: [HeraldProvider(name: 'analytics', events: analytics)],
        errorReporter: (failure) async {
          reported.add(failure.provider);
          throw StateError('the crash reporter is down');
        },
      );

      await herald.track(_event);
      // Lets the reporter's failed future settle; an escaped error would fail this test.
      await Future<void>.delayed(Duration.zero);

      expect(reported, ['analytics']);
    });

    test("a call doesn't wait for the reporter", () async {
      analytics.failure = StateError('analytics is down');
      final herald = Herald(
        providers: [HeraldProvider(name: 'analytics', events: analytics)],
        errorReporter: (_) => Completer<void>().future,
      );

      await herald.track(_event).timeout(const Duration(seconds: 5));
    });
  });

  group('setup', () {
    test('a provider without capabilities is refused', () {
      expect(
        () => HeraldProvider(name: 'empty'),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', contains('no capabilities')),
        ),
      );
    });

    test('a provider with a blank name is refused', () {
      expect(() => HeraldProvider(name: ' ', events: analytics), throwsArgumentError);
    });

    test('two providers with the same name are refused', () {
      expect(
        () => Herald(
          providers: [
            HeraldProvider(name: 'analytics', events: analytics),
            HeraldProvider(name: 'analytics', events: attribution),
          ],
        ),
        throwsA(
          isA<ArgumentError>().having((e) => e.message, 'message', contains("named 'analytics'")),
        ),
      );
    });
  });
}
