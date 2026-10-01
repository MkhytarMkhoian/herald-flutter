import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../appsflyer_event_tracker.dart';
import '../appsflyer_revenue_events.dart';

final class const PurchaseAppsFlyerEventTracker(
  final AppsFlyerPurchaseEvent event,
  final AppsFlyerSdk appsFlyer,
) implements AppsFlyerEventTracker {
  @override
  Future<void> track() =>
      appsFlyer.logEvent('af_purchase', eventValues: event.toAppsFlyerEventValues());
}
