import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_mixpanel/herald_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:mocktail/mocktail.dart';

import 'support.dart';

final class MockMixpanel extends Mock implements Mixpanel {}

final class MockPeople extends Mock implements People {}

void main() {
  late MockMixpanel mixpanel;
  late MockPeople people;

  setUp(() {
    mixpanel = MockMixpanel();
    people = MockPeople();
    when(() => mixpanel.getPeople()).thenReturn(people);
    when(() => mixpanel.track(any(), properties: any(named: 'properties')))
        .thenAnswer((_) async {});
    when(() => mixpanel.registerSuperProperties(any())).thenAnswer((_) async {});
    when(() => mixpanel.flush()).thenAnswer((_) async {});
    when(() => mixpanel.identify(any())).thenAnswer((_) async {});
    when(() => mixpanel.reset()).thenAnswer((_) async {});
  });

  test('parameters keep their types', () {
    const parameters = <String, AnalyticsValue>{
      'plan': .string('pro'),
      'seats': .int(3),
      'price': .double(9.99),
      'trial': .bool(false),
    };

    expect(parameters.toMixpanelProperties(), {
      'plan': 'pro',
      'seats': 3,
      'price': 9.99,
      'trial': false,
    });
  });

  group('trackers', () {
    test('the generic tracker sends the event under its own name', () async {
      await GenericMixpanelEventTracker(
        const TestEvent('checkout_started', {'seats': .int(3)}),
        mixpanel,
      ).track();

      verify(() => mixpanel.track('checkout_started', properties: {'seats': 3})).called(1);
    });

    test('a screen view is screen_view, with its name as screen_name', () async {
      await ScreenViewMixpanelEventTracker(
        const TestScreenView('CheckoutScreen', {'source': .string('cart')}),
        mixpanel,
      ).track();

      verify(
        () => mixpanel.track(
          'screen_view',
          properties: {'source': 'cart', 'screen_name': 'CheckoutScreen'},
        ),
      ).called(1);
    });

    test('a screen view with its own screen_name parameter is refused, and nothing is sent', () {
      final tracker = ScreenViewMixpanelEventTracker(
        const TestScreenView('CheckoutScreen', {'screen_name': .string('other')}),
        mixpanel,
      );

      expect(tracker.track, throwsArgumentError);
      verifyNever(() => mixpanel.track(any(), properties: any(named: 'properties')));
    });

    test('a property becomes a super property, with its type', () async {
      await GenericMixpanelPropertySetter(
        const TestProperty('seats', AnalyticsInt(2)),
        mixpanel,
      ).set();

      verify(() => mixpanel.registerSuperProperties({'seats': 2})).called(1);
    });

    test('a user property is written to the People profile', () async {
      await UserPropertyMixpanelPropertySetter(
        const TestUserProperty('plan', AnalyticsString('pro')),
        mixpanel,
      ).set();

      verify(() => people.set('plan', 'pro')).called(1);
    });
  });

  group('factories', () {
    late MixpanelAnalyticsTrackerService tracker;

    setUp(
      () => tracker = MixpanelAnalyticsTrackerService(
        eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
          ScreenViewMixpanelEventTrackerFactory(mixpanel),
          GenericMixpanelEventTrackerFactory(mixpanel),
        ]),
        propertySetterFactory: CompositeMixpanelPropertySetterFactory([
          UserPropertyMixpanelPropertySetterFactory(mixpanel),
          GenericMixpanelPropertySetterFactory(mixpanel),
        ]),
      ),
    );

    test('a user property reaches the profile and an ordinary one the super properties', () async {
      await tracker.set(const TestUserProperty('plan', AnalyticsString('pro')));
      await tracker.set(const TestProperty('theme', AnalyticsString('dark')));

      verify(() => people.set('plan', 'pro')).called(1);
      verify(() => mixpanel.registerSuperProperties({'theme': 'dark'})).called(1);
      verifyNever(() => mixpanel.registerSuperProperties({'plan': 'pro'}));
    });

    test('screen views and other events take their own paths', () async {
      await tracker.track(const TestScreenView('Home'));
      await tracker.track(const TestEvent('checkout_started'));

      verify(() => mixpanel.track('screen_view', properties: {'screen_name': 'Home'})).called(1);
      verify(() => mixpanel.track('checkout_started', properties: {})).called(1);
    });

    test('the user-property factory declines an ordinary property', () {
      expect(
        UserPropertyMixpanelPropertySetterFactory(mixpanel)
            .create(const TestProperty('a', AnalyticsInt(1))),
        const Declined(),
      );
    });

    test('the require-mapped factories throw for anything that reaches them', () {
      expect(
        () => const RequireMappedMixpanelEventTrackerFactory().create(const TestEvent('e')),
        throwsA(isA<UnhandledEventException>()),
      );
      expect(
        () => const RequireMappedMixpanelPropertySetterFactory().create(
          const TestProperty('p', AnalyticsInt(1)),
        ),
        throwsA(isA<UnhandledPropertyException>()),
      );
    });
  });

  group('service', () {
    late MixpanelAnalyticsService service;

    setUp(() => service = MixpanelAnalyticsService(mixpanel));

    test("start doesn't touch Mixpanel, so it never opts out", () async {
      await service.start();

      verifyZeroInteractions(mixpanel);
    });

    test('revoking consent flushes before opting out, and granting opts in', () async {
      await service.setEnabled(false);
      await service.setEnabled(true);

      verifyInOrder([
        () => mixpanel.flush(),
        () => mixpanel.optOutTracking(),
        () => mixpanel.optInTracking(),
      ]);
    });

    test('flush sends what Mixpanel has buffered', () async {
      await service.flush();

      verify(() => mixpanel.flush()).called(1);
    });

    test('identify and reset reach Mixpanel', () async {
      await service.identify(const Identity('user-1'));
      await service.reset();

      verifyInOrder([() => mixpanel.identify('user-1'), () => mixpanel.reset()]);
    });
  });
}
