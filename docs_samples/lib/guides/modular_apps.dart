import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';
import 'package:herald_firebase/herald_firebase.dart';

import '../concepts/factory_chain.dart';

// --8<-- [start:feature]
// The checkout feature package exposes its factories, and knows nothing about the app's other
// vendors.
abstract final class CheckoutAnalytics {
  static List<FirebaseEventTrackerFactory> firebase(FirebaseAnalytics firebaseAnalytics) => [
    CheckoutFirebaseEventTrackerFactory(firebaseAnalytics),
  ];
}
// --8<-- [end:feature]

// --8<-- [start:root]
// The app builds the Firebase provider from whatever the features contribute.
HeraldProvider firebaseProvider(
  FirebaseAnalytics firebaseAnalytics,
  List<FirebaseEventTrackerFactory> featureFactories, // from every feature, any order
) {
  final tracker = FirebaseAnalyticsTrackerService(
    eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
      ...featureFactories,
      ScreenViewFirebaseEventTrackerFactory(firebaseAnalytics), // then placed by hand
      GenericFirebaseEventTrackerFactory(firebaseAnalytics),
    ]),
    propertySetterFactory: CompositeFirebasePropertySetterFactory([
      GenericFirebasePropertySetterFactory(firebaseAnalytics),
    ]),
  );
  final service = FirebaseAnalyticsService(firebaseAnalytics);
  return HeraldProvider(
    name: 'firebase',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

HeraldProvider appFirebaseProvider(FirebaseAnalytics firebaseAnalytics) =>
    firebaseProvider(firebaseAnalytics, [
      ...CheckoutAnalytics.firebase(firebaseAnalytics),
      // ...ProfileAnalytics.firebase(firebaseAnalytics), one line per feature
    ]);
// --8<-- [end:root]
