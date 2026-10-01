import 'package:herald/herald.dart';

import 'log_event_tracker.dart';
import 'log_event_tracker_factory.dart';
import 'log_property_setter.dart';
import 'log_property_setter_factory.dart';

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
final class const RequireMappedLogEventTrackerFactory()
    implements LogEventTrackerFactory, FallbackFactory {
  @override
  Resolution<LogEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedLogEventTrackerFactory';
}

final class const RequireMappedLogPropertySetterFactory()
    implements LogPropertySetterFactory, FallbackFactory {
  @override
  Resolution<LogPropertySetter> create(Property property) =>
      throw UnhandledPropertyException(property);

  @override
  String toString() => 'RequireMappedLogPropertySetterFactory';
}
