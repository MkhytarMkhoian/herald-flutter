import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:herald/herald.dart';

import '../amplitude_event_tracker.dart';
import '../amplitude_values.dart';

final class const GenericAmplitudeEventTracker(final Event event, final Amplitude amplitude)
    implements AmplitudeEventTracker {
  @override
  Future<void> track() => amplitude.track(
    BaseEvent(event.name, eventProperties: event.parameters.toAmplitudeProperties()),
  );
}
