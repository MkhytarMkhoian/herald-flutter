import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/event_options.dart';
import 'package:amplitude_flutter/events/identify.dart';
import 'package:amplitude_flutter/events/revenue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_amplitude/herald_amplitude.dart';
import 'package:mocktail/mocktail.dart';

import 'support.dart';

final class MockAmplitude extends Mock implements Amplitude {}

/// The one event [amplitude] was asked to track.
BaseEvent _trackedEvent(MockAmplitude amplitude) =>
    verify(() => amplitude.track(captureAny())).captured.single as BaseEvent;

void main() {
  late MockAmplitude amplitude;

  setUpAll(() {
    registerFallbackValue(BaseEvent('fallback'));
    registerFallbackValue(Identify());
    registerFallbackValue(Revenue());
    registerFallbackValue(EventOptions());
  });

  setUp(() {
    amplitude = MockAmplitude();
    when(() => amplitude.track(any())).thenAnswer((_) async {});
    when(() => amplitude.identify(any())).thenAnswer((_) async {});
    when(() => amplitude.revenue(any(), any())).thenAnswer((_) async {});
    when(() => amplitude.setUserId(any())).thenAnswer((_) async {});
    when(() => amplitude.setOptOut(any())).thenAnswer((_) async {});
    when(() => amplitude.reset()).thenAnswer((_) async {});
    when(() => amplitude.flush()).thenAnswer((_) async {});
  });

  group('trackers', () {
    test('the generic tracker sends the event under its own name, with typed properties', () async {
      await GenericAmplitudeEventTracker(
        const TestEvent('checkout_started', {'seats': .int(3), 'trial': .bool(false)}),
        amplitude,
      ).track();

      final event = _trackedEvent(amplitude);
      expect(event.eventType, 'checkout_started');
      expect(event.eventProperties, {'seats': 3, 'trial': false});
    });

    test("a screen view is Amplitude's own, with its name as the screen name", () async {
      await ScreenViewAmplitudeEventTracker(
        const TestScreenView('Home', {'source': .string('cart')}),
        amplitude,
      ).track();

      final event = _trackedEvent(amplitude);
      expect(event.eventType, '[Amplitude] Screen Viewed');
      expect(event.eventProperties, {'source': 'cart', '[Amplitude] Screen Name': 'Home'});
    });

    test('a screen view with its own screen name parameter is refused, and nothing is sent', () {
      final tracker = ScreenViewAmplitudeEventTracker(
        const TestScreenView('Home', {'[Amplitude] Screen Name': .string('other')}),
        amplitude,
      );

      expect(tracker.track, throwsArgumentError);
      verifyNever(() => amplitude.track(any()));
    });

    test('a property is set through identify, with its type', () async {
      await GenericAmplitudePropertySetter(
        const TestProperty('seats', AnalyticsInt(2)),
        amplitude,
      ).set();

      final identify = verify(() => amplitude.identify(captureAny())).captured.single as Identify;
      expect(identify.properties, {
        r'$set': {'seats': 2},
      });
    });
  });

  group('revenue', () {
    const purchase = AmplitudeRevenueEvent(
      name: 'order_paid',
      price: 4.99,
      quantity: 2,
      productId: 'pass_day',
      revenueType: 'purchase',
      currency: 'EUR',
      receipt: 'r',
      receiptSig: 's',
      insertId: 'order-1',
      parameters: {'fare': .string('adult')},
    );

    test('every field reaches the Revenue object', () {
      final revenue = purchase.toAmplitudeRevenue();

      expect(revenue.price, 4.99);
      expect(revenue.quantity, 2);
      expect(revenue.productId, 'pass_day');
      expect(revenue.revenueType, 'purchase');
      expect(revenue.revenueCurrency, 'EUR');
      expect(revenue.revenue, isNull);
      expect(revenue.receipt, 'r');
      expect(revenue.receiptSig, 's');
      expect(revenue.properties, {'fare': 'adult'});
    });

    test("Amplitude's own conversion accepts the revenue, properties included", () {
      final event = purchase.toAmplitudeRevenue().toRevenueEvent();

      expect(event.eventProperties, containsPair('fare', 'adult'));
      expect(event.eventProperties, containsPair(r'$price', 4.99));
      expect(event.eventProperties, containsPair(r'$quantity', 2));
    });

    test('the insert id travels as an event option', () async {
      await RevenueAmplitudeEventTracker(purchase, amplitude).track();

      final captured = verify(() => amplitude.revenue(captureAny(), captureAny())).captured;
      expect((captured[0] as Revenue).price, 4.99);
      expect((captured[1] as EventOptions).insertId, 'order-1');
    });

    test('without an insert id no options are sent', () async {
      await RevenueAmplitudeEventTracker(
        const AmplitudeRevenueEvent(name: 'order_paid', price: 1),
        amplitude,
      ).track();

      verify(() => amplitude.revenue(any(), null)).called(1);
    });

    test('revenue events are equal by value', () {
      expect(
        const AmplitudeRevenueEvent(name: 'a', price: 1, parameters: {'x': .int(1)}),
        const AmplitudeRevenueEvent(name: 'a', price: 1, parameters: {'x': .int(1)}),
      );
      expect(
        const AmplitudeRevenueEvent(name: 'a', price: 1),
        isNot(const AmplitudeRevenueEvent(name: 'a', price: 2)),
      );
    });

    test('a custom factory sends app events as revenue before the generic factory', () async {
      final tracker = AmplitudeAnalyticsTrackerService(
        eventTrackerFactory: CompositeAmplitudeEventTrackerFactory([
          OrderPaidAmplitudeEventTrackerFactory(amplitude),
          GenericAmplitudeEventTrackerFactory(amplitude),
        ]),
        propertySetterFactory: CompositeAmplitudePropertySetterFactory([]),
      );

      await tracker.track(const TestEvent('order_paid'));

      verify(() => amplitude.revenue(any(), any())).called(1);
      verifyNever(() => amplitude.track(any()));
    });
  });

  group('factories', () {
    test('the screen-view factory claims screen views only', () {
      final factory = ScreenViewAmplitudeEventTrackerFactory(amplitude);

      expect(
        factory.create(const TestScreenView('Home')).handlers.single,
        isA<ScreenViewAmplitudeEventTracker>(),
      );
      expect(factory.create(const TestEvent('other')), const Declined());
    });

    test('the require-mapped factories throw for anything that reaches them', () {
      expect(
        () => const RequireMappedAmplitudeEventTrackerFactory().create(const TestEvent('e')),
        throwsA(isA<UnhandledEventException>()),
      );
      expect(
        () => const RequireMappedAmplitudePropertySetterFactory().create(
          const TestProperty('p', AnalyticsInt(1)),
        ),
        throwsA(isA<UnhandledPropertyException>()),
      );
    });
  });

  group('service', () {
    test('start waits for Amplitude to be built', () async {
      when(() => amplitude.isBuilt).thenAnswer((_) async => true);

      await AmplitudeAnalyticsService(amplitude).start();

      verify(() => amplitude.isBuilt).called(1);
    });

    test('a failed build surfaces as a failure', () async {
      when(() => amplitude.isBuilt).thenAnswer((_) async => false);

      await expectLater(AmplitudeAnalyticsService(amplitude).start(), throwsStateError);
    });

    test('consent maps onto the opt-out', () async {
      await AmplitudeAnalyticsService(amplitude).setEnabled(false);
      await AmplitudeAnalyticsService(amplitude).setEnabled(true);

      verifyInOrder([() => amplitude.setOptOut(true), () => amplitude.setOptOut(false)]);
    });

    test('identify, reset and flush reach Amplitude', () async {
      final service = AmplitudeAnalyticsService(amplitude);

      await service.identify(const Identity('user-1'));
      await service.reset();
      await service.flush();

      verifyInOrder([
        () => amplitude.setUserId('user-1'),
        () => amplitude.reset(),
        () => amplitude.flush(),
      ]);
    });
  });
}

final class const OrderPaidAmplitudeEventTrackerFactory(final Amplitude amplitude)
    implements AmplitudeEventTrackerFactory {
  @override
  Resolution<AmplitudeEventTracker> create(Event event) => switch (event.name) {
    'order_paid' => .claimed([
      RevenueAmplitudeEventTracker(AmplitudeRevenueEvent(name: event.name, price: 9.99), amplitude),
    ]),
    _ => .declined(),
  };
}
