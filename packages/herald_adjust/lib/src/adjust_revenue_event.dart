import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:herald/herald.dart';

import 'adjust_values.dart';

/// A purchase, in the fields Adjust's revenue tracking takes.
///
/// Your events don't extend it: your Adjust factory builds one from your event and sends it with
/// `RevenueAdjustEventTracker`, under the purchase's dashboard token.
final class const AdjustRevenueEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,
  required final double revenue,
  required final String currency,

  /// Makes a purchase sent twice count once.
  final String? deduplicationId,
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  AdjustEvent toAdjustEvent(String eventToken) => parameters.toAdjustEvent(eventToken)
    ..setRevenue(revenue, currency)
    ..deduplicationId = deduplicationId;

  @override
  bool operator ==(Object other) =>
      other is AdjustRevenueEvent &&
      other._fields == _fields &&
      _sameParameters(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(_fields, _hashParameters(parameters));

  (String, double, String, String?) get _fields => (name, revenue, currency, deduplicationId);

  @override
  String toString() => 'AdjustRevenueEvent($name, $revenue $currency)';
}

/// Ad revenue, in the fields Adjust's ad revenue tracking takes. Built by your Adjust factory and
/// sent with `AdRevenueAdjustEventTracker`.
final class const AdjustAdRevenueEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,

  /// Such as `applovin_max_sdk` or `admob_sdk`.
  required final String source,
  required final double revenue,
  required final String currency,
  final int? adImpressionsCount,
  final String? adRevenueNetwork,
  final String? adRevenueUnit,
  final String? adRevenuePlacement,
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  /// Parameters become callback parameters, as text.
  AdjustAdRevenue toAdjustAdRevenue() {
    final adRevenue = AdjustAdRevenue(source)
      ..setRevenue(revenue, currency)
      ..adImpressionsCount = adImpressionsCount
      ..adRevenueNetwork = adRevenueNetwork
      ..adRevenueUnit = adRevenueUnit
      ..adRevenuePlacement = adRevenuePlacement;
    for (final MapEntry(:key, :value) in parameters.entries) {
      adRevenue.addCallbackParameter(key, value.asString);
    }
    return adRevenue;
  }

  @override
  bool operator ==(Object other) =>
      other is AdjustAdRevenueEvent &&
      other._fields == _fields &&
      _sameParameters(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(_fields, _hashParameters(parameters));

  (String, String, double, String, int?, String?, String?, String?) get _fields => (
    name,
    source,
    revenue,
    currency,
    adImpressionsCount,
    adRevenueNetwork,
    adRevenueUnit,
    adRevenuePlacement,
  );

  @override
  String toString() => 'AdjustAdRevenueEvent($name, $source, $revenue $currency)';
}

bool _sameParameters(Map<String, AnalyticsValue> a, Map<String, AnalyticsValue> b) =>
    a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

int _hashParameters(Map<String, AnalyticsValue> parameters) =>
    Object.hashAllUnordered(parameters.entries.map((it) => Object.hash(it.key, it.value)));
