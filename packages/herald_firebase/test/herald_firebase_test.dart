import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_firebase/herald_firebase.dart';
import 'package:mocktail/mocktail.dart';

import 'support.dart';

final class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockFirebaseAnalytics analytics;

  setUp(() {
    analytics = MockFirebaseAnalytics();
    when(
      () => analytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logScreenView(
        screenName: any(named: 'screenName'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.setUserProperty(
        name: any(named: 'name'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
    when(() => analytics.setUserId(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => analytics.setAnalyticsCollectionEnabled(any())).thenAnswer((_) async {});
  });

  group('parameters', () {
    test('numbers stay numbers and flags become text, since GA4 has no boolean type', () {
      const parameters = <String, AnalyticsValue>{
        'plan': .string('pro'),
        'seats': .int(3),
        'price': .double(9.99),
        'trial': .bool(false),
      };

      expect(parameters.toFirebaseParameters(), {
        'plan': 'pro',
        'seats': 3,
        'price': 9.99,
        'trial': 'false',
      });
    });
  });

  group('trackers', () {
    test('the generic tracker logs the event under its own name', () async {
      await GenericFirebaseEventTracker(
        const TestEvent('checkout_started', {'seats': .int(3)}),
        analytics,
      ).track();

      verify(() => analytics.logEvent(name: 'checkout_started', parameters: {'seats': 3}))
          .called(1);
    });

    test('a screen view is logged as screen_view, with its name as the screen name', () async {
      await ScreenViewFirebaseEventTracker(
        const TestScreenView('CheckoutScreen', {'source': .string('cart')}),
        analytics,
      ).track();

      verify(
        () => analytics.logScreenView(screenName: 'CheckoutScreen', parameters: {'source': 'cart'}),
      ).called(1);
    });

    test('a screen view with its own screen_name parameter is refused, and nothing is sent', () {
      final tracker = ScreenViewFirebaseEventTracker(
        const TestScreenView('CheckoutScreen', {'screen_name': .string('other')}),
        analytics,
      );

      expect(tracker.track, throwsArgumentError);
      verifyNever(
        () => analytics.logScreenView(
          screenName: any(named: 'screenName'),
          parameters: any(named: 'parameters'),
        ),
      );
    });

    test('a property is set as a user property in its string form', () async {
      await GenericFirebasePropertySetter(
        const TestProperty('seats', AnalyticsInt(2)),
        analytics,
      ).set();

      verify(() => analytics.setUserProperty(name: 'seats', value: '2')).called(1);
    });
  });

  group('factories', () {
    test('the screen-view factory claims screen views and declines the rest', () {
      final factory = ScreenViewFirebaseEventTrackerFactory(analytics);

      expect(
        factory.create(const TestScreenView('Home')).handlers.single,
        isA<ScreenViewFirebaseEventTracker>(),
      );
      expect(factory.create(const TestEvent('other')), const Declined());
    });

    test('a chain sends screen views as screen views and everything else as-is', () async {
      final tracker = FirebaseAnalyticsTrackerService(
        eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
          ScreenViewFirebaseEventTrackerFactory(analytics),
          GenericFirebaseEventTrackerFactory(analytics),
        ]),
        propertySetterFactory: CompositeFirebasePropertySetterFactory([
          GenericFirebasePropertySetterFactory(analytics),
        ]),
      );

      await tracker.track(const TestScreenView('Home'));
      await tracker.track(const TestEvent('checkout_started'));
      await tracker.set(const TestProperty('plan', AnalyticsString('pro')));

      verify(() => analytics.logScreenView(screenName: 'Home', parameters: {})).called(1);
      verify(() => analytics.logEvent(name: 'checkout_started', parameters: {})).called(1);
      verify(() => analytics.setUserProperty(name: 'plan', value: 'pro')).called(1);
    });

    test('a generic factory anywhere but last is refused when the chain is built', () {
      expect(
        () => CompositeFirebaseEventTrackerFactory([
          GenericFirebaseEventTrackerFactory(analytics),
          ScreenViewFirebaseEventTrackerFactory(analytics),
        ]),
        throwsArgumentError,
      );
    });

    test('a chain ending in RequireMapped reports an unclaimed event through Herald', () async {
      final failures = <Object>[];
      final tracker = FirebaseAnalyticsTrackerService(
        eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
          ScreenViewFirebaseEventTrackerFactory(analytics),
          const RequireMappedFirebaseEventTrackerFactory(),
        ]),
        propertySetterFactory: CompositeFirebasePropertySetterFactory([
          const RequireMappedFirebasePropertySetterFactory(),
        ]),
      );
      final herald = Herald(
        providers: [HeraldProvider(name: 'firebase', events: tracker, properties: tracker)],
        errorReporter: (failure) => failures.add(failure.error),
      );

      await herald.track(const TestEvent('unwired'));
      await herald.set(const TestProperty('unwired', AnalyticsInt(1)));

      expect(failures, [isA<UnhandledEventException>(), isA<UnhandledPropertyException>()]);
      verifyNever(
        () => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      );
    });

    test('dropped keeps one event away from Firebase', () async {
      final tracker = FirebaseAnalyticsTrackerService(
        eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
          const DropDebugPingFirebaseEventTrackerFactory(),
          GenericFirebaseEventTrackerFactory(analytics),
        ]),
        propertySetterFactory: CompositeFirebasePropertySetterFactory([]),
      );

      await tracker.track(const TestEvent('debug_ping'));

      verifyNever(
        () => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      );
    });
  });

  group('service', () {
    test('consent maps to collection enabled', () async {
      final service = FirebaseAnalyticsService(analytics);

      await service.setEnabled(false);

      verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
    });

    test('identify and reset set and clear the user id', () async {
      final service = FirebaseAnalyticsService(analytics);

      await service.identify(const Identity('user-1'));
      await service.reset();

      verifyInOrder([() => analytics.setUserId(id: 'user-1'), () => analytics.setUserId()]);
    });

    test('start and flush touch nothing, since Firebase starts itself and has no flush', () async {
      final service = FirebaseAnalyticsService(analytics);

      await service.start();
      await service.flush();

      verifyZeroInteractions(analytics);
    });
  });
}

final class const DropDebugPingFirebaseEventTrackerFactory()
    implements FirebaseEventTrackerFactory {
  @override
  Resolution<FirebaseEventTracker> create(Event event) =>
      event.name == 'debug_ping' ? .dropped() : .declined();
}
