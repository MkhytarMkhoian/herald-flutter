import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:herald/herald.dart';

import '../meta_event_tracker.dart';
import '../meta_values.dart';

/// Logs the event under its own name, with its parameters.
final class const GenericMetaEventTracker(final Event event, final FacebookAppEvents appEvents)
    implements MetaEventTracker {
  @override
  Future<void> track() =>
      appEvents.logEvent(name: event.name, parameters: event.parameters.toMetaParameters());
}
