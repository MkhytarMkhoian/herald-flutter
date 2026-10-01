import 'package:herald/herald.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../mixpanel_property_setter.dart';
import '../mixpanel_values.dart';

/// Registers [property] as a super property, so Mixpanel attaches it to every later event from
/// this device.
final class const GenericMixpanelPropertySetter(final Property property, final Mixpanel mixpanel)
    implements MixpanelPropertySetter {
  @override
  Future<void> set() =>
      mixpanel.registerSuperProperties({property.name: property.value.asMixpanelValue});
}
