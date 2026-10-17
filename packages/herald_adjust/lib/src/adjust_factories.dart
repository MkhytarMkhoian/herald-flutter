import 'package:herald/herald.dart';

import 'adjust_event_tracker.dart';
import 'adjust_event_tracker_factory.dart';
import 'adjust_property_setter.dart';
import 'adjust_property_setter_factory.dart';
import 'setters/generic_adjust_property_setter.dart';
import 'trackers/token_adjust_event_tracker.dart';

/// The Adjust dashboard token for events of type `E`: `AdjustToken<SignUpCompleted>('abc123')`.
final class const AdjustToken<E extends Event>(final String token) {
  Type get _eventType => E;

  bool _matches(Event event) => event is E;

  @override
  String toString() => 'AdjustToken<$E>($token)';
}

/// Sends each event that has a token in `tokens` under that token, and declines the rest:
///
/// ```dart
/// TokenAdjustEventTrackerFactory([AdjustToken<SignUpCompleted>('abc123')])
/// ```
///
/// Events are matched by type, not by name, so a renamed event keeps its token. An event that
/// extends a listed type uses its token too.
///
/// One token per event; for an event that should count as several Adjust events, write a factory
/// that answers with several [TokenAdjustEventTracker]s and put it before this one.
final class TokenAdjustEventTrackerFactory(List<AdjustToken<Event>> tokens)
    implements AdjustEventTrackerFactory {
  final List<AdjustToken<Event>> _tokens = List.unmodifiable(tokens);

  /// Throws an [ArgumentError] if a type has two tokens.
  this {
    final seen = <Type>{};
    for (final token in _tokens) {
      if (!seen.add(token._eventType)) {
        throw ArgumentError(
          '${token._eventType} has two Adjust tokens. Give each event one token.',
        );
      }
    }
  }

  @override
  Resolution<AdjustEventTracker> create(Event event) {
    for (final token in _tokens) {
      if (token._matches(event)) return .claimed([TokenAdjustEventTracker(event, token.token)]);
    }
    return .declined();
  }
}

/// Adds any property as a global callback parameter. Adjust has no user profile, so this covers
/// [UserProperty] too. Claims everything, so it belongs last in a chain.
final class const GenericAdjustPropertySetterFactory()
    implements AdjustPropertySetterFactory, FallbackFactory {
  @override
  Resolution<AdjustPropertySetter> create(Property property) =>
      .claimed([GenericAdjustPropertySetter(property)]);

  @override
  String toString() => 'GenericAdjustPropertySetterFactory';
}
