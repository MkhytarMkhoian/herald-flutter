import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';
import 'package:herald_firebase/herald_firebase.dart';

final class const PayTapped(final String plan) extends Event {
  @override
  String get name => 'pay_tapped';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan)};
}

final class const CardNumberSeen(final String last4) extends Event {
  @override
  String get name => 'card_number_seen';
}

final class const CheckoutCompleted(final double value, final String currency) extends Event {
  @override
  String get name => 'checkout_completed';

  @override
  Map<String, AnalyticsValue> get parameters => {
    'value': .double(value),
    'currency': .string(currency),
  };
}

// --8<-- [start:tracker]
final class const PurchaseFirebaseEventTracker(
  final CheckoutCompleted event,
  final FirebaseAnalytics firebaseAnalytics,
) implements FirebaseEventTracker {
  @override
  Future<void> track() =>
      // GA4's recommended purchase event, with the typed parameters.
      firebaseAnalytics.logEvent(
        name: 'purchase',
        parameters: event.parameters.toFirebaseParameters(),
      );
}
// --8<-- [end:tracker]

// --8<-- [start:factory]
final class const CheckoutFirebaseEventTrackerFactory(final FirebaseAnalytics firebaseAnalytics)
    implements FirebaseEventTrackerFactory {
  @override
  Resolution<FirebaseEventTracker> create(Event event) => switch (event) {
    CheckoutCompleted() => .claimed([PurchaseFirebaseEventTracker(event, firebaseAnalytics)]),
    PayTapped() => .claimed([
      GenericFirebaseEventTracker(event, firebaseAnalytics),
    ]), // Herald's own
    CardNumberSeen() => .dropped(), // mine, and it goes nowhere
    _ => .declined(), // not mine: ask the next factory
  };
}
// --8<-- [end:factory]

List<FirebaseEventTrackerFactory> chains(FirebaseAnalytics firebaseAnalytics) {
  // --8<-- [start:chain]
  final chain = CompositeFirebaseEventTrackerFactory([
    CheckoutFirebaseEventTrackerFactory(firebaseAnalytics), // feature factories first
    ScreenViewFirebaseEventTrackerFactory(firebaseAnalytics), // then Herald's screen views
    GenericFirebaseEventTrackerFactory(firebaseAnalytics), // then everything else
  ]);
  // --8<-- [end:chain]

  // --8<-- [start:strict]
  final strict = CompositeFirebaseEventTrackerFactory([
    CheckoutFirebaseEventTrackerFactory(firebaseAnalytics),
    ScreenViewFirebaseEventTrackerFactory(firebaseAnalytics),
    const RequireMappedFirebaseEventTrackerFactory(), // an unclaimed event is reported
  ]);
  // --8<-- [end:strict]
  return [chain, strict];
}

List<Object> defaultRules(
  FirebaseAnalytics firebaseAnalytics,
  List<FirebaseEventTrackerFactory> firebaseFactories,
  List<AdjustEventTrackerFactory> adjustFactories,
) {
  // --8<-- [start:default]
  // Firebase: events without a factory of their own are still sent, under their own name.
  final firebase = CompositeFirebaseEventTrackerFactory([
    ...firebaseFactories,
    GenericFirebaseEventTrackerFactory(firebaseAnalytics),
  ]);

  // Adjust: nothing at the end, so only events a factory handled are sent.
  final adjust = CompositeAdjustEventTrackerFactory(adjustFactories);
  // --8<-- [end:default]
  return [firebase, adjust];
}
