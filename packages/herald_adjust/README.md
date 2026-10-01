# Herald for Adjust

Sends Herald events to Adjust, over [`adjust_sdk`](https://pub.dev/packages/adjust_sdk): events by
dashboard token, purchases and ad revenue.

```dart
final tracker = AdjustAnalyticsTrackerService(
  eventTrackerFactory: CompositeAdjustEventTrackerFactory([
    TokenAdjustEventTrackerFactory({'checkout_completed': 'abc123'}),
  ]), // nothing at the end: only tokened events are sent
  propertySetterFactory: CompositeAdjustPropertySetterFactory([
    const GenericAdjustPropertySetterFactory(),
  ]),
);
final service = AdjustAnalyticsService(
  AdjustConfig('YOUR_APP_TOKEN', AdjustEnvironment.production),
);
```

**Adjust starts silent.** `start()` turns Adjust off and only then starts it, so nothing is sent
until `setEnabled(true)`. Let the service start Adjust; don't call `Adjust.initSdk` yourself.

Adjust's plugin doesn't wait for its native side, so Herald can't report a failure that happens
there.

Purchases go through `AdjustRevenueEvent` and `RevenueAdjustEventTracker`, ad revenue through
`AdjustAdRevenueEvent` and `AdRevenueAdjustEventTracker`. Your factory builds them from your own
events.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
