import 'property.dart';

/// Somewhere a [Property] can be set. Like `EventTrackerService`, for properties.
abstract interface class PropertyTrackerService {
  Future<void> set(Property property);
}
