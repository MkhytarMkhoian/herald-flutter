# Herald for Amplitude

Sends Herald events and properties to Amplitude, over
[`amplitude_flutter`](https://pub.dev/packages/amplitude_flutter): events, user properties,
screen views and revenue.

```dart
final amplitude = Amplitude(
  Configuration(
    apiKey: apiKey,
    optOut: true, // silent until consent
    autocapture: const AutocaptureOptions(screenViews: false), // Herald sends screen views
  ),
);
final tracker = AmplitudeAnalyticsTrackerService(
  eventTrackerFactory: CompositeAmplitudeEventTrackerFactory([
    ScreenViewAmplitudeEventTrackerFactory(amplitude),
    GenericAmplitudeEventTrackerFactory(amplitude),
  ]),
  propertySetterFactory: CompositeAmplitudePropertySetterFactory([
    GenericAmplitudePropertySetterFactory(amplitude),
  ]),
);
final service = AmplitudeAnalyticsService(amplitude);
```

Values keep their types. A `ScreenViewEvent` becomes `[Amplitude] Screen Viewed`, and purchases go
through `AmplitudeRevenueEvent` and `RevenueAmplitudeEventTracker`, deduplicated by `insertId`.
Amplitude forgets the opt-out between launches, so re-apply the stored answer after `start()`.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald-docs/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
