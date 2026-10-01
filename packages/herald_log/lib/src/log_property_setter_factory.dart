import 'package:herald/herald.dart';

import 'log_property_setter.dart';

abstract interface class LogPropertySetterFactory {
  Resolution<LogPropertySetter> create(Property property);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeLogPropertySetterFactory(List<LogPropertySetterFactory> factories)
    implements LogPropertySetterFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<LogPropertySetterFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<LogPropertySetter> create(Property property) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(property)));
}
