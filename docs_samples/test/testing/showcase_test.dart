import 'package:flutter_test/flutter_test.dart';
import 'package:herald/herald.dart';
import 'package:herald_testing/herald_testing.dart';

// --8<-- [start:app]
final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

final class const OrderPaid(final double total) extends Event {
  @override
  String get name => 'order_paid';

  @override
  Map<String, AnalyticsValue> get parameters => {'total': .double(total)};
}

final class const PurchaseCount(final int count) extends UserProperty {
  @override
  String get name => 'total_purchases';

  @override
  AnalyticsValue get value => .int(count);
}

final class CheckoutViewModel(
  final EventTrackerService events,
  final PropertyTrackerService properties,
) {
  Future<void> start(String plan, int seats) => events.track(CheckoutStarted(plan, seats));

  Future<void> pay(double total, int purchases) async {
    await properties.set(PurchaseCount(purchases));
    await events.track(OrderPaid(total));
  }
}

final class SessionViewModel(final IdentifiableUserService identity) {
  Future<void> signIn(String userId) => identity.identify(Identity(userId));

  Future<void> signOut() => identity.reset();
}
// --8<-- [end:app]

void main() {
  late FakeAnalyticsProvider analytics;

  setUp(() => analytics = FakeAnalyticsProvider());

  test('through a real Herald', () async {
    // --8<-- [start:through-herald]
    final analytics = FakeAnalyticsProvider();
    final herald = Herald(
      providers: [HeraldProvider(name: 'test', events: analytics, properties: analytics)],
    );

    await CheckoutViewModel(herald, herald).start('pro', 3);

    analytics.assertTracked('checkout_started');
    // --8<-- [end:through-herald]
  });

  test('passed straight to the class', () async {
    // --8<-- [start:direct]
    await CheckoutViewModel(analytics, analytics).start('pro', 3);
    // --8<-- [end:direct]

    analytics.assertTracked('checkout_started');
  });

  test('parameters, compared by type', () async {
    await CheckoutViewModel(analytics, analytics).start('pro', 3);

    // --8<-- [start:parameters]
    analytics.assertTracked(
      'checkout_started',
      (event) => event
        ..param('plan', 'pro')
        ..param('seats', 3), // the number 3: the text '3' would fail
    );
    // --8<-- [end:parameters]
  });

  test('counting, absence and nothing else', () async {
    final checkout = CheckoutViewModel(analytics, analytics);
    await checkout.start('pro', 3);
    await checkout.start('pro', 3);

    // --8<-- [start:counting]
    analytics
      ..assertTrackedTimes('checkout_started', 2) // repeats are expected
      ..assertNotTracked('order_paid')
      ..assertNothingElseTracked(); // every tracked event was checked above
    // --8<-- [end:counting]
  });

  test('properties: the last value counts', () async {
    // --8<-- [start:properties]
    final checkout = CheckoutViewModel(analytics, analytics);
    await checkout.pay(9.99, 1);
    await checkout.pay(4.99, 2);

    analytics.assertPropertySet('total_purchases', 2); // 1 was overwritten by 2
    // --8<-- [end:properties]
  });

  test('order across different calls', () async {
    // --8<-- [start:order]
    await CheckoutViewModel(analytics, analytics).pay(9.99, 1);

    expect(analytics.records, [isA<PropertySetRecord>(), isA<TrackedRecord>()]);
    // --8<-- [end:order]
  });

  test('sign-in and sign-out', () async {
    // --8<-- [start:identity]
    final session = SessionViewModel(analytics);
    await session.signIn('user-42');
    await session.signOut();

    analytics.assertIdentified('user-42'); // passes even after the later reset
    expect(analytics.records, [const IdentifiedRecord(Identity('user-42')), const ResetRecord()]);
    // --8<-- [end:identity]
  });

  test('your own checks', () async {
    await CheckoutViewModel(analytics, analytics).pay(9.99, 1);

    // --8<-- [start:custom-checks]
    analytics.assertTracked(
      'order_paid',
      (event) => expect((event.event as OrderPaid).total, closeTo(9.99, 0.001)),
    );
    expect(analytics.events.single, isA<OrderPaid>());
    expect(analytics.properties.single.value, const AnalyticsInt(1));
    // --8<-- [end:custom-checks]
  });

  test('starting over mid-test', () async {
    // --8<-- [start:clear]
    final checkout = CheckoutViewModel(analytics, analytics);
    await checkout.start('pro', 3);
    analytics.clear(); // forget what came before

    await checkout.pay(9.99, 1);

    analytics
      ..assertTracked('order_paid')
      ..assertNothingElseTracked();
    // --8<-- [end:clear]
  });

  test('a failure shows everything recorded', () async {
    await CheckoutViewModel(analytics, analytics).start('pro', 3);

    expect(
      // --8<-- [start:failure]
      () => analytics.assertTracked('checkout_started', (event) => event.param('seats', '3')),
      // --8<-- [end:failure]
      throwsA(
        isA<TestFailure>().having(
          (failure) => failure.message,
          'message',
          "Event 'checkout_started' parameter 'seats' was AnalyticsInt(3), "
              'expected AnalyticsString(3).\n'
              '\n'
              'Recorded:\n'
              '  1. event    checkout_started { plan = pro, seats = 3 }',
        ),
      ),
    );
  });
}
