# Herald for Meta

Sends Herald events to Meta's App Events, over
[`facebook_app_events`](https://pub.dev/packages/facebook_app_events): conversions and purchases,
for Meta's ads. Meta keeps no user attributes, so this package handles events only.

```bash
flutter pub add facebook_app_events herald_meta
```

Set Meta's app id and client token in both native projects, as that plugin's README shows, and turn
its automatic collection off there too, so Meta logs nothing by itself before consent.

```dart
final appEvents = FacebookAppEvents();
final service = MetaAnalyticsService(appEvents);

final tracker = MetaAnalyticsTrackerService(
  eventTrackerFactory: CompositeMetaEventTrackerFactory(conversionFactories),
);

final provider = HeraldProvider(
  name: 'meta',
  events: tracker, // no properties
  identity: service,
  lifecycle: service,
  consent: service,
);
```

**Consent.** `setEnabled` turns Meta's own collection on or off: the events it logs by itself, such
as installs, and the advertiser id. It doesn't stop the events your app logs. Call it with the
stored answer on every launch.

Purchases go through `MetaPurchaseEvent` (`fb_mobile_purchase`), and other conversions under Meta's
standard names, such as `FacebookAppEvents.eventNameCompletedRegistration`.

## Documentation

It works with [`herald`](https://pub.dev/packages/herald), the core, whose page lists every Herald
package. The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides, and
the [repository](https://github.com/MkhytarMkhoian/herald-flutter) has an example app.
