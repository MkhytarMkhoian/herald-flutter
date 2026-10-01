import 'package:herald/herald.dart';

import 'mixpanel_property_setter.dart';

abstract interface class MixpanelPropertySetterFactory {
  Resolution<MixpanelPropertySetter> create(Property property);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeMixpanelPropertySetterFactory(List<MixpanelPropertySetterFactory> factories)
    implements MixpanelPropertySetterFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<MixpanelPropertySetterFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<MixpanelPropertySetter> create(Property property) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(property)));
}
