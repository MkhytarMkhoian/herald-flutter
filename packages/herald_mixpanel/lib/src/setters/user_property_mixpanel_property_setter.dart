import 'package:herald/herald.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../mixpanel_property_setter.dart';
import '../mixpanel_values.dart';

final class const UserPropertyMixpanelPropertySetter(
  final UserProperty property,
  final Mixpanel mixpanel,
) implements MixpanelPropertySetter {
  @override
  Future<void> set() async =>
      mixpanel.getPeople().set(property.name, property.value.asMixpanelValue);
}
