import 'package:herald/herald.dart';

import 'adjust_event_tracker.dart';
import 'adjust_event_tracker_factory.dart';
import 'adjust_property_setter.dart';
import 'adjust_property_setter_factory.dart';
import 'setters/generic_adjust_property_setter.dart';
import 'trackers/token_adjust_event_tracker.dart';

/// Claims every event whose name has a dashboard token in `tokens`, and declines the rest.
///
/// Adjust only knows events created in its dashboard, so there is no generic event factory: an
/// event without a token isn't sent. One token per event; for an event that should count as several
/// Adjust events, write a factory that answers with several [TokenAdjustEventTracker]s and put it
/// before this one.
final class TokenAdjustEventTrackerFactory(Map<String, String> tokens)
    implements AdjustEventTrackerFactory {
  final Map<String, String> _tokens = Map.unmodifiable(tokens);

  @override
  Resolution<AdjustEventTracker> create(Event event) => switch (_tokens[event.name]) {
    final token? => .claimed([TokenAdjustEventTracker(event, token)]),
    null => .declined(),
  };
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
