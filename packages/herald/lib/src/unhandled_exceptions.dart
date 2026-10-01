import 'event.dart';
import 'property.dart';

/// Thrown by a `RequireMapped` factory when no factory claimed an event.
///
/// The message names the event and its class. In builds made with `--obfuscate`, the class name is
/// obfuscated, but the event name isn't.
final class const UnhandledEventException(final Event event) implements Exception {
  @override
  String toString() =>
      "UnhandledEventException: No factory claimed event '${event.name}' (${event.runtimeType}). "
      'Add a factory for it, or end the chain with a generic factory to send it as-is.';
}

/// Like [UnhandledEventException], for properties.
final class const UnhandledPropertyException(final Property property) implements Exception {
  @override
  String toString() =>
      "UnhandledPropertyException: No factory claimed property '${property.name}' "
      '(${property.runtimeType}). '
      'Add a factory for it, or end the chain with a generic factory to set it as-is.';
}
