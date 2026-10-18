import 'package:herald/herald.dart';

/// Parameters as Meta takes them: numbers stay numbers, and true/false becomes text, since Meta's
/// parameters are text or numbers.
extension MetaParameters on Map<String, AnalyticsValue> {
  Map<String, Object> toMetaParameters() => {
    for (final MapEntry(:key, :value) in entries)
      key: switch (value) {
        AnalyticsInt(:final value) => value,
        AnalyticsDouble(:final value) => value,
        AnalyticsString(:final value) => value,
        AnalyticsBool(:final value) => value ? 'true' : 'false',
      },
  };
}
