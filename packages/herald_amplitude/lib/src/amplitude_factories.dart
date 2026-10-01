import 'package:amplitude_flutter/amplitude.dart';
import 'package:herald/herald.dart';

import 'amplitude_event_tracker.dart';
import 'amplitude_event_tracker_factory.dart';
import 'amplitude_property_setter.dart';
import 'amplitude_property_setter_factory.dart';
import 'setters/generic_amplitude_property_setter.dart';
import 'trackers/generic_amplitude_event_tracker.dart';
import 'trackers/screen_view_amplitude_event_tracker.dart';

/// Tracks any event under its own name, with its parameters. Claims every event, so it goes last in
/// a chain.
final class const GenericAmplitudeEventTrackerFactory(final Amplitude amplitude)
    implements AmplitudeEventTrackerFactory, FallbackFactory {
  @override
  Resolution<AmplitudeEventTracker> create(Event event) =>
      .claimed([GenericAmplitudeEventTracker(event, amplitude)]);

  @override
  String toString() => 'GenericAmplitudeEventTrackerFactory';
}

/// Claims every [ScreenViewEvent] as `[Amplitude] Screen Viewed` and declines everything else. To
/// send screen views differently, put your own factory before this one.
final class const ScreenViewAmplitudeEventTrackerFactory(final Amplitude amplitude)
    implements AmplitudeEventTrackerFactory {
  @override
  Resolution<AmplitudeEventTracker> create(Event event) => switch (event) {
    ScreenViewEvent() => .claimed([ScreenViewAmplitudeEventTracker(event, amplitude)]),
    _ => .declined(),
  };
}

/// Sets any property as an Amplitude user property, [UserProperty] included: Amplitude has one kind
/// of property. Claims every property, so it goes last in a chain.
final class const GenericAmplitudePropertySetterFactory(final Amplitude amplitude)
    implements AmplitudePropertySetterFactory, FallbackFactory {
  @override
  Resolution<AmplitudePropertySetter> create(Property property) =>
      .claimed([GenericAmplitudePropertySetter(property, amplitude)]);

  @override
  String toString() => 'GenericAmplitudePropertySetterFactory';
}
