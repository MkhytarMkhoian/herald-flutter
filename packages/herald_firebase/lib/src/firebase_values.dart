import 'package:herald/herald.dart';

extension FirebaseParameters on Map<String, AnalyticsValue> {
  /// The parameters with their types kept where GA4 has a matching type.
  ///
  /// GA4 accepts string and number parameters, so a number arrives as a number and stays
  /// aggregable. It has no boolean parameter type, so a flag is written as its string form,
  /// `'true'` or `'false'`.
  Map<String, Object> toFirebaseParameters() => {
    for (final MapEntry(:key, :value) in entries)
      key: switch (value) {
        AnalyticsInt(:final value) => value,
        AnalyticsDouble(:final value) => value,
        AnalyticsString() || AnalyticsBool() => value.asString,
      },
  };
}
