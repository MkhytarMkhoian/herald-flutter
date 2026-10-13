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

## Packages

Add the vendors you use, each over that vendor's official Flutter plugin:

| Package | What it is |
| --- | --- |
| [`herald_firebase`](https://pub.dev/packages/herald_firebase) | Sends to Firebase Analytics (GA4). |
| [`herald_adjust`](https://pub.dev/packages/herald_adjust) | Sends to Adjust: events by dashboard token, purchases and ad revenue. |
| [`herald_mixpanel`](https://pub.dev/packages/herald_mixpanel) | Sends to Mixpanel: events, user profile and super properties. |
| [`herald_appsflyer`](https://pub.dev/packages/herald_appsflyer) | Sends to AppsFlyer: conversions, purchases, subscriptions and ad revenue. |
| [`herald_amplitude`](https://pub.dev/packages/herald_amplitude) | Sends to Amplitude: events, user properties, screen views and revenue. |
| [`herald_log`](https://pub.dev/packages/herald_log) | Prints every call, for debug builds. |
| [`herald_testing`](https://pub.dev/packages/herald_testing) | `FakeAnalyticsProvider`, a fake vendor that records events so your tests can check them. |
| [`herald_widgets`](https://pub.dev/packages/herald_widgets) | Optional: tracking from widgets, such as screen views and impressions. |

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has an example app.
