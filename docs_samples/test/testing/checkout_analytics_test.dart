import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_docs_samples/concepts/factory_chain.dart';
import 'package:herald_docs_samples/concepts/vocabulary.dart';
import 'package:herald_docs_samples/quick_start.dart';
import 'package:herald_testing/herald_testing.dart';
import 'package:mocktail/mocktail.dart';

final class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  // --8<-- [start:fake-provider]
  test('checkout reports the plan and seats, once', () async {
    final analytics = FakeAnalyticsProvider();
    final herald = Herald(
      providers: [HeraldProvider(name: 'test', events: analytics, properties: analytics)],
    );

    await CheckoutViewModel(herald).onCheckout('pro', 3);

    analytics
      ..assertTracked(
        'checkout_started',
        (event) => event
          ..param('plan', 'pro')
          ..param('seats', 3), // an int: the String '3' would fail here
      )
      ..assertNothingElseTracked();
  });
  // --8<-- [end:fake-provider]

  // --8<-- [start:order]
  test('the purchase count is set before the purchase event that should carry it', () async {
    final analytics = FakeAnalyticsProvider();
    final PropertyTrackerService properties = analytics;
    final EventTrackerService events = analytics;

    await properties.set(const PurchaseCount(1));
    await events.track(const PlanSelected('pro', seats: 1, price: 9.99, trial: false));

    expect(analytics.records, [isA<PropertySetRecord>(), isA<TrackedRecord>()]);
  });
  // --8<-- [end:order]

  // --8<-- [start:single-capability]
  test('a class that takes one capability can be given the fake directly', () async {
    final analytics = FakeAnalyticsProvider();

    await CheckoutViewModel(analytics).onCheckout('pro', 3);

    expect(analytics.events, [const CheckoutStarted('pro', 3)]);
  });
  // --8<-- [end:single-capability]

  // --8<-- [start:factory]
  test('the checkout factory claims its events and declines the rest', () {
    final factory = CheckoutFirebaseEventTrackerFactory(MockFirebaseAnalytics());

    expect(factory.create(const CheckoutCompleted(9.99, 'EUR')), isA<Claimed<Object>>());
    expect(factory.create(const CardNumberSeen('4242')), const Dropped());
    expect(factory.create(const CheckoutStarted('pro', 3)), const Declined());
  });
  // --8<-- [end:factory]

  test('an assertion that cannot fail is not a test', () {
    expect(() => FakeAnalyticsProvider().assertTracked('never'), throwsA(isA<TestFailure>()));
  });
}
