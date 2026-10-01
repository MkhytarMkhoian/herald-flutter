import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';

import 'firebase_event_tracker.dart';
import 'firebase_event_tracker_factory.dart';
import 'firebase_property_setter.dart';
import 'firebase_property_setter_factory.dart';
import 'setters/generic_firebase_property_setter.dart';
import 'trackers/generic_firebase_event_tracker.dart';
import 'trackers/screen_view_firebase_event_tracker.dart';

/// Logs any event under its own name, with its parameters. Claims every event, so it goes last in a
/// chain.
final class const GenericFirebaseEventTrackerFactory(final FirebaseAnalytics analytics)
    implements FirebaseEventTrackerFactory, FallbackFactory {
  @override
  Resolution<FirebaseEventTracker> create(Event event) =>
      .claimed([GenericFirebaseEventTracker(event, analytics)]);

  @override
  String toString() => 'GenericFirebaseEventTrackerFactory';
}

/// Claims every [ScreenViewEvent] and declines everything else.
///
/// GA4 records a screen view as its own `screen_view` event, with the screen name as a parameter,
/// so screen views can't go through the generic factory. To send them differently, put your own
/// factory before this one.
final class const ScreenViewFirebaseEventTrackerFactory(final FirebaseAnalytics analytics)
    implements FirebaseEventTrackerFactory {
  @override
  Resolution<FirebaseEventTracker> create(Event event) => switch (event) {
    ScreenViewEvent() => .claimed([ScreenViewFirebaseEventTracker(event, analytics)]),
    _ => .declined(),
  };
}

/// Sets any property as a Firebase user property, [UserProperty] included: Firebase has one kind of
/// property. Claims every property, so it goes last in a chain.
final class const GenericFirebasePropertySetterFactory(final FirebaseAnalytics analytics)
    implements FirebasePropertySetterFactory, FallbackFactory {
  @override
  Resolution<FirebasePropertySetter> create(Property property) =>
      .claimed([GenericFirebasePropertySetter(property, analytics)]);

  @override
  String toString() => 'GenericFirebasePropertySetterFactory';
}
