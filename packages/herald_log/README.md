# Herald log

A Herald vendor that prints every call as a readable record, for debug builds:

```
[herald] event   checkout_started
    ├─ plan  = pro
    └─ seats = 3
[herald] prop    total_purchases = 2
[herald] reset
```

```dart
final AnalyticsLogger logger = debugPrint;
final logTracker = LogAnalyticsTrackerService(
  eventTrackerFactory: CompositeLogEventTrackerFactory([
    ScreenViewLogEventTrackerFactory(logger),
    GenericLogEventTrackerFactory(logger),
  ]),
  propertySetterFactory: CompositeLogPropertySetterFactory([
    GenericLogPropertySetterFactory(logger),
  ]),
);
final logService = LogAnalyticsService(logger);

final herald = Herald(
  providers: [
    if (kDebugMode)
      HeraldProvider(
        name: 'log',
        events: logTracker,
        properties: logTracker,
        identity: logService,
        lifecycle: logService,
        consent: logService,
      ),
  ],
);
```

The user id is printed as-is, so register this provider in debug builds only.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
