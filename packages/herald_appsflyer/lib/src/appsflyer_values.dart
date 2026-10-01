import 'package:herald/herald.dart';

extension AppsFlyerValue on AnalyticsValue {
  /// The value with its type kept. AppsFlyer counts revenue only when `af_revenue` arrives as a
  /// number, so a number must stay one.
  Object get asAppsFlyerValue => value;
}

extension AppsFlyerEventValues on Map<String, AnalyticsValue> {
  Map<String, Object> toAppsFlyerEventValues() => {
    for (final MapEntry(:key, :value) in entries) key: value.asAppsFlyerValue,
  };
}
