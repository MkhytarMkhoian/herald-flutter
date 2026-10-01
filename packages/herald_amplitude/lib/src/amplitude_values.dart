import 'package:herald/herald.dart';

extension AmplitudeValue on AnalyticsValue {
  Object get asAmplitudeValue => value;
}

extension AmplitudeProperties on Map<String, AnalyticsValue> {
  Map<String, Object> toAmplitudeProperties() => {
    for (final MapEntry(:key, :value) in entries) key: value.asAmplitudeValue,
  };
}
