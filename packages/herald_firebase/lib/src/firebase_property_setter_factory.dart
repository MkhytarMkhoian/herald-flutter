import 'package:herald/herald.dart';

import 'firebase_property_setter.dart';

abstract interface class FirebasePropertySetterFactory {
  Resolution<FirebasePropertySetter> create(Property property);
}

/// Asks each factory in order and uses the first answer that isn't a decline. If all decline,
/// nothing is sent. Throws an [ArgumentError] if a [FallbackFactory] isn't last.
final class CompositeFirebasePropertySetterFactory(List<FirebasePropertySetterFactory> factories)
    implements FirebasePropertySetterFactory {
  this {
    FallbackFactory.requireLast(_factories);
  }

  final List<FirebasePropertySetterFactory> _factories = List.unmodifiable(factories);

  @override
  Resolution<FirebasePropertySetter> create(Property property) =>
      Resolution.firstOf(_factories.map((factory) => factory.create(property)));
}
