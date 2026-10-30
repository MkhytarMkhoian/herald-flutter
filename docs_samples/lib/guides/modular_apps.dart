import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';
import 'package:herald_firebase/herald_firebase.dart';

import '../concepts/factory_chain.dart';
import '../quick_start.dart';

// --8<-- [start:feature]
// The checkout feature package exposes its factories, and knows nothing about the app's other
// vendors.
abstract final class CheckoutFactories {
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
      ...CheckoutFactories.firebase(firebaseAnalytics),
      // ...ProfileAnalytics.firebase(firebaseAnalytics), one line per feature
    ]);
// --8<-- [end:root]

// --8<-- [start:vendor-module]
// The Firebase package knows every feature's events, through their API packages, so it lists the
// factories itself.
HeraldProvider firebaseVendorProvider(FirebaseAnalytics firebaseAnalytics) {
  final tracker = FirebaseAnalyticsTrackerService(
    eventTrackerFactory: CompositeFirebaseEventTrackerFactory([
      CheckoutFirebaseEventTrackerFactory(firebaseAnalytics), // one for each feature that needs one
      ScreenViewFirebaseEventTrackerFactory(firebaseAnalytics),
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
// --8<-- [end:vendor-module]

// --8<-- [start:interface]
// The checkout API package: one method for each thing that can happen. No Herald, no vendors.
abstract interface class CheckoutAnalytics {
  Future<void> checkoutStarted(String plan, int seats);
  Future<void> paymentFailed(String reason);
}
// --8<-- [end:interface]

// --8<-- [start:feature]
// The checkout feature calls the interface, and knows nothing about analytics libraries.
class PaymentViewModel(final CheckoutAnalytics analytics) {
  Future<void> onPaymentFailed(String reason) => analytics.paymentFailed(reason);
}
// --8<-- [end:feature]

// --8<-- [start:implementation]
// The analytics package owns the events, and turns each call into one.
final class const PaymentFailed(final String reason) extends Event {
  @override
  String get name => 'payment_failed';

  @override
  Map<String, AnalyticsValue> get parameters => {'reason': .string(reason)};
}

final class HeraldCheckoutAnalytics(final EventTrackerService analytics)
    implements CheckoutAnalytics {
  @override
  Future<void> checkoutStarted(String plan, int seats) =>
      analytics.track(CheckoutStarted(plan, seats));

  @override
  Future<void> paymentFailed(String reason) => analytics.track(PaymentFailed(reason));
}
// --8<-- [end:implementation]

// --8<-- [start:binding]
// The app hands each feature its interface, backed by Herald.
PaymentViewModel createPaymentViewModel(Herald herald) =>
    PaymentViewModel(HeraldCheckoutAnalytics(herald));
// --8<-- [end:binding]
