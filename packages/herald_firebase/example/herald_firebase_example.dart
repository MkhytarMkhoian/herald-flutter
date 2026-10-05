import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_firebase/herald_firebase.dart';

final class const CheckoutStarted(final String plan, final int seats) extends Event {
  @override
  String get name => 'checkout_started';

  @override
  Map<String, AnalyticsValue> get parameters => {'plan': .string(plan), 'seats': .int(seats)};
}

HeraldProvider firebaseProvider(FirebaseAnalytics analytics) {
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
  return HeraldProvider(
    name: 'firebase',
    events: tracker,
    properties: tracker,
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Call Firebase.initializeApp() here, as Firebase's setup guide shows.
  final herald = Herald(providers: [firebaseProvider(FirebaseAnalytics.instance)]);

  await herald.start();
  await herald.track(const CheckoutStarted('pro', 3));
}
