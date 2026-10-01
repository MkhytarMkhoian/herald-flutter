import 'package:herald/herald.dart';

import 'amplitude_property_setter.dart';

abstract interface class AmplitudePropertySetterFactory {
  Resolution<AmplitudePropertySetter> create(Property property);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeAmplitudePropertySetterFactory(List<AmplitudePropertySetterFactory> factories)
    implements AmplitudePropertySetterFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<AmplitudePropertySetterFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<AmplitudePropertySetter> create(Property property) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(property)));
}
