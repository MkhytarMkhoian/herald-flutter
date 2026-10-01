import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';

import '../firebase_event_tracker.dart';
import '../firebase_values.dart';

/// Logs [event] as GA4's `screen_view`, with its name as `screen_name`.
///
/// Throws an [ArgumentError] if the event has its own `screen_name` parameter, because it would
/// replace the screen's name.
final class const ScreenViewFirebaseEventTracker(
  final ScreenViewEvent event,
  final FirebaseAnalytics analytics,
) implements FirebaseEventTracker {
  @override
  Future<void> track() {
    final parameters = event.parameters.toFirebaseParameters();
    if (parameters.containsKey('screen_name')) {
      throw ArgumentError.value(
        event.name,
        'event',
        "A screen view can't have a 'screen_name' parameter: GA4 uses it for the screen's name",
      );
    }
    return analytics.logScreenView(screenName: event.name, parameters: parameters);
  }
}
