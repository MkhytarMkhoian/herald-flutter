import 'package:adjust_sdk/adjust.dart';

import '../adjust_event_tracker.dart';
import '../adjust_revenue_event.dart';

/// Sends ad revenue. Unlike events, it needs no dashboard token.
final class const AdRevenueAdjustEventTracker(final AdjustAdRevenueEvent event)
    implements AdjustEventTracker {
  @override
  Future<void> track() async => Adjust.trackAdRevenue(event.toAdjustAdRevenue());
}
