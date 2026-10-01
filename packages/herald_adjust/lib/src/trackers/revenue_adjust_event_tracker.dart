import 'package:adjust_sdk/adjust.dart';

import '../adjust_event_tracker.dart';
import '../adjust_revenue_event.dart';

final class const RevenueAdjustEventTracker(final AdjustRevenueEvent event, final String eventToken)
    implements AdjustEventTracker {
  @override
  Future<void> track() async => Adjust.trackEvent(event.toAdjustEvent(eventToken));
}
