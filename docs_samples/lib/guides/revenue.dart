import 'package:amplitude_flutter/amplitude.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';
import 'package:herald_adjust/herald_adjust.dart';
import 'package:herald_amplitude/herald_amplitude.dart';
import 'package:herald_appsflyer/herald_appsflyer.dart';

// --8<-- [start:purchase]
final class const SubscriptionPurchased({
  required final String plan,
  required final double price,
  required final String currency,
  required final String orderId,
}) extends Event {
  // Firebase and Mixpanel log it as it is: GA4's recommended purchase, with typed parameters.
  @override
  String get name => 'purchase';

  @override
  Map<String, AnalyticsValue> get parameters => {
    'value': .double(price),
    'currency': .string(currency),
    'plan': .string(plan),
  };
}
// --8<-- [end:purchase]

// --8<-- [start:mappings]
extension SubscriptionPurchasedMappings on SubscriptionPurchased {
  // Adjust: the tokened event, plus revenue, counted once per transaction.
  AdjustRevenueEvent toAdjustRevenueEvent() => AdjustRevenueEvent(
    name: name,
    revenue: price,
    currency: currency,
    deduplicationId: orderId,
    parameters: parameters,
  );

  // AppsFlyer: af_purchase, with the amount under af_revenue.
  AppsFlyerPurchaseEvent toAppsFlyerPurchaseEvent() => AppsFlyerPurchaseEvent(
    name: name,
    revenue: price,
    currency: currency,
    contentId: plan,
    orderId: orderId,
    parameters: parameters,
  );

  // Amplitude: the revenue API, deduplicated by the insert id.
  AmplitudeRevenueEvent toAmplitudeRevenueEvent() => AmplitudeRevenueEvent(
    name: name,
    price: price,
    productId: plan,
    currency: currency,
    insertId: orderId,
    parameters: parameters,
  );
}
// --8<-- [end:mappings]

// --8<-- [start:factories]
final class const BillingAdjustEventTrackerFactory() implements AdjustEventTrackerFactory {
  @override
  Resolution<AdjustEventTracker> create(Event event) => switch (event) {
    SubscriptionPurchased() => .claimed([
      RevenueAdjustEventTracker(event.toAdjustRevenueEvent(), 'abc123'),
    ]),
    _ => .declined(),
  };
}

final class const BillingAppsFlyerEventTrackerFactory(final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTrackerFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) => switch (event) {
    SubscriptionPurchased() => .claimed([
      PurchaseAppsFlyerEventTracker(event.toAppsFlyerPurchaseEvent(), appsFlyer),
    ]),
    _ => .declined(),
  };
}

final class const BillingAmplitudeEventTrackerFactory(final Amplitude amplitude)
    implements AmplitudeEventTrackerFactory {
  @override
  Resolution<AmplitudeEventTracker> create(Event event) => switch (event) {
    SubscriptionPurchased() => .claimed([
      RevenueAmplitudeEventTracker(event.toAmplitudeRevenueEvent(), amplitude),
    ]),
    _ => .declined(),
  };
}
// --8<-- [end:factories]

// --8<-- [start:ad-impression]
final class const AdImpression(final double revenue, final String network) extends Event {
  @override
  String get name => 'ad_impression';

  @override
  Map<String, AnalyticsValue> get parameters => {'network': .string(network)};

  AdjustAdRevenueEvent toAdjustAdRevenueEvent() => AdjustAdRevenueEvent(
    name: name,
    source: 'applovin_max_sdk',
    revenue: revenue,
    currency: 'USD',
    adRevenueNetwork: network,
    parameters: parameters,
  );

  AppsFlyerAdRevenueEvent toAppsFlyerAdRevenueEvent() => AppsFlyerAdRevenueEvent(
    name: name,
    monetizationNetwork: network,
    mediationNetwork: AFMediationNetwork.applovinMax,
    revenue: revenue,
    currency: 'USD',
    parameters: parameters,
  );
}

final class const AdsAdjustEventTrackerFactory() implements AdjustEventTrackerFactory {
  @override
  Resolution<AdjustEventTracker> create(Event event) => switch (event) {
    AdImpression() => .claimed([AdRevenueAdjustEventTracker(event.toAdjustAdRevenueEvent())]),
    _ => .declined(),
  };
}

final class const AdsAppsFlyerEventTrackerFactory(final AppsFlyerSdk appsFlyer)
    implements AppsFlyerEventTrackerFactory {
  @override
  Resolution<AppsFlyerEventTracker> create(Event event) => switch (event) {
    AdImpression() => .claimed([
      AdRevenueAppsFlyerEventTracker(event.toAppsFlyerAdRevenueEvent(), appsFlyer),
    ]),
    _ => .declined(),
  };
}
// --8<-- [end:ad-impression]
