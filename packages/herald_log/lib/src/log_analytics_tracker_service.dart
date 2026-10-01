import 'package:herald/herald.dart';

import 'log_event_tracker_factory.dart';
import 'log_property_setter_factory.dart';

/// Sends events and properties to the log, as its factory chains decide. The calls for one event
/// run in order, and if one fails the rest don't run. Anything no factory claims isn't sent.
final class const LogAnalyticsTrackerService({
  required final LogEventTrackerFactory eventTrackerFactory,
  required final LogPropertySetterFactory propertySetterFactory,
}) implements EventTrackerService, PropertyTrackerService {
  @override
  Future<void> track(Event event) async {
    for (final handler in eventTrackerFactory.create(event).handlers) {
      await handler.track();
    }
  }

  @override
  Future<void> set(Property property) async {
    for (final handler in propertySetterFactory.create(property).handlers) {
      await handler.set();
    }
  }
}
