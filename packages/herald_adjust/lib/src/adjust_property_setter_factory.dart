import 'package:herald/herald.dart';

import 'adjust_property_setter.dart';

abstract interface class AdjustPropertySetterFactory {
  Resolution<AdjustPropertySetter> create(Property property);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeAdjustPropertySetterFactory(List<AdjustPropertySetterFactory> factories)
    implements AdjustPropertySetterFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<AdjustPropertySetterFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<AdjustPropertySetter> create(Property property) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(property)));
}
