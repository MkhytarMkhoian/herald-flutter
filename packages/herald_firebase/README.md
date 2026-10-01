# Herald for Firebase

Sends Herald events and properties to Firebase Analytics (GA4), over
[`firebase_analytics`](https://pub.dev/packages/firebase_analytics).

```dart
final analytics = FirebaseAnalytics.instance; // after Firebase.initializeApp()
final tracker = FirebaseAnalyticsTrackerService(
  eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
    ScreenViewFirebaseEventTrackerFactory(analytics), // GA4's reserved screen_view
    GenericFirebaseEventTrackerFactory(analytics), // everything else, as-is
  ]),
  propertySetterFactory: CompositeFirebasePropertySetterFactory([
    GenericFirebasePropertySetterFactory(analytics),
  ]),
);
final service = FirebaseAnalyticsService(analytics);

final provider = HeraldProvider(
  name: 'firebase',
  events: tracker,
  properties: tracker,
  identity: service,
  lifecycle: service,
  consent: service,
);
```

| Herald | Firebase |
| --- | --- |
| an event | `logEvent`, with numbers as numbers and flags as `'true'`/`'false'` |
| a `ScreenViewEvent` | `logScreenView(screenName: name)` |
| a property | `setUserProperty`, in its string form |
| `identify` / `reset` | `setUserId(id: ...)` / `setUserId()` |
| `setEnabled` | `setAnalyticsCollectionEnabled` |

Herald's error reporter can send vendor failures to Crashlytics, with a one-line reason:

```dart
final herald = Herald(
  providers: [provider],
  errorReporter: (failure) => FirebaseCrashlytics.instance.recordError(
    failure.error,
    failure.stackTrace,
    reason: '$failure', // firebase failed on Track(checkout_started): ...
  ),
);
```

**Firebase collects before consent** unless its native flags turn collection off:
`firebase_analytics_collection_enabled=false` in the Android manifest and
`FIREBASE_ANALYTICS_COLLECTION_ENABLED=NO` in `Info.plist`.

## Documentation

The [Herald website](https://mkhytarmkhoian.github.io/herald/) has the guides, and the
[repository](https://github.com/MkhytarMkhoian/herald-flutter) has the other packages and an
example app.
