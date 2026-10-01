# Herald for Mixpanel

Sends Herald events and properties to Mixpanel, over
[`mixpanel_flutter`](https://pub.dev/packages/mixpanel_flutter): events, the People profile and
super properties.

```dart
final mixpanel = await Mixpanel.init(
  projectToken,
  trackAutomaticEvents: false,
  optOutTrackingDefault: true, // silent until consent
);
final tracker = MixpanelAnalyticsTrackerService(
  eventTrackerFactory: CompositeMixpanelEventTrackerFactory([
    ScreenViewMixpanelEventTrackerFactory(mixpanel),
    GenericMixpanelEventTrackerFactory(mixpanel),
  ]),
  propertySetterFactory: CompositeMixpanelPropertySetterFactory([
    UserPropertyMixpanelPropertySetterFactory(mixpanel), // People profile: must come first
    GenericMixpanelPropertySetterFactory(mixpanel), // super properties
  ]),
);
final service = MixpanelAnalyticsService(mixpanel);
```

Values keep their types. A `UserProperty` goes to the People profile and any other property
becomes a super property. Revoking consent flushes, then opts out.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
