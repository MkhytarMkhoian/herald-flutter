import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';
import 'package:herald_firebase/herald_firebase.dart';

import '../concepts/vocabulary.dart';

List<Object> routing(
  FirebaseAnalytics firebaseAnalytics,
  List<FirebaseEventTrackerFactory> featureFirebaseFactories,
) {
  // --8<-- [start:two-kinds]
  // Firebase gets everything: events no factory took are sent under their own name.
  final firebaseEvents = CompositeFirebaseEventTrackerFactory([
    ...featureFirebaseFactories,
    ScreenViewFirebaseEventTrackerFactory(firebaseAnalytics),
    GenericFirebaseEventTrackerFactory(firebaseAnalytics), // everything else
  ]);

  // Adjust gets only events with a dashboard token.
  final adjustEvents = CompositeAdjustEventTrackerFactory([
    TokenAdjustEventTrackerFactory({'checkout_completed': 'abc123'}),
  ]); // nothing at the end: other events aren't sent
  // --8<-- [end:two-kinds]
  return [firebaseEvents, adjustEvents];
}

// --8<-- [start:drop-property]
final class const AppAdjustPropertySetterFactory() implements AdjustPropertySetterFactory {
  @override
  Resolution<AdjustPropertySetter> create(Property property) => switch (property) {
    AppTheme() => .dropped(), // a UI preference, not an attribution signal
    _ => .declined(),
  };
}
// --8<-- [end:drop-property]
