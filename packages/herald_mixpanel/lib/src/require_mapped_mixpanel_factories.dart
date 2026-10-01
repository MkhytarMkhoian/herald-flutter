import 'package:herald/herald.dart';

import 'mixpanel_event_tracker.dart';
import 'mixpanel_event_tracker_factory.dart';
import 'mixpanel_property_setter.dart';
import 'mixpanel_property_setter_factory.dart';

/// Fails for any event that reaches it, so the error reporter shows events nobody mapped. Put it
/// last in a chain.
final class const RequireMappedMixpanelEventTrackerFactory()
    implements MixpanelEventTrackerFactory, FallbackFactory {
  @override
  Resolution<MixpanelEventTracker> create(Event event) => throw UnhandledEventException(event);

  @override
  String toString() => 'RequireMappedMixpanelEventTrackerFactory';
}

final class const RequireMappedMixpanelPropertySetterFactory()
    implements MixpanelPropertySetterFactory, FallbackFactory {
  @override
  Resolution<MixpanelPropertySetter> create(Property property) =>
      throw UnhandledPropertyException(property);

  @override
  String toString() => 'RequireMappedMixpanelPropertySetterFactory';
}
