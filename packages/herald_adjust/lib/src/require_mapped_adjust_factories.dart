import 'package:herald/herald.dart';

import 'adjust_event_tracker.dart';
import 'adjust_event_tracker_factory.dart';
import 'adjust_property_setter.dart';
import 'adjust_property_setter_factory.dart';

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
final class const RequireMappedAdjustEventTrackerFactory()
    implements AdjustEventTrackerFactory, FallbackFactory {
  @override
  Resolution<AdjustEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedAdjustEventTrackerFactory';
}

final class const RequireMappedAdjustPropertySetterFactory()
    implements AdjustPropertySetterFactory, FallbackFactory {
  @override
  Resolution<AdjustPropertySetter> create(Property property) =>
      throw UnhandledPropertyException(property);

  @override
  String toString() => 'RequireMappedAdjustPropertySetterFactory';
}
