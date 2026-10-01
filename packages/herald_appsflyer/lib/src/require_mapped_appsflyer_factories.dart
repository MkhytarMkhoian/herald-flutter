import 'package:herald/herald.dart';

import 'appsflyer_event_tracker.dart';
import 'appsflyer_event_tracker_factory.dart';

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
final class const RequireMappedAppsFlyerEventTrackerFactory()
    implements AppsFlyerEventTrackerFactory, FallbackFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedAppsFlyerEventTrackerFactory';
}
