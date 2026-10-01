import 'package:herald/herald.dart';

import 'amplitude_event_tracker.dart';
import 'amplitude_event_tracker_factory.dart';
import 'amplitude_property_setter.dart';
import 'amplitude_property_setter_factory.dart';

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
final class const RequireMappedAmplitudeEventTrackerFactory()
    implements AmplitudeEventTrackerFactory, FallbackFactory {
  @override
  Resolution<AmplitudeEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedAmplitudeEventTrackerFactory';
}

final class const RequireMappedAmplitudePropertySetterFactory()
    implements AmplitudePropertySetterFactory, FallbackFactory {
  @override
  Resolution<AmplitudePropertySetter> create(Property property) =>
      throw UnhandledPropertyException(property);

  @override
  String toString() => 'RequireMappedAmplitudePropertySetterFactory';
}
