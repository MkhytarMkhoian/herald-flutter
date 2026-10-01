import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:herald/herald.dart';

import 'appsflyer_values.dart';

/// A purchase, as AppsFlyer's `af_purchase`, with its revenue under `af_revenue`.
///
/// Your events don't extend it: your AppsFlyer factory builds one from your event and sends it with
/// `PurchaseAppsFlyerEventTracker`.
final class const AppsFlyerPurchaseEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,
  required final double revenue,
  required final String currency,
  final String? contentId,
  final String? contentType,
  final int? quantity,

  /// Sent as `af_order_id`. Makes a purchase sent twice count once.
  final String? orderId,

  /// Sent with the values above. Don't use their keys.
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  /// The values AppsFlyer receives. Empty optional fields are left out.
  ///
  /// Throws an [ArgumentError] if [parameters] has a key this purchase sets itself.
  Map<String, Object> toAppsFlyerEventValues() => _withParameters(this, {
    'af_revenue': revenue,
    'af_currency': currency,
    'af_content_id': ?contentId,
    'af_content_type': ?contentType,
    'af_quantity': ?quantity,
    'af_order_id': ?orderId,
  });

  @override
  bool operator ==(Object other) =>
      other is AppsFlyerPurchaseEvent &&
      other._fields == _fields &&
      _sameParameters(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(_fields, _hashParameters(parameters));

  (String, double, String, String?, String?, int?, String?) get _fields =>
      (name, revenue, currency, contentId, contentType, quantity, orderId);

  @override
  String toString() => 'AppsFlyerPurchaseEvent($name, $revenue $currency)';
}

/// A subscription, as AppsFlyer's `af_subscribe`, with its revenue under `af_revenue`. Sent with
/// `SubscribeAppsFlyerEventTracker`.
final class const AppsFlyerSubscribeEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,
  required final double revenue,
  required final String currency,

  /// Sent with the values above. Don't use their keys.
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  /// Throws an [ArgumentError] if [parameters] has a key this subscription sets itself.
  Map<String, Object> toAppsFlyerEventValues() =>
      _withParameters(this, {'af_revenue': revenue, 'af_currency': currency});

  @override
  bool operator ==(Object other) =>
      other is AppsFlyerSubscribeEvent &&
      other._fields == _fields &&
      _sameParameters(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(_fields, _hashParameters(parameters));

  (String, double, String) get _fields => (name, revenue, currency);

  @override
  String toString() => 'AppsFlyerSubscribeEvent($name, $revenue $currency)';
}

/// Ad revenue, sent with `AdRevenueAppsFlyerEventTracker`.
final class const AppsFlyerAdRevenueEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,
  required final String monetizationNetwork,
  required final AFMediationNetwork mediationNetwork,
  required final double revenue,
  required final String currency,
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  @override
  bool operator ==(Object other) =>
      other is AppsFlyerAdRevenueEvent &&
      other._fields == _fields &&
      _sameParameters(other.parameters, parameters);

  @override
  int get hashCode => Object.hash(_fields, _hashParameters(parameters));

  (String, String, AFMediationNetwork, double, String) get _fields =>
      (name, monetizationNetwork, mediationNetwork, revenue, currency);

  @override
  String toString() => 'AppsFlyerAdRevenueEvent($name, $revenue $currency)';
}

/// The event's parameters followed by [values], refusing a parameter that would be overwritten.
Map<String, Object> _withParameters(Event event, Map<String, Object> values) {
  for (final key in event.parameters.keys) {
    if (values.containsKey(key)) {
      throw ArgumentError.value(
        event.name,
        'event',
        "$event can't have a '$key' parameter: it sets that key itself",
      );
    }
  }
  return {...event.parameters.toAppsFlyerEventValues(), ...values};
}

bool _sameParameters(Map<String, AnalyticsValue> a, Map<String, AnalyticsValue> b) =>
    a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

int _hashParameters(Map<String, AnalyticsValue> parameters) =>
    Object.hashAllUnordered(parameters.entries.map((it) => Object.hash(it.key, it.value)));
