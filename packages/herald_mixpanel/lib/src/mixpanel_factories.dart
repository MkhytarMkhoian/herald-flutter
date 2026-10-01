import 'package:herald/herald.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'mixpanel_event_tracker.dart';
import 'mixpanel_event_tracker_factory.dart';
import 'mixpanel_property_setter.dart';
import 'mixpanel_property_setter_factory.dart';
import 'setters/generic_mixpanel_property_setter.dart';
import 'setters/user_property_mixpanel_property_setter.dart';
import 'trackers/generic_mixpanel_event_tracker.dart';
import 'trackers/screen_view_mixpanel_event_tracker.dart';

/// Tracks any event under its own name, with its parameters. Claims every event, so it goes last in
/// a chain.
final class const GenericMixpanelEventTrackerFactory(final Mixpanel mixpanel)
    implements MixpanelEventTrackerFactory, FallbackFactory {
  @override
  Resolution<MixpanelEventTracker> create(Event event) =>
      .claimed([GenericMixpanelEventTracker(event, mixpanel)]);

  @override
  String toString() => 'GenericMixpanelEventTrackerFactory';
}

/// Claims every [ScreenViewEvent] as a `screen_view` event and declines everything else. To send
/// screen views differently, put your own factory before this one.
final class const ScreenViewMixpanelEventTrackerFactory(final Mixpanel mixpanel)
    implements MixpanelEventTrackerFactory {
  @override
  Resolution<MixpanelEventTracker> create(Event event) => switch (event) {
    ScreenViewEvent() => .claimed([ScreenViewMixpanelEventTracker(event, mixpanel)]),
    _ => .declined(),
  };
}

/// Claims every [UserProperty] for the People profile and declines everything else.
///
/// Put it before [GenericMixpanelPropertySetterFactory]: a [UserProperty] is also a [Property], so
/// the generic factory would take it first and the profile would never be written.
final class const UserPropertyMixpanelPropertySetterFactory(final Mixpanel mixpanel)
    implements MixpanelPropertySetterFactory {
  @override
  Resolution<MixpanelPropertySetter> create(Property property) => switch (property) {
    UserProperty() => .claimed([UserPropertyMixpanelPropertySetter(property, mixpanel)]),
    _ => .declined(),
  };
}

/// Sends every property as a super property. Put it last in the chain.
final class const GenericMixpanelPropertySetterFactory(final Mixpanel mixpanel)
    implements MixpanelPropertySetterFactory, FallbackFactory {
  @override
  Resolution<MixpanelPropertySetter> create(Property property) =>
      .claimed([GenericMixpanelPropertySetter(property, mixpanel)]);

  @override
  String toString() => 'GenericMixpanelPropertySetterFactory';
}
