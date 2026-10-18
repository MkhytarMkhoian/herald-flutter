import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:herald/herald.dart';

import 'meta_event_tracker.dart';
import 'meta_event_tracker_factory.dart';
import 'trackers/generic_meta_event_tracker.dart';

/// Logs any event under its own name. Claims everything, so it belongs last in a chain.
///
/// Most apps leave it out and send Meta only their conversions, each claimed by a factory of its
/// own.
final class const GenericMetaEventTrackerFactory(final FacebookAppEvents appEvents)
    implements MetaEventTrackerFactory, FallbackFactory {
  @override
  Resolution<MetaEventTracker> create(Event event) =>
      .claimed([GenericMetaEventTracker(event, appEvents)]);

  @override
  String toString() => 'GenericMetaEventTrackerFactory';
}

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped.
final class const RequireMappedMetaEventTrackerFactory()
    implements MetaEventTrackerFactory, FallbackFactory {
  @override
  Resolution<MetaEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedMetaEventTrackerFactory';
}
