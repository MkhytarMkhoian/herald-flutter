# Herald

Events, properties and the `Herald` fan-out: the core of Herald for Flutter, in pure Dart,
with no Flutter, vendor SDK or DI library. Vendors are separate packages.

```dart
final class CheckoutStarted extends Event {
  const CheckoutStarted(this.plan, this.seats);

  final String plan;
  final int seats;

  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

final herald = Herald(
  providers: [
    HeraldProvider(name: 'analytics', events: analyticsTracker, properties: analyticsTracker),
    HeraldProvider(name: 'attribution', events: attributionTracker),
  ],
  errorReporter: (failure) => report(failure.error, failure.stackTrace),
);

await herald.track(const CheckoutStarted('pro', 3));
```

`Herald` implements all five capabilities — `EventTrackerService`, `PropertyTrackerService`,
`IdentifiableUserService`, `AnalyticsLifecycleService` and `ConsentService` — so give your classes
the one interface they use.

Each call runs against every vendor at once, and a failing vendor is reported without stopping
the others. Calls don't wait for each other, so when order matters, await the earlier call.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
