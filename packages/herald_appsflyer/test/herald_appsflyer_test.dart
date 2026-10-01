import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_appsflyer/herald_appsflyer.dart';
import 'package:mocktail/mocktail.dart';

import 'support.dart';

final class MockAppsFlyerSdk extends Mock implements AppsFlyerSdk {}

AppsFlyerPurchaseEvent _purchase({String orderId = 'order-1', String fare = 'adult'}) =>
    AppsFlyerPurchaseEvent(
      name: 'order_paid',
      revenue: 4.99,
      currency: 'EUR',
      orderId: orderId,
      parameters: {'fare': .string(fare)},
    );

void main() {
  late MockAppsFlyerSdk appsFlyer;

  setUpAll(() => registerFallbackValue(AFMediationNetwork.applovinMax));

  setUp(() {
    appsFlyer = MockAppsFlyerSdk();
    when(() => appsFlyer.logEvent(any(), eventValues: any(named: 'eventValues')))
        .thenAnswer((_) async {});
    when(
      () => appsFlyer.logAdRevenue(
        monetizationNetwork: any(named: 'monetizationNetwork'),
        mediationNetwork: any(named: 'mediationNetwork'),
        currencyIso4217Code: any(named: 'currencyIso4217Code'),
        revenue: any(named: 'revenue'),
        additionalParameters: any(named: 'additionalParameters'),
      ),
    ).thenAnswer((_) async {});
    when(() => appsFlyer.stop(any())).thenAnswer((_) async {});
    when(() => appsFlyer.start()).thenAnswer((_) async {});
    when(() => appsFlyer.setCustomerUserId(any())).thenAnswer((_) async {});
  });

  group('revenue types', () {
    test('a purchase puts its revenue under af_revenue, and leaves absent fields out', () {
      const purchase = AppsFlyerPurchaseEvent(
        name: 'order_paid',
        revenue: 4.99,
        currency: 'EUR',
        quantity: 2,
        parameters: {'fare': .string('adult')},
      );

      expect(purchase.toAppsFlyerEventValues(), {
        'fare': 'adult',
        'af_revenue': 4.99,
        'af_currency': 'EUR',
        'af_quantity': 2,
      });
    });

    test('a subscription carries af_revenue and af_currency', () {
      const subscription = AppsFlyerSubscribeEvent(
        name: 'subscribed',
        revenue: 9.99,
        currency: 'USD',
        parameters: {'plan': .string('pro')},
      );

      expect(subscription.toAppsFlyerEventValues(), {
        'plan': 'pro',
        'af_revenue': 9.99,
        'af_currency': 'USD',
      });
    });

    test('a parameter with a key the event sets itself is refused', () {
      const purchase = AppsFlyerPurchaseEvent(
        name: 'order_paid',
        revenue: 4.99,
        currency: 'EUR',
        parameters: {'af_revenue': .string('other')},
      );
      const subscription = AppsFlyerSubscribeEvent(
        name: 'subscribed',
        revenue: 9.99,
        currency: 'USD',
        parameters: {'af_currency': .string('EUR')},
      );

      expect(purchase.toAppsFlyerEventValues, throwsArgumentError);
      expect(subscription.toAppsFlyerEventValues, throwsArgumentError);
    });

    test('a key the purchase leaves empty is free for a parameter', () {
      const purchase = AppsFlyerPurchaseEvent(
        name: 'order_paid',
        revenue: 4.99,
        currency: 'EUR',
        parameters: {'af_order_id': .string('order-1')},
      );

      expect(purchase.toAppsFlyerEventValues(), containsPair('af_order_id', 'order-1'));
    });

    test('revenue events are equal by value', () {
      expect(_purchase(), _purchase());
      expect(_purchase().hashCode, _purchase().hashCode);
      expect(_purchase(), isNot(_purchase(orderId: 'order-2')));
      expect(_purchase(), isNot(_purchase(fare: 'child')));
      expect(
        const AppsFlyerSubscribeEvent(name: 'a', revenue: 1, currency: 'EUR'),
        isNot(const AppsFlyerSubscribeEvent(name: 'a', revenue: 1, currency: 'USD')),
      );
      expect(
        const AppsFlyerAdRevenueEvent(
          name: 'a',
          monetizationNetwork: 'admob',
          mediationNetwork: AFMediationNetwork.googleAdMob,
          revenue: 1,
          currency: 'USD',
        ),
        isNot(
          const AppsFlyerAdRevenueEvent(
            name: 'a',
            monetizationNetwork: 'admob',
            mediationNetwork: AFMediationNetwork.applovinMax,
            revenue: 1,
            currency: 'USD',
          ),
        ),
      );
    });
  });

  group('trackers', () {
    test('the generic tracker logs the event under its own name, with typed values', () async {
      await GenericAppsFlyerEventTracker(
        const TestEvent('af_complete_registration', {'method': .string('email'), 'step': .int(2)}),
        appsFlyer,
      ).track();

      verify(
        () => appsFlyer.logEvent(
          'af_complete_registration',
          eventValues: {'method': 'email', 'step': 2},
        ),
      ).called(1);
    });

    test('a purchase with a clashing parameter sends nothing', () {
      final tracker = PurchaseAppsFlyerEventTracker(
        const AppsFlyerPurchaseEvent(
          name: 'p',
          revenue: 1,
          currency: 'EUR',
          parameters: {'af_currency': .string('USD')},
        ),
        appsFlyer,
      );

      expect(tracker.track, throwsArgumentError);
      verifyZeroInteractions(appsFlyer);
    });

    test('a purchase is logged as af_purchase and a subscription as af_subscribe', () async {
      await PurchaseAppsFlyerEventTracker(
        const AppsFlyerPurchaseEvent(name: 'p', revenue: 1, currency: 'EUR'),
        appsFlyer,
      ).track();
      await SubscribeAppsFlyerEventTracker(
        const AppsFlyerSubscribeEvent(name: 's', revenue: 2, currency: 'EUR'),
        appsFlyer,
      ).track();

      verifyInOrder([
        () => appsFlyer.logEvent(
          'af_purchase',
          eventValues: {'af_revenue': 1.0, 'af_currency': 'EUR'},
        ),
        () => appsFlyer.logEvent(
          'af_subscribe',
          eventValues: {'af_revenue': 2.0, 'af_currency': 'EUR'},
        ),
      ]);
    });

    test('ad revenue goes through logAdRevenue', () async {
      await AdRevenueAppsFlyerEventTracker(
        const AppsFlyerAdRevenueEvent(
          name: 'ad_shown',
          monetizationNetwork: 'admob',
          mediationNetwork: AFMediationNetwork.googleAdMob,
          revenue: 0.01,
          currency: 'USD',
          parameters: {'slot': .int(1)},
        ),
        appsFlyer,
      ).track();

      verify(
        () => appsFlyer.logAdRevenue(
          monetizationNetwork: 'admob',
          mediationNetwork: AFMediationNetwork.googleAdMob,
          currencyIso4217Code: 'USD',
          revenue: 0.01,
          additionalParameters: {'slot': 1},
        ),
      ).called(1);
    });
  });

  group('factories', () {
    test('a chain without a fallback sends only the conversions a factory handles', () async {
      final tracker = AppsFlyerAnalyticsTrackerService(
        eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory([
          OrderPaidAppsFlyerEventTrackerFactory(appsFlyer),
        ]),
      );

      await tracker.track(const TestEvent('order_paid'));
      await tracker.track(const TestEvent('cart_viewed'));

      verify(() => appsFlyer.logEvent('af_purchase', eventValues: any(named: 'eventValues')))
          .called(1);
      verifyNoMoreInteractions(appsFlyer);
    });

    test('the generic factory claims everything', () {
      expect(
        GenericAppsFlyerEventTrackerFactory(appsFlyer).create(const TestEvent('e')).handlers.single,
        isA<GenericAppsFlyerEventTracker>(),
      );
    });

    test('a fallback factory that is not last is refused', () {
      expect(
        () => CompositeAppsFlyerEventTrackerFactory([
          GenericAppsFlyerEventTrackerFactory(appsFlyer),
          OrderPaidAppsFlyerEventTrackerFactory(appsFlyer),
        ]),
        throwsArgumentError,
      );
    });

    test('the require-mapped factory throws for anything that reaches it', () {
      expect(
        () => const RequireMappedAppsFlyerEventTrackerFactory().create(const TestEvent('e')),
        throwsA(isA<UnhandledEventException>()),
      );
    });
  });

  group('service', () {
    test('start keeps the SDK stopped', () async {
      await AppsFlyerAnalyticsService(appsFlyer).start();

      verify(() => appsFlyer.stop(true)).called(1);
      verifyNever(() => appsFlyer.start());
    });

    test('granting consent resumes then starts, in that order', () async {
      await AppsFlyerAnalyticsService(appsFlyer).setEnabled(true);

      verifyInOrder([() => appsFlyer.stop(false), () => appsFlyer.start()]);
    });

    test('revoking consent stops the SDK and does not start it', () async {
      await AppsFlyerAnalyticsService(appsFlyer).setEnabled(false);

      verify(() => appsFlyer.stop(true)).called(1);
      verifyNever(() => appsFlyer.start());
    });

    test('identify sets the customer user id, and reset touches nothing', () async {
      final service = AppsFlyerAnalyticsService(appsFlyer);

      await service.identify(const Identity('user-1'));
      await service.reset();

      verify(() => appsFlyer.setCustomerUserId('user-1')).called(1);
      verifyNoMoreInteractions(appsFlyer);
    });
  });
}

final class const OrderPaidAppsFlyerEventTrackerFactory(final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTrackerFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) => switch (event.name) {
    'order_paid' => .claimed([
      PurchaseAppsFlyerEventTracker(
        AppsFlyerPurchaseEvent(name: event.name, revenue: 3, currency: 'EUR'),
        appsFlyer,
      ),
    ]),
    _ => .declined(),
  };
}
