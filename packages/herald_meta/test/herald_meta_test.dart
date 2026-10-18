import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_meta/herald_meta.dart';
import 'package:mocktail/mocktail.dart';

import 'support.dart';

final class MockFacebookAppEvents extends Mock implements FacebookAppEvents {}

void main() {
  late MockFacebookAppEvents appEvents;
  late MetaAnalyticsService service;

  setUp(() {
    appEvents = MockFacebookAppEvents();
    when(() => appEvents.initializeSdk()).thenAnswer((_) async {});
    when(() => appEvents.setAutoLogAppEventsEnabled(any())).thenAnswer((_) async {});
    when(() => appEvents.setAdvertiserIdCollectionEnabled(any())).thenAnswer((_) async {});
    when(() => appEvents.setUserID(any())).thenAnswer((_) async {});
    when(() => appEvents.clearUserID()).thenAnswer((_) async {});
    when(() => appEvents.flush()).thenAnswer((_) async {});
    when(
      () => appEvents.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => appEvents.logPurchase(
        amount: any(named: 'amount'),
        currency: any(named: 'currency'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) async {});
    service = MetaAnalyticsService(appEvents);
  });

  group('consent', () {
    test('consent finishes starting Meta, then turns its collection on', () async {
      await service.setEnabled(true);

      verifyInOrder([
        () => appEvents.initializeSdk(),
        () => appEvents.setAutoLogAppEventsEnabled(true),
        () => appEvents.setAdvertiserIdCollectionEnabled(true),
      ]);
    });

    test('withdrawing consent turns collection off without starting Meta', () async {
      await service.setEnabled(false);

      verifyNever(() => appEvents.initializeSdk());
      verify(() => appEvents.setAutoLogAppEventsEnabled(false)).called(1);
      verify(() => appEvents.setAdvertiserIdCollectionEnabled(false)).called(1);
    });

    test('sign-in, sign-out and flush reach Meta', () async {
      await service.identify(const Identity('user-42'));
      await service.reset();
      await service.flush();

      verify(() => appEvents.setUserID('user-42')).called(1);
      verify(() => appEvents.clearUserID()).called(1);
      verify(() => appEvents.flush()).called(1);
    });
  });

  group('trackers', () {
    test('parameters keep numbers as numbers and send true or false as text', () {
      expect(
        {
          'plan': const AnalyticsString('pro'),
          'seats': const AnalyticsInt(3),
          'price': const AnalyticsDouble(9.99),
          'trial': const AnalyticsBool(false),
        }.toMetaParameters(),
        {'plan': 'pro', 'seats': 3, 'price': 9.99, 'trial': 'false'},
      );
    });

    test('a purchase is logged with its amount and currency', () async {
      await PurchaseMetaEventTracker(
        const MetaPurchaseEvent(
          name: 'ticket_bought',
          amount: 4.99,
          currency: 'EUR',
          parameters: {'fare': AnalyticsString('day')},
        ),
        appEvents,
      ).track();

      verify(
        () => appEvents.logPurchase(amount: 4.99, currency: 'EUR', parameters: {'fare': 'day'}),
      ).called(1);
    });

    test('a purchase with an amount that is not a finite number is refused', () {
      expect(
        PurchaseMetaEventTracker(
          const MetaPurchaseEvent(name: 'ticket_bought', amount: double.nan, currency: 'EUR'),
          appEvents,
        ).track(),
        throwsArgumentError,
      );
    });
  });

  group('factories', () {
    test('the composite uses the first factory that answers', () {
      final resolution = CompositeMetaEventTrackerFactory([
        GenericMetaEventTrackerFactory(appEvents),
      ]).create(const TestEvent('search_tapped'));

      expect(resolution.handlers.single, isA<GenericMetaEventTracker>());
    });

    test('a fallback factory that is not last is refused', () {
      expect(
        () => CompositeMetaEventTrackerFactory([
          GenericMetaEventTrackerFactory(appEvents),
          const RequireMappedMetaEventTrackerFactory(),
        ]),
        throwsArgumentError,
      );
    });

    test('the require-mapped factory fails for any event', () {
      expect(
        () => const RequireMappedMetaEventTrackerFactory().create(const TestEvent('search_tapped')),
        throwsA(isA<UnhandledEventException>()),
      );
    });
  });
}
