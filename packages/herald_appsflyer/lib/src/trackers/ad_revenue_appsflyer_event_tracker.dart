import 'package:appsflyer_sdk/appsflyer_sdk.dart';

import '../appsflyer_event_tracker.dart';
import '../appsflyer_revenue_events.dart';
import '../appsflyer_values.dart';

final class const AdRevenueAppsFlyerEventTracker(
  final AppsFlyerAdRevenueEvent event,
  final AppsFlyerSdk appsFlyer,
) implements AppsFlyerEventTracker {
  @override
  Future<void> track() => appsFlyer.logAdRevenue(
    monetizationNetwork: event.monetizationNetwork,
    mediationNetwork: event.mediationNetwork,
    currencyIso4217Code: event.currency,
    revenue: event.revenue,
    additionalParameters: event.parameters.toAppsFlyerEventValues(),
  );
}
