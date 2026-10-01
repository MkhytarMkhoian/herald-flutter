import 'package:herald/herald.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../mixpanel_event_tracker.dart';
import '../mixpanel_values.dart';

const _screenViewEvent = 'screen_view';
const _screenNameProperty = 'screen_name';

/// Tracks [event] as a `screen_view` event, with its name as `screen_name`: the names GA4 uses, since
/// Mixpanel has none of its own.
///
/// Throws an [ArgumentError] if the event has its own `screen_name` parameter, because it would
/// replace the screen's name.
final class const ScreenViewMixpanelEventTracker(
  final ScreenViewEvent event,
  final Mixpanel mixpanel,
) implements MixpanelEventTracker {
  @override
  Future<void> track() {
    final properties = event.parameters.toMixpanelProperties();
    if (properties.containsKey(_screenNameProperty)) {
      throw ArgumentError.value(
        event.name,
        'event',
        "A screen view can't have a '$_screenNameProperty' parameter: it holds the screen's name",
      );
    }
    return mixpanel.track(
      _screenViewEvent,
      properties: {...properties, _screenNameProperty: event.name},
    );
  }
}
