# Herald testing

A fake Herald vendor for tests. `FakeAnalyticsProvider` records every call instead of sending it,
and its assertions check what your code tracked.

```yaml
dev_dependencies:
  herald_testing: ^1.0.0
```

The examples below test this view model:

```dart
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
```

## Plug it in

Register the fake with a real `Herald`, so the test also runs your Herald setup:

```dart
final analytics = FakeAnalyticsProvider();
final herald = Herald(
  providers: [HeraldProvider(name: 'test', events: analytics, properties: analytics)],
);

await CheckoutViewModel(herald, herald).start('pro', 3);

analytics.assertTracked('checkout_started');
```

Or pass it straight to the class: the fake has all five capabilities.

```dart
await CheckoutViewModel(analytics, analytics).start('pro', 3);
```

## Events and their parameters

```dart
analytics.assertTracked(
  'checkout_started',
  (event) => event
    ..param('plan', 'pro')
    ..param('seats', 3), // the number 3: the text '3' would fail
);
```

`assertTracked` expects exactly one such event, so a duplicate fails. Values are compared by type,
because a number and its text reach a vendor differently.

```dart
analytics
  ..assertTrackedTimes('checkout_started', 2) // repeats are expected
  ..assertNotTracked('order_paid')
  ..assertNothingElseTracked(); // every tracked event was checked above
```

## Properties: the last value counts

```dart
final checkout = CheckoutViewModel(analytics, analytics);
await checkout.pay(9.99, 1);
await checkout.pay(4.99, 2);

analytics.assertPropertySet('total_purchases', 2); // 1 was overwritten by 2
```

## Order across different calls

`records` lists every call in order, so you can check that a property was set before the event
that should carry it:

```dart
await CheckoutViewModel(analytics, analytics).pay(9.99, 1);

expect(analytics.records, [isA<PropertySetRecord>(), isA<TrackedRecord>()]);
```

## Sign-in and sign-out

```dart
final session = SessionViewModel(analytics);
await session.signIn('user-42');
await session.signOut();

analytics.assertIdentified('user-42'); // passes even after the later reset
expect(analytics.records, [const IdentifiedRecord(Identity('user-42')), const ResetRecord()]);
```

## Your own checks

```dart
analytics.assertTracked(
  'order_paid',
  (event) => expect((event.event as OrderPaid).total, closeTo(9.99, 0.001)),
);
expect(analytics.events.single, isA<OrderPaid>());
expect(analytics.properties.single.value, const AnalyticsInt(1));
```

`clear()` forgets everything recorded so far, for tests with several steps.

## When something is wrong

Every failure explains itself and lists everything the fake received:

```
Event 'checkout_started' parameter 'seats' was AnalyticsInt(3), expected AnalyticsString(3).

Recorded:
  1. event    checkout_started { plan = pro, seats = 3 }
```

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
