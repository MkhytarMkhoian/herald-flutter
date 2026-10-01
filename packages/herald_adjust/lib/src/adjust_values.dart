import 'package:adjust_sdk/adjust_event.dart';
import 'package:herald/herald.dart';

extension AdjustParameters on Map<String, AnalyticsValue> {
  /// An [AdjustEvent] for the dashboard event [eventToken], with these parameters as callback
  /// parameters. Adjust's parameters are text, so values are sent in their string form.
  AdjustEvent toAdjustEvent(String eventToken) {
    final adjustEvent = AdjustEvent(eventToken);
    for (final MapEntry(:key, :value) in entries) {
      adjustEvent.addCallbackParameter(key, value.asString);
    }
    return adjustEvent;
  }
}
