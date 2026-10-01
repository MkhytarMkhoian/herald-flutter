import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:herald/herald.dart';

import '../firebase_event_tracker.dart';
import '../firebase_values.dart';

final class const GenericFirebaseEventTracker(final Event event, final FirebaseAnalytics analytics)
    implements FirebaseEventTracker {
  @override
  Future<void> track() =>
      analytics.logEvent(name: event.name, parameters: event.parameters.toFirebaseParameters());
}
