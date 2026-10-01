import 'package:herald/herald.dart';

import 'analytics_logger.dart';
import 'log_event_tracker.dart';
import 'log_event_tracker_factory.dart';
import 'log_property_setter.dart';
import 'log_property_setter_factory.dart';
import 'setters/generic_log_property_setter.dart';
import 'trackers/generic_log_event_tracker.dart';
import 'trackers/screen_view_log_event_tracker.dart';

final class const GenericLogEventTrackerFactory(final AnalyticsLogger logger)
    implements LogEventTrackerFactory, FallbackFactory {
  @override
  Resolution<LogEventTracker> create(Event event) =>
      .claimed([GenericLogEventTracker(event, logger)]);

  @override
  String toString() => 'GenericLogEventTrackerFactory';
}

/// Claims every [ScreenViewEvent] and prints it as a screen record. Declines everything else.
final class const ScreenViewLogEventTrackerFactory(final AnalyticsLogger logger)
    implements LogEventTrackerFactory {
  @override
  Resolution<LogEventTracker> create(Event event) => switch (event) {
    ScreenViewEvent() => .claimed([ScreenViewLogEventTracker(event, logger)]),
    _ => .declined(),
  };
}

final class const GenericLogPropertySetterFactory(final AnalyticsLogger logger)
    implements LogPropertySetterFactory, FallbackFactory {
  @override
  Resolution<LogPropertySetter> create(Property property) =>
      .claimed([GenericLogPropertySetter(property, logger)]);

  @override
  String toString() => 'GenericLogPropertySetterFactory';
}
