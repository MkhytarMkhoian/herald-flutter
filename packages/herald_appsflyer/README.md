# Herald for AppsFlyer

Sends Herald events to AppsFlyer, over [`appsflyer_sdk`](https://pub.dev/packages/appsflyer_sdk) 7:
conversions, purchases, subscriptions and ad revenue. AppsFlyer keeps no user attributes, so this
package handles events only.

```dart
final appsFlyer = AppsFlyerSdk.instance;
await appsFlyer.init(devKey: 'YOUR_DEV_KEY', appId: 'YOUR_APPLE_APP_ID');
await appsFlyer.registerSessionReadyListener(() async {
  await appsFlyer.start();
});

final tracker = AppsFlyerAnalyticsTrackerService(
  eventTrackerFactory: CompositeAppsFlyerEventTrackerFactory(conversionFactories),
);
final service = AppsFlyerAnalyticsService(appsFlyer);

final provider = HeraldProvider(
  name: 'appsflyer',
  events: tracker, // no properties
  identity: service,
  lifecycle: service,
  consent: service,
);
```

**AppsFlyer starts on consent.** `start()` stops the SDK, and `setEnabled(true)` resumes and
starts it. AppsFlyer 7 forgets the stopped state and the customer user id between launches, so
call `identify` and then `setEnabled` with the stored answer on every cold start.

Purchases go through `AppsFlyerPurchaseEvent` (`af_purchase`), subscriptions through
`AppsFlyerSubscribeEvent` (`af_subscribe`) and ad revenue through `AppsFlyerAdRevenueEvent`.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
