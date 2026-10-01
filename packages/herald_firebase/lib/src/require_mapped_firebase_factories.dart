import 'package:herald/herald.dart';

import 'firebase_event_tracker.dart';
import 'firebase_event_tracker_factory.dart';
import 'firebase_property_setter.dart';
import 'firebase_property_setter_factory.dart';

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
final class const RequireMappedFirebaseEventTrackerFactory()
    implements FirebaseEventTrackerFactory, FallbackFactory {
  @override
  Resolution<FirebaseEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedFirebaseEventTrackerFactory';
}

final class const RequireMappedFirebasePropertySetterFactory()
    implements FirebasePropertySetterFactory, FallbackFactory {
  @override
  Resolution<FirebasePropertySetter> create(Property property) =>
      throw UnhandledPropertyException(property);

  @override
  String toString() => 'RequireMappedFirebasePropertySetterFactory';
}
