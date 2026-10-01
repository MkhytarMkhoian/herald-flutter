import 'package:adjust_sdk/adjust.dart';
import 'package:herald/herald.dart';

import '../adjust_event_tracker.dart';
import '../adjust_values.dart';

/// Sends [event] under [eventToken]. Its name isn't sent: the token identifies the event.
final class const TokenAdjustEventTracker(final Event event, final String eventToken)
    implements AdjustEventTracker {
  @override
  Future<void> track() async => Adjust.trackEvent(event.parameters.toAdjustEvent(eventToken));
}
