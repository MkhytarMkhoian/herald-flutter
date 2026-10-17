import 'dart:convert';

import 'package:adjust_sdk/adjust_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';

import 'support.dart';

/// The channel Adjust's plugin talks to its native side over. Tests record what it sends.
const _adjustChannel = MethodChannel('com.adjust.sdk/api');

final _sent = <MethodCall>[];

List<String> _sentMethods() => [for (final call in _sent) call.method];

Map<Object?, Object?> _sentArguments(String method) =>
    _sent.singleWhere((call) => call.method == method).arguments as Map<Object?, Object?>;

Map<String, Object?> _callbackParameters(Map<Object?, Object?> map) =>
    jsonDecode(map['callbackParameters'] as String? ?? '{}') as Map<String, Object?>;

Future<void> _record(MethodCall call) async => _sent.add(call);

AdjustAdRevenueEvent _adShown({String unit = 'banner', int slot = 2}) => AdjustAdRevenueEvent(
  name: 'ad_shown',
  source: 'admob_sdk',
  revenue: 0.5,
  currency: 'EUR',
  adRevenueUnit: unit,
  parameters: {'slot': .int(slot)},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late AdjustAnalyticsService service;

  setUp(() {
    _sent.clear();
    messenger.setMockMethodCallHandler(_adjustChannel, _record);
    service = AdjustAnalyticsService(AdjustConfig('app-token', AdjustEnvironment.sandbox));
  });

  tearDown(() => messenger.setMockMethodCallHandler(_adjustChannel, null));

  group('conversion', () {
    test('an event becomes the token with every parameter as text', () {
      final map = const TestEvent('checkout_started', {
        'plan': .string('pro'),
        'seats': .int(3),
        'price': .double(5),
        'trial': .bool(true),
      }).parameters.toAdjustEvent('abc123').toMap;

      expect(map['eventToken'], 'abc123');
      expect(_callbackParameters(map), {
        'plan': 'pro',
        'seats': '3',
        'price': '5.0',
        'trial': 'true',
      });
    });

    test('a revenue event carries its revenue and deduplication id', () {
      final map = const AdjustRevenueEvent(
        name: 'order_paid',
        revenue: 9.99,
        currency: 'EUR',
        deduplicationId: 'order-1',
        parameters: {'fare': .string('adult')},
      ).toAdjustEvent('rev123').toMap;

      expect(map, containsPair('eventToken', 'rev123'));
      expect(map, containsPair('revenue', '9.99'));
      expect(map, containsPair('currency', 'EUR'));
      expect(map, containsPair('deduplicationId', 'order-1'));
      expect(_callbackParameters(map), {'fare': 'adult'});
    });

    test('ad revenue sets only the fields that are present', () {
      final map = const AdjustAdRevenueEvent(
        name: 'ad_shown',
        source: 'applovin_max_sdk',
        revenue: 0.01,
        currency: 'USD',
        adRevenueNetwork: 'network',
        parameters: {'slot': .int(2)},
      ).toAdjustAdRevenue().toMap;

      expect(map, containsPair('source', 'applovin_max_sdk'));
      expect(map, containsPair('revenue', '0.01'));
      expect(map, containsPair('currency', 'USD'));
      expect(map, containsPair('adRevenueNetwork', 'network'));
      expect(map.containsKey('adRevenueUnit'), isFalse);
      expect(map.containsKey('adImpressionsCount'), isFalse);
      expect(_callbackParameters(map), {'slot': '2'});
    });

    test('revenue events are equal by value', () {
      expect(
        const AdjustRevenueEvent(
          name: 'a',
          revenue: 1,
          currency: 'EUR',
          parameters: {'x': .int(1)},
        ),
        const AdjustRevenueEvent(
          name: 'a',
          revenue: 1,
          currency: 'EUR',
          parameters: {'x': .int(1)},
        ),
      );
      expect(
        const AdjustRevenueEvent(name: 'a', revenue: 1, currency: 'EUR'),
        isNot(const AdjustRevenueEvent(name: 'a', revenue: 1, currency: 'USD')),
      );
    });

    test('ad revenue events are equal by value', () {
      expect(_adShown(), _adShown());
      expect(_adShown().hashCode, _adShown().hashCode);
      expect(_adShown(), isNot(_adShown(unit: 'interstitial')));
      expect(_adShown(), isNot(_adShown(slot: 3)));
    });
  });

  group('factories', () {
    test('the token factory sends an event of a listed type under its token', () async {
      final factory = TokenAdjustEventTrackerFactory([AdjustToken<_SignUpCompleted>('abc123')]);

      await factory.create(const _SignUpCompleted()).handlers.single.track();

      expect(_sentArguments('trackEvent'), containsPair('eventToken', 'abc123'));
    });

    test('the token factory matches by type, not by name, and declines the rest', () {
      final factory = TokenAdjustEventTrackerFactory([AdjustToken<_SignUpCompleted>('abc123')]);

      expect(
        factory.create(const _SignUpCompletedWithGoogle()),
        isA<Claimed<AdjustEventTracker>>(),
      );
      expect(factory.create(const TestEvent('sign_up_completed')), const Declined());
    });

    test('the token factory gives each listed type its own token', () async {
      final factory = TokenAdjustEventTrackerFactory([
        AdjustToken<_SignUpCompleted>('abc123'),
        AdjustToken<TestEvent>('def456'),
      ]);

      await factory.create(const TestEvent('search_tapped')).handlers.single.track();

      expect(_sentArguments('trackEvent'), containsPair('eventToken', 'def456'));
    });

    test('the token factory refuses a type with two tokens', () {
      expect(
        () => TokenAdjustEventTrackerFactory([
          AdjustToken<_SignUpCompleted>('abc123'),
          AdjustToken<_SignUpCompleted>('def456'),
        ]),
        throwsArgumentError,
      );
    });

    test('the token list cannot be changed after the factory is built', () {
      final tokens = <AdjustToken<Event>>[];
      final factory = TokenAdjustEventTrackerFactory(tokens);

      tokens.add(AdjustToken<_SignUpCompleted>('abc123'));

      expect(factory.create(const _SignUpCompleted()), const Declined());
    });

    test('custom factories before the token factory send purchases and ad revenue', () async {
      final tracker = AdjustAnalyticsTrackerService(
        eventTrackerFactory: CompositeAdjustEventTrackerFactory([
          const BillingAdjustEventTrackerFactory(),
          TokenAdjustEventTrackerFactory([AdjustToken<_SignUpCompleted>('abc123')]),
        ]),
        propertySetterFactory: CompositeAdjustPropertySetterFactory([
          const GenericAdjustPropertySetterFactory(),
        ]),
      );

      await tracker.track(const TestEvent('order_paid'));
      await tracker.track(const TestEvent('ad_shown'));
      await tracker.track(const TestEvent('unmapped'));
      await tracker.set(const TestProperty('plan', AnalyticsString('pro')));

      expect(_sentMethods(), ['trackEvent', 'trackAdRevenue', 'addGlobalCallbackParameter']);
      expect(_sentArguments('trackEvent'), containsPair('revenue', '4.99'));
      expect(_sentArguments('trackAdRevenue'), containsPair('source', 'admob_sdk'));
      expect(_sentArguments('addGlobalCallbackParameter'), {'key': 'plan', 'value': 'pro'});
    });

    test('a fallback factory that is not last is refused', () {
      expect(
        () => CompositeAdjustEventTrackerFactory([
          const RequireMappedAdjustEventTrackerFactory(),
          TokenAdjustEventTrackerFactory([AdjustToken<_SignUpCompleted>('abc123')]),
        ]),
        throwsArgumentError,
      );
      expect(
        () => CompositeAdjustPropertySetterFactory([
          const GenericAdjustPropertySetterFactory(),
          const RequireMappedAdjustPropertySetterFactory(),
        ]),
        throwsArgumentError,
      );
    });

    test('the require-mapped factories throw for anything that reaches them', () {
      expect(
        () => const RequireMappedAdjustEventTrackerFactory().create(const TestEvent('e')),
        throwsA(isA<UnhandledEventException>()),
      );
      expect(
        () => const RequireMappedAdjustPropertySetterFactory().create(
          const TestProperty('p', AnalyticsInt(1)),
        ),
        throwsA(isA<UnhandledPropertyException>()),
      );
    });
  });

  group('service', () {
    test('start turns Adjust off before starting it, so it starts silent', () async {
      await service.start();

      expect(_sentMethods(), ['disable', 'initSdk']);
      expect(_sentArguments('initSdk'), containsPair('appToken', 'app-token'));
    });

    test('consent turns Adjust on and off', () async {
      await service.setEnabled(true);
      await service.setEnabled(false);

      expect(_sentMethods(), ['enable', 'disable']);
    });

    test('identity is a global callback parameter', () async {
      await service.identify(const Identity('user-1'));
      await service.reset();

      expect(_sentMethods(), ['addGlobalCallbackParameter', 'removeGlobalCallbackParameter']);
      expect(_sentArguments('addGlobalCallbackParameter'), {'key': 'user_id', 'value': 'user-1'});
      expect(_sentArguments('removeGlobalCallbackParameter'), {'key': 'user_id'});
    });

    test('the identity parameter can be renamed', () async {
      await AdjustAnalyticsService(
        AdjustConfig('app-token', AdjustEnvironment.sandbox),
        identityParameter: 'customer',
      ).identify(const Identity('user-1'));

      expect(_sentArguments('addGlobalCallbackParameter'), {'key': 'customer', 'value': 'user-1'});
    });
  });
}

/// Sends `order_paid` as a purchase and `ad_shown` as ad revenue, as an app's billing and ads
/// features would.
final class const BillingAdjustEventTrackerFactory() implements AdjustEventTrackerFactory {
  @override
  Resolution<AdjustEventTracker> create(Event event) => switch (event.name) {
    'order_paid' => .claimed([
      RevenueAdjustEventTracker(
        AdjustRevenueEvent(name: event.name, revenue: 4.99, currency: 'EUR'),
        'rev123',
      ),
    ]),
    'ad_shown' => .claimed([
      AdRevenueAdjustEventTracker(
        AdjustAdRevenueEvent(name: event.name, source: 'admob_sdk', revenue: 0.5, currency: 'EUR'),
      ),
    ]),
    _ => .declined(),
  };
}

class _SignUpCompleted extends Event {
  const _SignUpCompleted();

  @override
  String get name => 'sign_up_completed';
}

final class _SignUpCompletedWithGoogle extends _SignUpCompleted {
  const _SignUpCompletedWithGoogle();
}
