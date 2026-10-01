import 'package:herald/herald.dart';

extension MixpanelValue on AnalyticsValue {
  Object get asMixpanelValue => value;
}

extension MixpanelProperties on Map<String, AnalyticsValue> {
  Map<String, Object> toMixpanelProperties() => {
    for (final MapEntry(:key, :value) in entries) key: value.asMixpanelValue,
  };
}
