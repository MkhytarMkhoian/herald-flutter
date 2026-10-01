import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:herald/herald.dart';

import '../amplitude_event_tracker.dart';
import '../amplitude_values.dart';

const _screenViewedEvent = '[Amplitude] Screen Viewed';
const _screenNameProperty = '[Amplitude] Screen Name';

/// Tracks [event] as Amplitude's own `[Amplitude] Screen Viewed`, with its name as
/// `[Amplitude] Screen Name`.
///
/// Turn Amplitude's own screen-view capture off (`AutocaptureOptions(screenViews: false)`, and no
/// `AmplitudeNavigatorObserver`), or every screen is counted twice.
///
/// Throws an [ArgumentError] if the event has its own `[Amplitude] Screen Name` parameter, because
/// it would replace the screen's name.
final class const ScreenViewAmplitudeEventTracker(
  final ScreenViewEvent event,
  final Amplitude amplitude,
) implements AmplitudeEventTracker {
  @override
  Future<void> track() {
    final properties = event.parameters.toAmplitudeProperties();
    if (properties.containsKey(_screenNameProperty)) {
      throw ArgumentError.value(
        event.name,
        'event',
        "A screen view can't have a '$_screenNameProperty' parameter: it holds the screen's name",
      );
    }
    return amplitude.track(
      BaseEvent(
        _screenViewedEvent,
        eventProperties: {...properties, _screenNameProperty: event.name},
      ),
    );
  }
}
